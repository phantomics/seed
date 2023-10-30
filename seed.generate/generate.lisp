;;;; seed.generate.lisp

(in-package #:seed.generate)

(defun load-system-directory (directory-path)
  (let ((files (uiop:directory-files directory-path)))
    (loop :for f :in files :when (string= "seed" (first (last (cl-ppcre:split "[.]" (namestring f)))))
          :do (load f))))

(defmacro seed-instance (&key portals-path)
  (let ((subdirs (gensym)) (sd (gensym)) (files (gensym)) (key (gensym))
        (si-sym (intern "*SEED-INTERFACES*" (package-name *package*))))
    `(let ((,subdirs (uiop:subdirectories ,(asdf:system-relative-pathname
                                            (intern (package-name *package*) "KEYWORD")
                                            portals-path))))
       (proclaim '(special ,si-sym))
       (setf ,si-sym nil)
       (defun ,(intern "OF-INTERFACES" (package-name *package*)) (,key)
         (getf ,(intern "*SEED-INTERFACES*" (package-name *package*)) ,key))
       (loop :for ,sd :in ,subdirs :do (load-system-directory ,sd)))))

(defmacro system (name &key contacts branches)
  (let ((si-sym (intern "*SEED-INTERFACES*" (package-name *package*))))
    `(setf (getf ,si-sym ,name)
           (lambda (input &optional branch)
             (print (list :in input))))))

(defmacro seed (name &key props contacts branches bindings portal-contacts)
  (let* ((input (gensym)) (blank (gensym))
         (si-sym (intern "*SEED-INTERFACES*" (package-name *package*)))
         (psym `(getf ,si-sym ,(intern (string name) "KEYWORD"))))
    `(progn
       (unless (boundp ',si-sym) (defvar ,si-sym nil))
       (setf ,psym nil
             (getf ,psym :props) ',props
             ,@(when portal-contacts `((getf (getf ,psym :props) :portal-contacts) ',portal-contacts
                                       (getf (getf ,psym :props) :endpoint) nil)))
       ,@(loop :for contact-sym :in portal-contacts
               :collect `(load-system-directory (asdf:system-relative-pathname ,contact-sym "./")))
       (let ,(loop :for (key value) :on bindings :by #'cddr
                   :collect (list value (case key (:package (intern (string name) "KEYWORD"))
                                              (:system `(getf ,si-sym ,(intern (string name) "KEYWORD")))
                                              (:portal-name name))))
         (setf (getf ,psym :branches) ,(cons 'list branches))))))

(defun in-system-context (spec system-name)
  (append (list (first spec) (second spec))
          (cons (cons :system system-name) (cddr spec))))

(defmacro manifest-portal-contact-web (&rest options)
  (let ((pname (package-name *package*)))
    (cons 'portal-contact-web (append options (list :package-name (intern pname "KEYWORD")
                                                    :main-interface (intern "*SEED-INTERFACES*" pname))))))

(defun portal-contact-web (&key (port 8080) package-name
                             main-interface static-provider output-process)
  (let* ((root-path (asdf:system-relative-pathname package-name "./"))
	 (service (make-instance 'ningle::app))
	 (handler (clack:clackup (lack.builder:builder
				  :session nil
				  ;; (:static :path
				  ;;          (lambda (path) (if (ppcre:scan "^(?:/static/|/sound-files/)" path)
				  ;;       		      path nil))
				  ;;          :root root-path)
				  service)
				 :port port :server :woo :address "0.0.0.0")))
    (setf (ningle:route service "/" :accept '("text/html" "text/xml"))
	  (lambda (params)
            (let ((portal-sym (intern (string-upcase (rest (assoc :portal params))) "KEYWORD")))
              (funcall static-provider))))
    (setf (ningle:route service "/:portal/" :accept '("text/html" "text/xml"))
	  (lambda (params)
            (let ((portal-sym (intern (string-upcase (rest (assoc :portal params))) "KEYWORD")))
              ;; (print (list :ee portal-sym (getf main-interface portal-sym)))
              ;; (print (list :ff ;; (funcall (getf (getf (getf main-interface portal-sym) :branches)
              ;;                  ;;                :systems))
              ;;              ))
              (com.inuoe.jzon:stringify (funcall (getf (getf (getf main-interface portal-sym) :branches)
                                                       :systems))))))
    ;; (setf (ningle:route service "/" :accept '("text/html" "text/xml"))
    ;;       #'present-main-interface)
    ;; (setf (ningle:route service "/enter" :method :POST)
    ;;       (lambda (params)
    ;;         (handler-case
    ;;     	(let* ((original-params params)
    ;;     	       (username (cdr (assoc "username" params :test #'string=)))
    ;;     	       (password (cdr (assoc "password" params :test #'string=))))
    ;;     	  (login (list :|username| username :|password| password)
    ;;     		 (redirect-to "/")
    ;;     		 (present-login-interface (cons '("message" . "Wrong username or password.")
    ;;     						original-params))
    ;;     		 (present-login-interface (cons '("message" . "Wrong username or password.")
    ;;     						original-params))))
    ;;           (error (c)
    ;;     	(format t "Caught a condition: ~&")
    ;;     	(values (jonathan:to-json '(:|error| t))
    ;;     		c)))))
    ;; (setf (ningle:route service "/exit" :method :GET)
    ;;   (lambda (params)
    ;;     (handler-case
    ;;         (logout (present-login-interface (cons '("message" . "You are now logged out.") params))
    ;;     	    (present-login-interface (cons '("message" . "You are not logged in.") params)))
    ;;       (error (c)
    ;;         (format t "Caught a condition: ~&")
    ;;         (values (jonathan:to-json '(:|error| t))
    ;;     	    c)))))
    (setf (ningle:route service "/:portal/:contact/grow/" :method :port :accept "application/json")
	  (lambda (params)
	    (handler-case (interact portal :systems params)
	      (error (c)
		(format t "Caught a condition: ~&")
		(values 5 ; (jonathan:to-json '(:|error| t))
			c)))))
    (values (setq *stop-server* (lambda () (clack:stop handler)))
	    (setq *restart-server* (lambda () (clack:stop handler)
					   (clack:clackup service :port port :server :woo))))))

(defun interact (portal branch &optional input)
  (funcall (getf (getf portal :branches) branch)
           input))

(defun with (item &rest props) ;; obsolete
  (append (list :props item) props))

(defun with-meta (item &rest props)
  `(meta ,item ,@props))

(defun portal-contacts (system)
  (getf (getf (if (not (symbolp system))
                  system (getf *seed-interfaces* system))
              :props) :portal-contacts))

(defun portal-endpoint (system)
  (getf (getf (if (not (symbolp system))
                  system (getf *seed-interfaces* system))
              :props) :endpoint))

(defun of-system (system &rest keys)
  ;; (print (list :ss system keys))
  (let ((found (getf system (first keys))))
    (if (not (rest keys))
        found (apply #'of-system found (rest keys)))))

(defun build-key-path (value keys)
  (if (rest keys) (list (first keys) (build-key-path value (rest keys)))
      (list (first keys) value)))

(defun (setf of-system) (new-value system &rest keys)
  "Set a system property according to a series of keys."
  (if (rest keys)
      (let ((found (getf system (first keys))))
        (if (member (cadr keys) found)
            (setf (apply #'of-system found (rest keys)) new-value
                  (getf system (first keys))            found)
            (setf (getf system (first keys))
                  (append (build-key-path new-value (rest keys))
                          found))))
      (setf (getf system (first keys)) new-value)))

(defun array-to-list (input)
  "Convert array to list."
  (if (or (not (arrayp input))
          (zerop (array-rank input)))
      (list (disclose input))
      (let* ((dimensions (array-dimensions input))
             (depth (1- (length dimensions)))
             (indices (make-list (1+ depth) :initial-element 0)))
        (labels ((recurse (n)
                   (loop :for j :below (nth n dimensions)
                      :do (setf (nth n indices) j)
                      :collect (if (= n depth)
                                   ;; (let ((item (apply #'aref input indices)))
                                   ;;   (if (arrayp item)
                                   ;;  (array-to-list item)
                                   ;;  item))
                                   (apply #'aref input indices)
                                   (recurse (1+ n))))))
          (recurse 0)))))

(defmacro load-seed-system (system)
  `(progn (asdf:operate 'asdf:prepare-op ,system)
          (seed.sublimate:instantiate-priority-macro-reader (asdf:load-system ,system))))

(defun encode (form &optional meta)
  ;; (print (list :fo form meta))
  (if (listp form)
      (if (and (symbolp (first form))
               (string= "META" (string-upcase (first form))))
          (if (listp (second form))
              `(:ty :ls :ct ,(loop :for item :in (second form) :collect (encode item))
                 ,@(if (not (cddr form))
                       nil (list :mt (cddr form))))
              (encode (second form) (cddr form)))
          (loop :for item :in form :collect (encode item)))
      (if nil ; (arrayp form)
          form (append (if meta (list :mt  meta) nil)
                       `(:ty ,(typecase form (symbol :sy) (number :nm) (array :ar))
                         :ct ,(typecase form (symbol (string form)) (string form)
                                        (array (array-to-list form))
                                        (t (write-to-string form)))
                         ,@(if (typep form 'array)
                               (list :dm (array-dimensions form)))
                         ,@(if (not (symbolp form))
                               nil `(:pk ,(package-name (symbol-package form)))))))))

(defun form-span (form &optional collapse-sublists)
  (if (not (listp (first form)))
      nil (if (listp (caar form))
              (loop :for item :in form :collect (form-span item collapse-sublists))
              (let ((sum 0) (sublists))
                (loop :for item :in (rest form)
                      :do (let ((result (form-span item collapse-sublists)))
                            (incf sum (if (not result)
                                          1 (progn (setf sublists t)
                                                   (or (getf (first item) :br) 1))))))
                (when (or sublists (not collapse-sublists))
                  (setf (getf (first form) :br) sum))
                form))))

(defun align-first-vector (vectors)
  (let ((max-length 0))
    (loop :for v :in vectors :do (setf max-length (max max-length (length v))))
    (when (> max-length (length (first vectors)))
      (setf (first vectors) (append (first vectors)
                                    (loop :for i :below (- max-length (length (first vectors)))
                                          :collect nil))))
    vectors))

(defun form-as-vectors (form &optional vectors (vpoint 0) (vdepth 0))
  (let ((root (not vectors))
        (vectors (or vectors (list :v))))
    (if (not (listp (first form)))
        nil (if (listp (caar form))
                (let ((cvpoint vpoint) (cvdepth vdepth))
                  ;; (incf vdepth)
                  (loop :for item :in form
                        :do (multiple-value-bind (_ new-vpoint new-vdepth)
                                (form-as-vectors item vectors cvpoint vdepth)
                              (setf cvpoint new-vpoint)))
                  (values (if (not root) vectors
                              (align-first-vector (mapcar #'reverse (reverse (rest vectors)))))
                          cvpoint cvdepth))
                (symbol-macrolet ((this-vector (nth (- (length (rest vectors)) 1 vpoint)
                                                    (rest vectors))))
                  ;; (print :ggg)
                  (loop :while (> vpoint (1- (length (rest vectors)))) :do (push nil (rest vectors)))
                  ;; (print (list :vv vectors (- (length (rest vectors)) vpoint)))
                  (when (> vdepth (length this-vector))
                    (loop :for i :from vdepth :downto (1+ (length this-vector))
                          :do (push nil
                                    ;; 1
                                    this-vector)))
                  (push (first form) this-vector)
                  (incf vdepth)
                  ;; (print (list :tv vectors))
                  (loop :for item :in (rest form)
                        :do (when (> vdepth (length this-vector))
                              (loop :for i :from vdepth :downto (1+ (length this-vector))
                                    :do (push nil
                                              ;; 1
                                              this-vector)))
                            (multiple-value-bind (new-vectors new-vpoint new-vdepth)
                                (form-as-vectors item vectors vpoint vdepth)
                              (if new-vectors (setf vpoint new-vpoint vdepth new-vdepth)
                                  (progn (push item this-vector)
                                         (incf vpoint)
                                         ;; (print (list :vp vpoint (1- (length (rest vectors)))))
                                         (loop :while (> vpoint (1- (length (rest vectors))))
                                               :do (push nil (rest vectors)))))))
                  (values (if (not root) vectors
                              (align-first-vector (mapcar #'reverse (reverse (cddr vectors)))))
                          vpoint vdepth))))))

;; (defun json-convert-to (form)
;;   (jonathan:to-json form))

;; (defun json-convert-to (form &optional stream)
;;   (let ((initial (not stream))
;;         (stream (or stream (make-string-output-stream))))
;;     (if (not (listp form))
;;         (com.inuoe.jzon:stringify form)
;;         (if (keywordp (first form))
;;             (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
;;               (com.inuoe.jzon:with-object* 
;;                 (loop :for (key value) :on form :by #'cddr
;;                       :do (com.inuoe.jzon:write-key* (symbol-munger:lisp->camel-case key))
;;                           (com.inuoe.jzon:write-value* value))))
;;             (loop :for item :in form :do (json-convert-to item stream))))
;;     (if (not initial)
;;         nil (get-output-stream-string stream))))

;; (defun json-convert-to (form &optional stream)
;;   (let ((initial (not stream))
;;         (stream (or stream (make-string-output-stream))))
;;     (print (list :fo form))
;;     (if (not (listp form))
;;         (if (arrayp form)
;;             (loop :for item :across form :collect (json-convert-to item stream))
;;             (com.inuoe.jzon:stringify form))
;;         (if (keywordp (first form))
;;             (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
;;               (com.inuoe.jzon:with-object* 
;;                 (loop :for (key value) :on form :by #'cddr
;;                       :do (com.inuoe.jzon:write-key* (symbol-munger:lisp->camel-case key))
;;                           (when (eq :mt key) (print (list :vl value)))
;;                           (if (and (or (eq :ct key)
;;                                        (eq :mt key))
;;                                    (listp value))
;;                               (com.inuoe.jzon:with-array*
;;                                 (loop :for item :in value :do (json-convert-to item stream)))
;;                               (if (and (symbolp value) (not (eq :ct key)))
;;                                   (com.inuoe.jzon:write-value*
;;                                    (symbol-munger:lisp->camel-case value))
;;                                   (com.inuoe.jzon:write-value* value))))))
;;             (loop :for item :in form :do (json-convert-to item stream))))
;;     (if (not initial)
;;         nil (get-output-stream-string stream))))

(defun json-convert-to (form &optional stream)
  (let ((initial (not stream))
        (stream (or stream (make-string-output-stream))))
    ;; (print (list :in initial))
    (if initial (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
                  (json-convert-to form stream)
                  (get-output-stream-string stream))
        (if (not (listp form))
            (if (arrayp form)
                (com.inuoe.jzon:with-array*
                  (loop :for item :across form :do (json-convert-to item stream)))
                (com.inuoe.jzon:write-value* form))
            (if (keywordp (first form))
                (com.inuoe.jzon:with-object* 
                  (loop :for (key value) :on form :by #'cddr
                        :do (com.inuoe.jzon:write-key* (symbol-munger:lisp->camel-case key))
                            ;; (when (eq :mt key) (print (list :vl value form)))
                            (if (listp value)
                                (if (listp (first value))
                                    (com.inuoe.jzon:with-array*
                                      (loop :for item :in value :do (json-convert-to item stream)))
                                    (json-convert-to value stream))
                                (if (and (symbolp value) (not (eq :ct key)))
                                    (com.inuoe.jzon:write-value*
                                     (symbol-munger:lisp->camel-case value))
                                    (com.inuoe.jzon:write-value* value)))))
                (com.inuoe.jzon:with-array*
                  (loop :for item :in (if (not (eql '>> (first form)))
                                          form (rest form))
                        :do (json-convert-to item stream))))))))

(defun json-convert-from (form)
  (jonathan:parse form))

(defun alist-to-json (input-form &optional stream)
  (let ((stream (or stream (make-string-output-stream))))
    (flet ((process-form (form)
             (loop :for item :in form
                   :do (com.inuoe.jzon:write-key*
                        (symbol-munger:lisp->camel-case (first item)))
                       (if (not (third item))
                           (if (symbolp (third item))
                               (com.inuoe.jzon:write-value*
                                (symbol-munger:lisp->camel-case (second item)))
                               (com.inuoe.jzon:write-value* (second item)))
                           (com.inuoe.jzon:with-array*
                             (loop :for property :in (rest item)
                                   :do (if (symbolp property)
                                           (com.inuoe.jzon:write-value*
                                            (symbol-munger:lisp->camel-case property))
                                           (com.inuoe.jzon:write-value* property))))))))
      (if stream (com.inuoe.jzon:with-object* (process-form input-form))
          (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
            (com.inuoe.jzon:with-object* (process-form input-form))
            (get-output-stream-string stream))))))

;; (defmacro interface-spec (props &rest elements)
;;   `(generate-interface-spec ,@(loop :for el :in elements :collect (list 'quote el))))

;; (defmacro >> (&rest items)
;;   (cons 'vector items))

(defmacro uic (props &optional item)
  `(generate-uic ',props ,item))

(defmacro uic-set (props &rest clauses)
  `(generate-uic-set ',props ,@clauses))

(defun generate-uic (props &optional item)
  `(meta ,item ,@(loop :for clause :in props :collect (if (or t (not (listp clause))
                                                              (not (keywordp (first clause))))
                                                          clause (list 'quote clause)))))

(defun generate-uic-set (props &rest clauses)
  `(meta ,clauses ,@props))

(defun interface-format-form (form spec)
  (if (and (listp form) (listp (first form)))
      (loop :for item :in form :collect (interface-format-form item spec))
      (if (or (not (listp form))
              (not (eql 'meta (first form))))
          form (destructuring-bind (meta-sym content &rest meta-props) form
                 (append (list meta-sym (interface-format-form content spec))
                         (meta-spec-extend meta-props (rest (assoc "interfaceSpec"
                                                                   spec :test #'string=))))))))

(defun meta-spec-extend (props spec)
  (append (cond ((string= "browser" (first spec))
                 (cond ((string= "react" (second spec))
                        (append (cond ((member :group (getf props :type) :test #'eq)
                                       (list :react-component "SeedView"))
                                      ((member :form (getf props :type) :test #'eq)
                                       (list :react-component "SeedForm"))
                                      (t nil))
                                (cond ((equalp (getf props :members) '(>> :sidebar :main))
                                       (list :builder "layoutColumnar"
                                             :specs (list (list :width 3)
                                                          (list :width 9))))
                                      ((equalp (getf props :members) '(>> :heading :main))
                                       (list :builder "layoutStacked"
                                             :specs (list (list :height 1)
                                                          (list :height 1))))
                                      (t nil)))))))
          props))

(defmacro psl (form)
  `(subseq (parenscript:ps-inline ,form) 11))

(defun branch-spec-form (stream-out section &rest props)
  (let ((system (getf props :system))
        (branch (getf props :branch)))
    (case section
      (:body (cl-who:with-html-output (stream-out)
               (:form :class "container" :hx-post "/render/" :hx-trigger "load, reload consume, submit"
                      :id (format nil "branch-~a" (lisp->camel-case branch))
                      :hx-vals (json-convert-to (list :system system :branch branch)))))
      (:body-svg (let ((this-id (format nil "branch-~a" (lisp->camel-case branch))))
                   (cl-who:with-html-output (stream-out)
                     (:div :hx-post "/render/" :hx-trigger "load, reload consume"
                           :class "sub-container"
                           :x-init (psl (progn (chain console (log :eo))
                                               (fetch-contact (lisp (string-upcase (getf props :system)))
                                                              (lisp (string-upcase (getf props :branch)))
                                                              (create height (@ $el offset-height)
                                                                      width  (@ $el offset-width))
                                                              (lambda (data)
                                                                (chain console (log :dt data
                                                                                    (@ $el offset-height)))
                                                                ))))
                           :id this-id :hx-vals (json-convert-to (list :system system :branch branch))))))
      (:control
       (case (getf props :subsection)
         (:submit (cl-who:with-html-output (stream-out)
                    (:button :class "ui button"
                             ;; :|x-on:click| (lsk (fetch-contact ))
                             (str (string-downcase (getf props :subsection))))))
         (:save (cl-who:with-html-output (stream-out)
                  (:button :class "ui button"
                           (str (string-downcase (getf props :subsection))))))
         )))))

(defun branch-spec-codemirror-editor (stream-out section &rest props)
  (let ((token (format nil "cm-texteditor-~a-~a"
                       (string-downcase (getf props :system))
                       (string-downcase (getf props :branch)))))
    (case section
      (:body (cl-who:with-html-output (stream-out)
               (:div :id (lisp token) :class (getf props :item-classes)
                     :x-init (psl (progn (setf (@ window codemirror) nil)
                                         (fetch-contact (lisp (string-upcase (getf props :system)))
                                                        (lisp (string-upcase (getf props :branch)))
                                                        nil (lambda (data) 
                                                              ;; (chain console (log :dt (@ data text)))
                                                              (setf (getprop (@ window seed-data)
                                                                             (lisp token))
                                                                    (create-codemirror
                                                                     (chain document
                                                                            (get-element-by-id (lisp token)))
                                                                     (@ data text))))))))))
      (:control
       (case (getf props :subsection)
         (:save (cl-who:with-html-output (stream-out)
                  (:button :class "ui button"
                           :|x-on:click|
                           (psl (fetch-contact (lisp (string-upcase (getf props :system)))
                                               (lisp (string-upcase (getf props :branch)))
                                               (@ (getprop (@ window seed-data)
                                                           (lisp token))
                                                  state doc text)
                                               ;; (@ window codemirror state doc text)
                                               (lambda (data) (chain console (log :sv)))))
                           (str (string-downcase (getf props :subsection)))))))))))

(defun branch-spec-cvdatagrid-tree (stream-out section &rest props)
  (let ((token (format nil "canvas-datagrid-~a-~a"
                       (string-downcase (getf props :system))
                       (string-downcase (getf props :branch))))
        (mode (getf props :mode)))
    (case section
      (:body (cl-who:with-html-output (stream-out)
               (:div :id "datagrid-tree" :class (getf props :item-classes)
                     :x-init
                     (psl (fetch-contact
                           (lisp (string-upcase (getf props :system)))
                           (lisp (string-upcase (getf props :branch)))
                           nil (lambda (data)
                                 (let* ((grid-schema
                                          (chain (getprop data 0)
                                                 (map (lambda (item ix)
                                                        (create name ""
                                                                type "lisp"
                                                                ;; style cell-width 60
                                                                )))))
                                        (grid (canvas-datagrid
                                               (create schema grid-schema
                                                       style (create cell-width 60)))))
                                   (chain console (log :gs grid-schema))
                                   (chain document (get-element-by-id "datagrid-tree")
                                          (append-child grid))

                                   (chain grid (add-event-listener
                                                "beforerendercell"
                                                (lambda (e)
                                                  ;; (chain console
                                                  ;;        (log :ee (getprop (@ e row)
                                                  ;;                          (@ e cell
                                                  ;;                               bound-column-index)
                                                  ;;                          ;; "ct"
                                                  ;;                          )
                                                  ;;             (or (= undefined
                                                  ;;                    (getprop (@ e row)
                                                  ;;                             (@ e cell bound-column-index)))
                                                  ;;                 (= -array
                                                  ;;                    (getprop (@ e row)
                                                  ;;                             (@ e cell
                                                  ;;                                  bound-column-index)
                                                  ;;                             "constructor")))
                                                  ;;             ))
                                                  (if ;; (or (= undefined
                                                      ;;        (getprop (@ e row)
                                                      ;;                 (@ e cell bound-column-index)))
                                                      ;;     ;; (if (= -array
                                                      ;;     ;;        (getprop (@ e row)
                                                      ;;     ;;                 (@ e cell
                                                      ;;     ;;                      bound-column-index)
                                                      ;;     ;;                 "constructor"))
                                                      ;;     ;;     (= 0 (getprop (@ e row)
                                                      ;;     ;;                   (@ e cell bound-column-index)
                                                      ;;     ;;                   "length")))
                                                      ;;     )
                                                      (or (= undefined
                                                             (getprop (@ e row)
                                                                      (@ e cell bound-column-index)))
                                                          ;; (= -array
                                                          ;;    (getprop (@ e row)
                                                          ;;             (@ e cell
                                                          ;;                  bound-column-index)
                                                          ;;             "constructor"))
                                                          )
                                                      ;; (= -array
                                                      ;;    (getprop (@ e row)
                                                      ;;             (@ e cell
                                                      ;;                  bound-column-index)
                                                      ;;             "constructor"))
                                                      (chain e (prevent-default)))
                                                  ;; (if (<= (length (@ e row))
                                                  ;;         (@ e cell bound-column-index))
                                                  ;;     (chain e (prevent-default)))
                                                  )))

                                   (chain grid (add-event-listener
                                                "rendercell"
                                                (lambda (e)
                                                  ;; (chain console (log :ee (getprop (@ e row)
                                                  ;;                                  (@ e cell bound-column-index))))
                                                  (if (and (/= -array (getprop (@ e row)
                                                                               (@ e cell bound-column-index)
                                                                               "constructor"))
                                                           (/= undefined
                                                               (getprop (@ e row)
                                                                        (@ e cell bound-column-index)
                                                                        "br")))
                                                      (progn ;; (setf (@ e cell height)
                                                             ;;       (* (getprop (@ e row)
                                                             ;;                   (@ e cell bound-column-index)
                                                             ;;                   "br")
                                                             ;;          (@ e cell height)))
                                                        ;; (chain console (log :hh (* (getprop (@ e row)
                                                        ;;                                     (@ e cell bound-column-index)
                                                        ;;                                     "br")
                                                        ;;                            (@ e cell height))))
                                                             ))
                                                  ;; (chain console (log "c" (@ e value)))
                                                  )))
                                   
                                   (setf (@ grid data) data
                                         (getprop (@ window seed-data) (lisp token))
                                         grid
                                         ;; (@ grid style) (create cell-width 60)
                                         (@ grid formatters lisp)
                                         (lambda (e b)
                                           (if (<= (length (@ e row))
                                                   (@ e cell bound-column-index))
                                               "" (getprop (@ e row)
                                                           (@ e cell bound-column-index)
                                                           "ct")))
                                         ))))))))
      (:control
       (case (getf props :subsection)
         (:save (cl-who:with-html-output (stream-out)
                  (:button :class "ui button"
                           :|x-on:click|
                           (psl (fetch-contact (lisp (string-upcase (getf props :system)))
                                               (lisp (string-upcase (getf props :branch)))
                                               (@ (getprop (@ window seed-data) (lisp token))
                                                  data)
                                               (lambda (data) (chain console (log :sv)))))
                           (str (string-downcase (getf props :subsection)))))))))))

(defun branch-spec-cvdatagrid-sheet (stream-out section &rest props)
  (let ((token (format nil "canvas-datagrid-~a-~a"
                       (string-downcase (getf props :system))
                       (string-downcase (getf props :branch))))
        (mode (getf props :mode)))
    (case section
      (:body (cl-who:with-html-output (stream-out)
               (:div :id "datagrid-cells" :class (getf props :item-classes)
                     :x-init
                     (psl (fetch-contact
                           (lisp (string-upcase (getf props :system)))
                           (lisp (string-upcase (getf props :branch)))
                           nil (lambda (data)
                                 ;; (chain console (log :dd data))
                                 (let ((grid (canvas-datagrid (create style (create cell-width 60)))))
                                   (chain document (get-element-by-id "datagrid-cells")
                                          (append-child grid))
                                   (setf (@ grid data) (@ data ct)
                                         (getprop (@ window seed-data) (lisp token))
                                         grid))))))))
      (:control
       (case (getf props :subsection)
         (:save (cl-who:with-html-output (stream-out)
                  (:button :class "ui button"
                           :|x-on:click|
                           (psl (fetch-contact (lisp (string-upcase (getf props :system)))
                                               (lisp (string-upcase (getf props :branch)))
                                               (@ (getprop (@ window seed-data) (lisp token))
                                                  data)
                                               (lambda (data) (chain console (log :sv)))))
                           (str (string-downcase (getf props :subsection))))))
         (:toggle-baseline
          (cl-who:with-html-output (stream-out)
            (:button :class "ui button"
                     :|x-on:click|
                     (psl (fetch-contact (lisp (string-upcase (getf props :system)))
                                         (lisp (string-upcase (getf props :branch)))
                                         (create toggle-baseline t)
                                         (lambda (data) (chain console (log :tb)))))
                     (str (string-downcase (getf props :subsection)))))))))))

(defun branch-spec-d3 (stream-out section &rest props)
  (let ((token (format nil "canvas-datagrid-~a-~a"
                       (string-downcase (getf props :system))
                       (string-downcase (getf props :branch))))
        (mode (getf props :mode)))
    (case section
      (:body (cl-who:with-html-output (stream-out)
               (:div :id "d3-container"
                     :x-init
                     (psl (let ((fetcher (lambda (builder data)
                                           (fetch-contact
                                            (lisp (string-upcase (getf props :system)))
                                            (lisp (string-upcase (getf props :branch)))
                                            data builder))))
                            (funcall fetcher (chain window (d3-build fetcher))
                                     nil))))))
      (:control
       (case (getf props :subsection)
         (:save (cl-who:with-html-output (stream-out)
                  (:button :class "ui button"
                           :|x-on:click|
                           (psl (fetch-contact (lisp (string-upcase (getf props :system)))
                                               (lisp (string-upcase (getf props :branch)))
                                               (@ (getprop (@ window seed-data) (lisp token))
                                                  data)
                                               (lambda (data) (chain console (log :sv)))))
                           (str (string-downcase (getf props :subsection)))))))))))

(defun render-html-interface (form &optional system-id meta path stream)
  (let ((strout (or stream (make-string-output-stream)))
        ;; get ID of applicable system from form metadata
        (system-id (or (rest (assoc :system (getf form :mt)))
                       system-id))
        (path-string (apply #'concatenate 'string
                            (loop :for item :in (reverse path)
                                  :append (list (write-to-string item) " ")))))
    (case (getf form :ty)
      ;; (print (list :mm meta))
      (:sy (if (not (getf meta :app))
               (write-string (getf form :ct) strout)
               (case (getf meta :app)
                 (:set-endpoint
                  (cl-who:with-html-output (strout)
                    (:span :|x-on:click|
                           (psl (chain (fetch "/contact/"
                                              (create method "POST"
                                                      body (chain -j-s-o-n
                                                                  (stringify
                                                                   (create
                                                                    portal (lisp (string-upcase
                                                                                  system-id))
                                                                    BRANCH "SYSTEMS"
                                                                    input (ps:lisp (getf form :ct)))))
                                                      headers (create "Content-type"
                                                                      "application/json; charset=UTF-8")))
                                       (then (lambda (response) (chain response (json))))
                                       (then (lambda (data) (chain htmx (trigger "#main" "reload"))))))
                           (str (lisp->camel-case (getf form :ct))))))
                 (t (write-string (getf form :ct) strout)))))
      (:ar (when (stringp (getf form :ct))
             (write-string (getf form :ct) strout)))
      (:ls (let ((contents (getf form :ct))
                 (type (rest (assoc :type (getf form :mt))))
                 (members (rest (assoc :members (getf form :mt)))))
             (match type
               ((list :form)
                (cl-who:with-html-output (strout)
                  (:div :path path-string
                        (loop :for c :in contents :for ix :from 0
                              :do (let ((item-classes
                                          (apply #'concatenate 'string
                                                 (loop :for y :in (rest (assoc :type (getf c :mt)))
                                                       :collect (format nil "~a " y))))
                                        (this-meta (if (not (assoc :app (getf form :mt)))
                                                       nil (assoc :app (getf form :mt)))))
                                    (if (assoc :access (getf c :mt))
                                        (let ((branch (second (assoc :access (getf c :mt)))))
                                          (htm (:div :class item-classes :hx-trigger "load, reload"
                                                     :hx-post "/render/"
                                                     :hx-vals (json-convert-to (list :system :portal.demo1
                                                                                     :branch branch)))))
                                        (htm (:div :class item-classes
                                                   (render-html-interface c system-id this-meta
                                                                          (cons ix path)
                                                                          strout)))))))))
               ((list :form :elem)
                (let ((branch (second (assoc :access (getf form :mt))))
                      (controls (rest (assoc :controls (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class "container column-inner"
                          (if (not (assoc :header controls))
                              nil (htm (:div :class "ui medium header"
                                             (:h2 :class "branch-name" (str (lisp->camel-case branch)))
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :header controls))
                                                         :do (branch-spec-form
                                                              strout :control :subsection c :system system-id
                                                              :branch branch))))))
                          (branch-spec-form
                           strout :body-svg :system system-id :branch branch :item-classes item-classes)
                          (if (not (assoc :footer controls))
                              nil (htm (:div :class "ui medium footer"
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :footer controls))
                                                         :do (branch-spec-form
                                                              strout :control :subsection c :system system-id
                                                              :branch branch))))))))))
               ((list :form :text)
                (let ((branch (second (assoc :access (getf form :mt))))
                      (controls (rest (assoc :controls (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class "container column-inner"
                          (if (not (assoc :header controls))
                              nil (htm (:div :class "ui medium header"
                                             (:h2 :class "branch-name" (str (lisp->camel-case branch)))
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :header controls))
                                                         :do (branch-spec-codemirror-editor
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))
                          (branch-spec-codemirror-editor strout :body :system system-id
                                                                     :branch branch :item-classes item-classes)
                          (if (not (assoc :footer controls))
                              nil (htm (:div :class "ui medium footer"
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :footer controls))
                                                         :do (branch-spec-codemirror-editor
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))))))
               ((list :form :tree)
                (let ((branch (second (assoc :access (getf form :mt))))
                      (controls (rest (assoc :controls (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class "container column-inner"
                          (if (not (assoc :header controls))
                              nil (htm (:div :class "ui medium header"
                                             (:h2 :class "branch-name" (str (lisp->camel-case branch)))
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :header controls))
                                                         :do (branch-spec-cvdatagrid-tree
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))
                          (branch-spec-cvdatagrid-tree strout :body :system system-id :mode :tree
                                                                    :branch branch :item-classes item-classes)
                          (if (not (assoc :footer controls))
                              nil (htm (:div :class "ui medium footer"
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :footer controls))
                                                         :do (branch-spec-cvdatagrid-tree
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))))))
               ((list :form :cells)
                (let ((branch (second (assoc :access (getf form :mt))))
                      (controls (rest (assoc :controls (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class "container column-inner"
                          (if (not (assoc :header controls))
                              nil (htm (:div :class "ui medium header"
                                             (:h2 :class "branch-name" (str (lisp->camel-case branch)))
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :header controls))
                                                         :do (branch-spec-cvdatagrid-sheet
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))
                          (branch-spec-cvdatagrid-sheet strout :body :system system-id
                                                                     :branch branch :item-classes item-classes)
                          (if (not (assoc :footer controls))
                              nil (htm (:div :class "ui medium footer"
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :footer controls))
                                                         :do (branch-spec-cvdatagrid-sheet
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))))))
               ((list :form :vector)
                (let ((branch (second (assoc :access (getf form :mt))))
                      (controls (rest (assoc :controls (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class "container column-inner"
                          (if (not (assoc :header controls))
                              nil (htm (:div :class "ui medium header"
                                             (:h2 :class "branch-name" (str (lisp->camel-case branch)))
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :header controls))
                                                         :do (branch-spec-d3
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))
                          (branch-spec-d3 strout :body :system system-id
                                                       :branch branch :item-classes item-classes)
                          (if (not (assoc :footer controls))
                              nil (htm (:div :class "ui medium footer"
                                             (:div :class "controls-holder"
                                                   (loop :for c :in (rest (assoc :footer controls))
                                                         :do (branch-spec-d3
                                                              strout :control :subsection c :system system-id
                                                                              :branch branch))))))))))
               ((list :form (guard form-type (keywordp form-type)))
                (let ((branch (second (assoc :access (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class item-classes :hx-trigger "load, reload"
                          :hx-post "/render/" :hx-vals (json-convert-to (list :system :demo.sheet
                                                                              :branch branch))))))
               ((list* :group :linear _)
                (let ((widths (if (eq :sidebar (first members))
                                  '("two" "fourteen") '("seven" "seven"))))
                  (cl-who:with-html-output (strout)
                    (:div :class (format nil "ui grid-layout ~a"
                                         (apply #'concatenate
                                                'string (loop :for s :in (cddr type)
                                                              :append (list " " (string-downcase s)))))
                          :path path-string
                          (loop :for c :in contents :for m :in members :for w :in widths :for ix :from 0
                                :do (let ((col-class (format nil "~a wide column" w))
                                          (item-classes
                                            (apply #'concatenate 'string
                                                   (loop :for y :in (rest (assoc :type (getf c :mt)))
                                                         :collect (format nil "~a " y)))))
                                      (htm (:div :class (format nil "~a ~a"
                                                                (string-downcase item-classes)
                                                                ;; col-class
                                                                (string-downcase m))
                                                 (render-html-interface c system-id nil
                                                                        (cons ix path)
                                                                        strout)))))))))
               ((list :group :stack)
                (cl-who:with-html-output (strout)
                  (:div :path path-string
                        (loop :for c :in contents :for m :in members :for ix :from 0
                              :do (let ((item-classes
                                          (apply #'concatenate 'string
                                                 (loop :for y :in (rest (assoc :type (getf c :mt)))
                                                       :collect (format nil "~a " (string-downcase y))))))
                                    (htm (:div :class item-classes
                                               (render-html-interface c system-id nil
                                                                      (cons ix path)
                                                                      strout))))))))))))
    (if stream nil (get-output-stream-string strout))))

(defun render-console (form &key branch)
  "Render a 'console'; a set of fields that independently update the server state when changed as opposed to requiring a specific 'submit' action to update all field values."
  (htrender form :input-processor (lambda (item)
                                    (let ((item-name (getf (cdar item) :name)))
                                      (list (append (first item)
                                                    (list :hx-post "/render/"
                                                          :id (format nil "branch-~a"
                                                                      (lisp->camel-case branch))
                                                          :hx-vals (json-convert-to
                                                                    (list :system :portal.demo1
                                                                          :branch branch
                                                                          :name item-name)))))))
            :branch branch))

(defun htrender (form &key branch input-processor form-parameters params)
  (if (listp (first form))
      (cons :div (loop :for f :in form :collect (htrender f :input-processor input-processor
                                                            :form-parameters form-parameters
                                                            :params params)))
      (destructuring-bind (_ item &rest props) form
        (let ((title (rest (assoc :title props)))
              (name (rest (assoc :name props)))
              (type (rest (assoc :type props)))
              (input-processor (or input-processor #'identity))
              (system (getf params :system))
              (branch (getf params :branch)))
          (labels ((build-elem (class item &optional multiple)
                     `(:div :class ,class
                            ,@(if (not title) nil `((:span :class "title" ,title)))
                            ,@(funcall (if (and (listp item) (not multiple))
                                           input-processor #'identity)
                                       (if (and multiple (listp item))
                                           item (list item)))))
                   (build-elems (class item) (build-elem class item t)))
            (case (first type)
              (:set (case (second type)
                      (:form 
                       (print (list :ty type))
                       `(:form :hx-post "/render/"
                               :hx-trigger "reload, submit"
                               :x-data "{'thisForm': $el}"
                               :hx-vals ,(json-convert-to
                                          (list :system (string-upcase system)
                                                :branch (string-upcase branch)))
                               ,(funcall (case (third type)
                                           (:tabular
                                            (lambda (form)
                                              (cons :table
                                                    (loop :for row :in item
                                                          :collect
                                                          (cons :tr (loop :for cell :in row
                                                                          :collect (list :td (htrender
                                                                                              cell
                                                                                              :params
                                                                                              params))))))))
                                           (t #'identity))
                                         item)))
                      ;; (:form (htrender
                      ;;         item :form-parameters :params params
                      ;;         (list :hx-post "/render/"
                      ;;               :hx-vals (json-convert-to
                      ;;                         (list :system (string-upcase system)
                      ;;                               :branch (string-upcase branch))))))
                      (:table (cons :table
                                    (loop :for row :in item
                                          :collect (cons :tr (loop :for cell :in row
                                                                   :collect (list :td (htrender
                                                                                       cell
                                                                                       :params params)))))))))
              (:field (build-elem "ui input" (list :input :type "text"
                                                          :name (symbol-munger:lisp->camel-case name)
                                                          :value item)))
              (:select (case (second type)
                         (:dropdown
                          (let ((title (rest (assoc :title props)))
                                (options (rest (assoc :options props)))
                                (action (rest (assoc :action props))))
                            `(:select :class "ui selection dropdown"
                               :name ,name
                               ,@(if (not (eq action :branch-reload))
                                     nil (list :|x-on:change|
                                               (psl (progn
                                                      (chain console (log this-form))
                                                      (chain htmx (trigger this-form "submit"))))))
                               ,@(loop :for o :in options
                                       :collect `(:option :value ,o
                                                          ,@(if (not (string= o item))
                                                                nil `(:selected 1))
                                                          ,o)))
                            ;; `(:div :class "ui vertical menu"
                            ;;        (:div :class "ui dropdown item"
                            ;;              ,(rest (assoc :title props))
                            ;;              (:i :class "dropdown icon")
                            ;;              (:div :class "menu"
                            ;;                    ,@(loop :for o :in options
                            ;;                            :collect `(:a :class "item" ,o)))))
                            ))))
              (:trigger `(:button :class "ui button" ,title))
              (:boolean `(:button :class "ui button" ,title))
              (:submit-control `(:button :class "ui button" :type "submit" "Submit"))))))))

(defun set-in-element-spec (name form value)
  (if (not (listp form))
      nil (destructuring-bind (_ item &rest props) form
            (let ((this-name (rest (assoc :name props))))
              (if (eql name this-name)
                  (setf (second form) value)
                  (if (listp item)
                      (let ((output))
                        (loop :for i :in item :while (not output)
                              :do (setf output (set-in-element-spec name i value)))
                        output)))))))

(defun meta-revise (form pairs)
  (if (not (listp form))
      nil (if (listp (first form))
              (progn (loop :for f :in form :do (meta-revise f pairs))
                     form)
              (destructuring-bind (_ item &rest props) form
                (let* ((this-name (rest (assoc :name props)))
                       (corresponding (if (not this-name)
                                          nil (rest (assoc this-name pairs))))
                       (process (or (match (rest (assoc :type props))
                                      ((list :field :numeric :integer)
                                       #'parse-number:parse-number))
                                    #'identity)))
                  (if corresponding
                      (setf (second form) (funcall process corresponding))
                      (when (listp item)
                        (loop :for i :in item :do (meta-revise i pairs))))
                  form)))))

(defun from-system-file (system file key &key as-string)
  "Read a form from a file in the manner of a plist (but not requiring a strict key, value structure)."
  (with-open-file (stream (asdf:system-relative-pathname system (format nil "./~a" file))
			  :direction :input)
    (let ((form-start) (form-length))
      (loop :while (not form-start) :for item := (read stream) :while item
            :do (when (and (symbolp item) (eq key item))
                  (setf form-start (file-position stream))))
      (if (not form-start)
          nil (if as-string (when form-start
                              (read stream)
                              (setf form-length (- (file-position stream) form-start))
                              (let ((output (make-string form-length)))
                                (file-position stream form-start)
                                (read-sequence output stream)
                                output))
                  (read stream))))))

(defun (setf from-system-file) (new-value system file key &key as-string)
  "Replace a form from a file in the manner of a plist (but not requiring a strict key, value structure)."
  (let ((form-start) (form-end) (before-bytes) (after-bytes)
        (file-path (format nil "./~a" file)))
    (with-open-file (stream (asdf:system-relative-pathname system file-path)
			    :direction :input)
      (loop :while (not form-start) :for item := (read stream) :while item
            :when (and (symbolp item) (eq key item))
              :do (setf form-start (file-position stream)))
      (when form-start
        (read stream) ;; read the next form, then take the file position
        (setf form-end     (file-position stream)
              before-bytes (make-array form-start :element-type '(unsigned-byte 8))
              after-bytes  (make-array (- (file-length stream) form-end)
                                       :element-type '(unsigned-byte 8)))
        ;; use byte arrays to hold before and after text because using character
        ;; strings causes problems with Unicode character byte alignment
        (with-open-file (bytes (asdf:system-relative-pathname system file-path)
			       :direction :input :element-type '(unsigned-byte 8))
          (read-sequence before-bytes bytes)
          (file-position bytes form-end)
          (read-sequence after-bytes bytes))))
    (if (not after-bytes)
        nil (progn (with-open-file (output (asdf:system-relative-pathname system file-path)
			                   :direction :output :element-type '(unsigned-byte 8)
                                           :if-does-not-exist :create :if-exists :supersede)
                     (write-sequence before-bytes output))
                   (with-open-file (output (asdf:system-relative-pathname system file-path)
                                           :direction :output :if-does-not-exist :create
                                           :if-exists :overwrite)
                     (file-position output form-start)
                     (if as-string (write-string new-value output)
                         (let ((*print-case* :downcase))
                           (write new-value :stream output)
                           (princ #\Newline output)))
                     (setf form-end (file-position output)))
                   (with-open-file (output (asdf:system-relative-pathname system file-path)
			                   :direction :output :element-type '(unsigned-byte 8)
                                           :if-does-not-exist :create :if-exists :overwrite)
                     (file-position output form-end)
                     (write-sequence after-bytes output))
                   new-value))))

;; (defun (setf from-system-file) (new-value system file key &key as-string)
;;   "Replace a form from a file in the manner of a plist (but not requiring a strict key, value structure)."
;;   (let ((form-start) (before-string) (after-string))
;;     (with-open-file (stream (asdf:system-relative-pathname system (format nil "./~a" file))
;; 			    :direction :input)
;;       (loop :while (not form-start) :for item := (read stream) :while item
;;             :do ;; (print (list :ii item (file-position stream)))
;;                 (when (and (symbolp item) (eq key item))
;;                   (setf form-start (file-position stream))))
;;       (when form-start
;;         (read stream)
;;         (setf before-string (make-string form-start)
;;               after-string  (make-string (- (file-length stream)
;;                                             (file-position stream))))
;;         (read-sequence after-string stream)
;;         (file-position stream 0)
;;         (read-sequence before-string stream)))
;;     (if (not after-string)
;;         nil (with-open-file (output (asdf:system-relative-pathname system (format nil "./~a" file))
;;                                     :direction :output :if-does-not-exist :create
;;                                     :if-exists :supersede)
;;               ;; (file-position output form-start)
;;               ;; (print (list :bfs before-string))
;;               ;; (loop :for i :below before-string :for byte := (read-byte stream)
;;               ;;       :do (write-byte byte output))
              
;;               (write-string before-string output)
;;               (if as-string (write-string new-value output)
;;                   (let ((*print-case* :downcase))
;;                     (write new-value :stream output)
;;                     (princ #\Newline output)))
;;               (write-string after-string output)
;;               ;; (file-position stream (+ after-string ...))
;;               ;; (loop :for byte := (read-byte stream) :while byte
;;               ;;       :do (write-byte byte output))
;;               new-value))))

(defmacro defvar-value (form)
  `(third ,form))

(defmacro of-array-spec (key spec)
  (if (eq :shape key) `(second ,spec)
      `(getf (cddr ,spec) ,key)))

(defun text-wrap (text &key syntax unwrap (trailing-newlines 1))
  (case syntax
    (:progn (if unwrap (let ((first-break) (end-point) (tnl-count 0))
                         (loop :for c :across text :for cx :from 0 :while (not first-break)
                               :when (member c '(#\Newline #\Return) :test #'char=)
                                 :do (setf first-break (1+ cx)))
                         (loop :for cx :from (1- (length text)) :downto 0 :while (not end-point)
                               :when (member (aref text cx) '(#\Newline #\Return) :test #'char=)
                                 :do (when (= trailing-newlines (incf tnl-count))
                                       (setf end-point cx)))
                         (subseq text first-break end-point))
                (format nil "(progn~%~a)~%" text)))))

(defun set-in-system-file (new-value system file key)
  "Replace a form from a file in the manner of a plist (but not requiring a strict key, value structure)."
  (let ((form-start) (before-string) (after-string))
    (with-open-file (stream (asdf:system-relative-pathname system (format nil "./~a" file))
			    :direction :input)
      (loop :while (not form-start) :for item := (read stream) :while item
            :do (when (and (symbolp item) (eq key item))
                  (setf form-start (file-position stream))))
      (when form-start
        (read stream)
        (setf before-string (make-string form-start)
              after-string  (make-string (- (file-length stream)
                                            (file-position stream))))
        (read-sequence after-string stream)
        (file-position stream 0)
        (read-sequence before-string stream)))
    (if (not after-string)
        nil (with-open-file (output (asdf:system-relative-pathname system (format nil "./~a" file))
                                    :direction :output :if-does-not-exist :create
                                    :if-exists :supersede)
              ;; (file-position output form-start)
              (write-string before-string output)
              (let ((*print-case* :downcase))
                (write new-value :stream output)
                (princ #\Newline output))
              (write-string after-string output)
              new-value))))

;; (defmacro build-directed-graph (&rest nodes)
;;   (let ((n (gensym)) (link (gensym)) (nodes-out (gensym)))
;;     `(let ((,nodes-out (list ,@(loop :for node :in nodes
;;                                      :collect (list 'list (cons 'list (mapcar (lambda (i) (cons 'list i))
;;                                                                               (first node)))
;;                                                     `(list (list ,@(mapcar (lambda (i) (cons 'list i))
;;                                                                            (cdadr node)))
;;                                                            ,(caadr node))
;;                                                     )))))
;;        (loop :for ,n :in ,nodes-out
;;              :do (loop :for ,link :in (rest ,n)
;;                        :do (rplacd ,link (nth (second ,link) ,nodes-out))))
;;        ,nodes-out)))

(defmacro build-directed-graph2 (&rest nodes)
  (let ((n (gensym)) (link (gensym)) (nodes-out (gensym)))
    `(let ((,nodes-out (list ,@(loop :for node :in nodes
                                     :collect (list 'list (cons 'list (mapcar (lambda (i) (cons 'list i))
                                                                              (first node)))
                                                    `(list (list ,@(mapcar (lambda (i) (cons 'list i))
                                                                           (caadr node)))
                                                           ,(cadadr node)))))))
       (loop :for ,n :in ,nodes-out
             :do (loop :for ,link :in (rest ,n)
                       :do (rplacd ,link (list (nth (second ,link) ,nodes-out)))))
       ,nodes-out)))

;; '(build-directed-graph
;;  (((:title "First node."))
;;   (1 (:title "Link to second node.")))
;;  (((:title "Second node."))
;;   (2 (:title "Link to third node.")))
;;  (((:title "Third node."))
;;   (0 (:title "Link to first node.")))
;;  )

'(build-directed-graph2
 (((:title "First node."))
  (((:title "Link to second node."))
   1))
 (((:title "Second node."))
  (((:title "Link to third node."))
   2))
 (((:title "Third node."))
  (((:title "Link to first node."))
   0))
 )

;; (defun dgraph-interface (dgraph &optional interface &key (depth 0) open-path)
;;   (print (list :dd interface))
;;   (if (not interface)
;;       (loop :for item :in dgraph :collect (cons (first item)
;;                                                 (if (not (second item))
;;                                                     nil (loop :for link :in (rest item)
;;                                                               :collect :closed))))
;;       (if (not open-path)
;;           interface (destructuring-bind (open-index &rest rest-indices) open-path
;;                       (print interface)
;;                       (if rest-indices
;;                           (dgraph-interface (nth open-index (if (zerop depth)
;;                                                                 dgraph (rest dgraph)))
;;                                             (nth open-index (if (zerop depth)
;;                                                                 interface (rest interface)))
;;                                             :depth (1+ depth) :open-path rest-indices)
;;                           (setf (nth open-index (rest interface))
;;                                 (let ((target (nth open-index (print (rest dgraph)))))
;;                                   (print (list :tg (first target)))
;;                                   (append (list (first target)
;;                                                 (if (second target) :closed nil)))))
;;                           )
;;                       interface))))

;; (defun dgraph-interface (dgraph &optional interface &key (depth 0) open-path)
;;   (print (list :dd interface))
;;   (if (not interface)
;;       (loop :for item :in dgraph :collect (cons (first item)
;;                                                 (if (not (second item))
;;                                                     nil (loop :for link :in (rest item)
;;                                                               :collect :closed))))
;;       (if (not open-path)
;;           interface (destructuring-bind (open-index &rest rest-indices) open-path
;;                       (print interface)
;;                       (if (rest rest-indices)
;;                           (dgraph-interface (nth open-index (if (zerop depth)
;;                                                                 dgraph (rest dgraph)))
;;                                             (nth open-index (if (zerop depth)
;;                                                                 interface (rest interface)))
;;                                             :depth (1+ depth) :open-path rest-indices)
;;                           (let* ((last-index (first rest-indices))
;;                                  (target (nth last-index (rest (nth open-index (rest dgraph))))))
;;                             (print (list :nx last-index (nth open-index (rest interface))
;;                                          (nth last-index (rest (nth open-index (rest interface))))
;;                                          :ft (first target) target
;;                                          ))
;;                             (setf (nth last-index (rest (nth open-index (rest interface))))
;;                                   (append (list (first target)
;;                                                 (if (second target) :closed nil))))
;;                             ;; (setf (nth open-index (rest interface))
;;                             ;;       (let ((target (nth open-index (print (rest dgraph)))))
;;                             ;;         (print (list :tg (first target)))
;;                             ;;         (append (list (first target)
;;                             ;;                     (if (second target) :closed nil)))))
;;                             ))
;;                       interface))))

(defun dgraph-interface (dgraph &optional interface &key (depth 0) path to-open)
  (if (not interface)
      (loop :for item :in dgraph :collect (cons (first item)
                                                (if (not (second item))
                                                    nil (loop :for link :in (rest item)
                                                              :collect :closed))))
      (if (not path)
          interface (let ((dgraph (if (zerop depth) (cons :head dgraph) dgraph))
                          (interface (if (zerop depth) (cons :head interface) interface)))
                      (destructuring-bind (open-index &rest rest-indices) path
                        ;; (print (list :in interface))
                        (if (rest rest-indices)
                            (dgraph-interface (nth open-index (rest dgraph))
                                              (nth open-index (rest interface))
                                              :depth (1+ depth) :path rest-indices :to-open to-open)
                            (let* ((last-index (first rest-indices))
                                   (target (nth last-index (rest (nth open-index (rest dgraph))))))
                              ;; (print (list :nx last-index (nth open-index (rest interface))
                              ;;              (nth last-index (rest (nth open-index (rest interface))))
                              ;;              :ft (first target) ; target
                              ;;              ))
                              
                              (setf (nth last-index (rest (nth open-index (rest interface))))
                                    (if to-open (append (list (first target)
                                                              (if (second target) :closed nil)))
                                        :closed))
                              ))
                        (if (zerop depth) (rest interface)
                            interface))))))

(let ((x-start 10) (y-start 30) (x-increment 40) (y-increment 40))
  (defun svrender-graph (gmodel &key x-offset y-offset parent (path-string "")
                                  (expand-control-format #'identity)
                                  (contract-control-format #'identity))
    (let ((y-offset (or y-offset y-start)) (x-offset (or x-offset x-start))
          (radius 20) (output) (link-specs))
      (loop :for item :in gmodel :for ix :from 0 :when (listp item)
            :do (let ((is-expandable (second item))
                      (path-string (if (zerop (length path-string))
                                       (format nil "~a 0 " ix)
                                       (format nil "~a ~a " path-string ix))))
                  (push `(:g :class "node-group"
                             :transform ,(format nil "translate(~a,~a)" x-offset y-offset)
                             (:g :class "title-frame"
                                 :transform ,(format nil "translate(36,-12)")
                                 (:rect :x 0 :y 0 :fill "#efefef" :height 24 :width 200 :rx 12)
                                 (:g :class "description"
                                     (:text :class "title" :y 16 :x ,(if is-expandable 26 6)
                                            ,(second (assoc :title (first item))))))
                             (:g :class "circle-glyph"
                                 (:circle :class "outer-circle" :cx 16 :cy 0 :r 16)
                                 (:circle :class "inner-circle" :cx 16 :cy 0 :r 12))
                             ,@(if (not is-expandable)
                                   nil (list (funcall
                                              (if (eq :closed is-expandable)
                                                  expand-control-format contract-control-format)
                                              `(:g :class "expand-control" :path ,path-string
                                                   (:circle :class "button-backing" :cx 48 :cy 0 :r 10)
                                                   (:circle :class "button-circle"  :cx 48 :cy 0 :r 8)
                                                   (:rect :class "indicator" :x 43.5 :y -1
                                                          :height 3 :width 9)
                                                   ,@(if (not (eq :closed is-expandable))
                                                         nil `((:rect :class "indicator" :x 46.5 :y -4
                                                                      :height 9 :width 3))))))))
                        output)
                  
                  (when parent (destructuring-bind (parent-x parent-y) parent
                                 (let ((mid-x (+ parent-x (* 0.5 (- x-offset parent-x)))))
                                   (push `(:path :class "link"
                                                 :d ,(format nil "M~a,~aC~a,~a,~a,~a,~a,~a"
                                                             parent-x parent-y mid-x parent-y
                                                             mid-x y-offset x-offset y-offset))
                                         link-specs))))
                  (if (rest item)
                      (multiple-value-bind (out-list new-y-offset new-link-specs)
                          (svrender-graph
                           (rest item) :x-offset (+ x-increment x-offset)
                                       :y-offset (+ y-increment y-offset)
                           :path-string path-string :parent (list x-offset y-offset)
                           :expand-control-format expand-control-format
                           :contract-control-format contract-control-format)
                        (setf output (append out-list output)
                              link-specs (append new-link-specs link-specs)
                              y-offset new-y-offset))
                      (incf y-offset y-increment))))
      (values (if (zerop (length path-string))
                  ;; link specs are appended at the final stage, the reversal causes
                  ;; them to be drawn first so they'll be underneath the node graphics
                  (reverse (append output link-specs))
                  output)
              y-offset link-specs))))

;; (dgraph-interface iii bla :open-path '(0 0))
;; (dgraph-interface iii bla :open-path '(1 0 0))

(defun of-graph-spec (spec &optional index)
  (labels ((alist-to-plist (form)
             (loop :for item :in form
                   :append (list (first item)
                                 (if (not (third item))
                                     (second item) (rest item)))))
           (listing-format (form)
             (append (alist-to-plist (first form))
                     (list :children (loop :for link :in (rest form)
                                           :collect (append (alist-to-plist (first link))
                                                            (list :to (second link))))))))
    (if index (listing-format (nth index (rest spec)))
        (list :title "root" 
              :children (mapcar #'listing-format (rest spec))))))

(defun graph-spec-to-json (spec &optional index)
  (let ((stream (make-string-output-stream)))
    (flet ((listing-format (form)
             (com.inuoe.jzon:with-object*
               (com.inuoe.jzon:write-key* :data)
               (alist-to-json (first form) stream)
               (com.inuoe.jzon:write-key* :children)
               (com.inuoe.jzon:with-array*
                 (loop :for link :in (rest form)
                       :do (com.inuoe.jzon:with-object*
                             (com.inuoe.jzon:write-key* :data)
                             (alist-to-json (rest link) stream)
                             (com.inuoe.jzon:write-key* :to)
                             (com.inuoe.jzon:write-value* (first link))))))))
      (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
        (if index (listing-format (nth index (rest spec)))
            (com.inuoe.jzon:with-object*
              (com.inuoe.jzon:write-key* :data)
              (alist-to-json '((:title "root")) stream)
              (com.inuoe.jzon:write-key* :children)
              (com.inuoe.jzon:with-array*
                (mapcar #'listing-format (rest spec))))))
      (get-output-stream-string stream))))

;; (defun alist-to-json (form &optional stream)
;;   (let ((stream (or stream (make-string-output-stream))))
;;     ;; (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
;;       (com.inuoe.jzon:with-object*
;;         (loop :for item :in form
;;               :do (com.inuoe.jzon:write-key* (symbol-munger:lisp->camel-case (first item)))
;;                   (if (not (third item))
;;                       (if (symbolp (third item))
;;                           (com.inuoe.jzon:write-value*
;;                            (symbol-munger:lisp->camel-case (second item)))
;;                           (com.inuoe.jzon:write-value* (second item)))
;;                       (com.inuoe.jzon:with-array*
;;                         (loop :for property :in (rest item)
;;                               :do (if (symbolp property)
;;                                       (com.inuoe.jzon:write-value*
;;                                        (symbol-munger:lisp->camel-case property))
;;                                       (com.inuoe.jzon:write-value* property)))))))
;;     (unless stream (get-output-stream-string stream))
;;     ))

;; (define-setf-expander from-system-file (system file &environment env)
;;   "Set the last element in a list to the given value."
;;   (multiple-value-bind (dummies vals newval setter getter)
;;       (get-setf-expansion x env)
;;     (let ((store (gensym)))
;;       (values dummies
;;               vals
;;               `(,store)
;;               `(progn (set-in-system-file ,store ,system ,getter) ,store)
;;               `(lastguy ,getter)))))

;; (defun as-defvar (symbol form)
;;   (print (list :eee form))
;;   (if (not (and (eq 'defvar (first form))
;;                 (string= (string symbol)
;;                          (string (second form)))))
;;       nil (third form)))

;; (defun (setf as-defvar) (new-value symbol form)
;;   (print (list :nv new-value symbol form))
;;   (if (not (and (eq 'defvar (first form))
;;                 (string= (string symbol)
;;                          (string (second form)))))
;;       nil (progn (setf (third form) new-value)
;;                  form)))

;; (define-setf-expander as-defvar (symbol form &environment env)
;;   "Set the last element in a list to the given value."
;;   (multiple-value-bind (dummies vals newval setter getter)
;;       (get-setf-expansion ay env)
;;     (let ((store (gensym)))
;;       (values dummies vals
;;               `(,store)
;;               `(if (print (not (and (eq 'defvar (first ,getter))
;;                              (string= (string ,symbol)
;;                                       (string (second ,getter))))))
;;                    nil (progn (rplaca (last ,getter) ,store) (print ,getter)))
;;               `(as-defvar ,symbol ,getter)))))

;; (defun of-array-spec (spec property)
;;   (destructuring-bind (_ shape &rest props) spec
;;     (case property
;;       (:shape shape)
;;       (t (getf spec property)))))

;; (defun (setf of-array-spec) (new-value spec property)
;;   (print (list :ss new-value spec property))
;;   (destructuring-bind (call shape &rest props) spec
;;     (case property
;;       (:shape (setf (second spec) new-value))
;;       (t (setf (getf (cddr spec) property) new-value)))
;;     spec))

;; (define-setf-expander of-array-spec (spec property &environment env)
;;   "Set the last element in a list to the given value."
;;   (multiple-value-bind (dummies vals newval setter getter)
;;       (get-setf-expansion spec env)
;;     (let ((store (gensym)))
;;       (values dummies vals
;;               `(,store)
;;               `(progn (case ,property
;;                         (:shape (setf (second ,getter) ,store))
;;                         (t (setf (getf (cddr ,getter) ,property) ,store)))
;;                       (print ,getter))
;;               `(of-array-spec ,getter ,store)))))

;;  (define-setf-expander of-array-spec (spec property &environment env)
;;    (multiple-value-bind (temps vals stores
;;                           store-form access-form)
;;        (get-setf-expansion property env);Get setf expansion for int.
;;      (let ((ktemp (gensym))     ;Temp var for byte specifier.
;;            (store (gensym))     ;Temp var for byte to store.
;;            (stemp (first stores))) ;Temp var for int to store.
;;        ;; (print (list :sto stores))
;;        ;;; Return the setf expansion for LDB as five values.
;;        (values (cons ktemp temps)       ;Temporary variables.
;;                (cons spec vals)     ;Value forms.
;;                (list store)             ;Store variables.
;;                `(let ((,stemp (case ,property
;;                                 (:shape (setf (second ,access-form) ,store))
;;                                 (t (setf (getf (cddr ,store-form) ,access-form) ,store)))))
;;                   ,store-form
;;                   ,store)               ;Storing form.
;;                `(of-array-spec ,access-form ,store) ;Accessing form.
;;                ))))

;;  (define-setf-expander ldb (bytespec int &environment env)
;;    (multiple-value-bind (temps vals stores
;;                           store-form access-form)
;;        (get-setf-expansion int env);Get setf expansion for int.
;;      (let ((btemp (gensym))     ;Temp var for byte specifier.
;;            (store (gensym))     ;Temp var for byte to store.
;;            (stemp (first stores))) ;Temp var for int to store.
;;        (if (cdr stores) (error "Can't expand this."))
;; ;;; Return the setf expansion for LDB as five values.
;;        (values (cons btemp temps)       ;Temporary variables.
;;                (cons bytespec vals)     ;Value forms.
;;                (list store)             ;Store variables.
;;                `(let ((,stemp (dpb ,store ,btemp ,access-form)))
;;                   ,store-form
;;                   ,store)               ;Storing form.
;;                `(ldb ,btemp ,access-form) ;Accessing form.
;;               ))))


;; (defun lastguy (x) (car (last x)))

;; (define-setf-expander lastguy (x &environment env)
;;   "Set the last element in a list to the given value."
;;   (multiple-value-bind (dummies vals newval setter getter)
;;       (get-setf-expansion x env)
;;     (let ((store (gensym)))
;;       (values dummies
;;               vals
;;               `(,store)
;;               `(progn (rplaca (last ,getter) ,store) ,store)
;;               `(lastguy ,getter)))))

;; (defun from-system-file (system file key)
;;   (let ((form (uiop:read-file-form (asdf:system-relative-pathname system (format nil "./~a" file))
;;                                    :at nil)))
;;     ;; note: assumes that everything after the (in-package ...) form is a plist
;;     (getf (rest form) key)))

;; (defun (setf from-system-file) (new-value system file key)
;;   (let ((*print-case* :downcase)
;;         (form (uiop:read-file-form (asdf:system-relative-pathname system (format nil "./~a" file))
;;                                    :at nil)))
;;     ;; note: assumes that everything after the (in-package ...) form is a plist
;;     (setf (getf (rest form) key) new-value)
;;     (with-open-file (stream (asdf:system-relative-pathname system (format nil "./~a" file))
;; 			    :direction :output :if-exists :supersede :if-does-not-exist :create)
;;       (loop :for item :in form :do (print item stream)))))

#|

Process: get view
Display view of system, may have elements pulling from other branches
Portal functions reside in seed system
Portal-linked system functions reside in the portal system

Basic interaction:
(interact (getf *seed-interfaces* :portal.demo1) :systems)

|#
