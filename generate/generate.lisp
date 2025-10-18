;;;; generate.lisp

(in-package #:seed.generate)

;; SECTION: base macros for Seed systems

(defun load-system-directory (directory-path &optional callback)
  (let ((package-out))
    (loop :for f :in (uiop:directory-files directory-path) :until package-out
          :when (and (string= "SEED" (string-upcase (pathname-name f)))
                     (string= "LISP" (string-upcase (pathname-type f))))
            :do (with-open-file (stream f :direction :input)
                  (setf package-out (eval (read stream nil)))
                  (load f)))
    (when package-out (multiple-value-bind (systems root-name)
                          (funcall (symbol-function (intern "SYSTEMS" (package-name package-out))))
                        (and (funcall callback (getf systems root-name) root-name))))))

(defun chain-fns (fns)
  (if (rest fns)
      (let ((context (gensym)) (input (gensym)))
        `(lambda (,context ,input)
           (-<> ,input ,@(loop :for item :in fns :collect `(funcall ,item ,context <>)))))
      (first fns)))

(defun channel-fns (syname brname fns)
  (let ((state (gensym (string-upcase syname))) (data (gensym (string-upcase brname)))
        (final (gensym)) (output (gensym)) (final-out (gensym)))
    (if (rest fns)
        `(lambda (,state ,data)
           (let ((,final))
             ,@(loop :for fn :in fns :for fix :from (1- (length fns)) :downto 0
                     :collect `(multiple-value-bind (,output ,final-out)
                                   (if ,final (values ,data ,final) (funcall ,fn ,state ,data))
                                 (setf ,data  ,output
                                       ;; ,data  ,(if (zerop fix)
                                       ;;             output (list 'or output data))
                                       ,final ,final-out)))
             ,data))
        (first fns))))

(defmacro seed (name &body props)
  (let* ((access    (rest (assoc :access props)))
         (contacts  (rest (assoc :contacts props)))
         (config    (rest (assoc :config  props)))
         (linking   (rest (assoc :linking props)))
         (grow      (and access (getf access :to-grow)))
         (systems   (and access (getf access :systems)))
         (ctaccess  (and access (getf access :ctaccess)))
         (staccess  (and access (getf access :staccess)))
         (of-system (and access (getf access :of-system)))
         (pname     (string name))
         (defbranch (and access (intern "DEFBRANCH" pname)))
         (expand-regardless (member :expand-regardless config))
         (branches (gensym "BR")) (system (gensym "SY")) (key (gensym "KY"))
         (values (gensym "VL")) (session (gensym "SS")) (input (gensym "IN"))
         (item (gensym "IT")) (portal-state (gensym "PR")) (params (gensym "PA")))
    `(progn ,@(and staccess (destructuring-bind (st-sym &rest of-sym) staccess
                              (and (or expand-regardless (not (fboundp of-sym)))
                                   `((eval-when (:compile-toplevel :load-toplevel :execute)
                                       (setf (macro-function ',of-sym)
                                             (lambda (form env)
                                               (destructuring-bind (_ &rest ,params) form
                                                 (declare (ignore _))
                                                 (when (eq :- (first ,params))
                                                   (setf (first ,params) ,(or linking name)))
                                                 (cons 'funcall (cons ',st-sym ,params))))))))))
            ,@(when access
                `((let ((,portal-state (list :point nil :template-point nil
                                             ,@(and contacts `(:contacts ,(cons 'list contacts)))
                                             ,@(and config   `(:config   ,(cons 'list config)))))
                        (,branches (list ,(or linking name) nil)))
                    ,@(and access `((proclaim '(special ,grow ,@(and of-system '(of-system))
                                                ,defbranch))))
                    (eval-when (:compile-toplevel :load-toplevel :execute)
                      (setf (symbol-function ',defbranch)
                            (lambda (,key &optional ,input)
                              (let ((,system ,(or linking name)))
                                (if (member ,system ,branches)
                                    (if ,input (setf (getf (getf ,branches ,system) ,key) ,input)
                                        (getf (getf ,branches ,system) ,key))
                                    (error "Attempting to add a branch to an undefined system."))))
                            ,@(and of-system (or expand-regardless (not (fboundp of-system)))
                                   `((symbol-function ',of-system)
                                     (lambda (,key &optional ,input)
                                       (if ,input (setf (getf ,portal-state ,key) ,input)
                                           (getf ,portal-state ,key)))))
                            ,@(and grow (or expand-regardless (not (fboundp grow)))
                                   `((symbol-function ',grow)
                                     (lambda (,system ,key &optional ,session ,input)
                                       (unless ,key
                                         (error "Warning: attempt to grow system ~a without a specified branch."
                                                ,system))
                                       (funcall (getf (getf ,branches (or ,system ,(or linking name))) ,key)
                                                ,session ,input))))
                            ,@(and systems (or expand-regardless (not (fboundp systems)))
                                   `((symbol-function ',systems)
                                     (lambda () (values ,branches ,(or linking name)))))
                            ,@(and ctaccess
                                   (destructuring-bind (ct-sym &rest of-sym) ctaccess
                                     (and (or expand-regardless (not (fboundp of-sym)))
                                          `((symbol-function ',of-sym)
                                            (lambda (&rest ,key)
                                              (dolist (,item ,ct-sym)
                                                (and (or (not ,key) (member ,item ,key))
                                                     (load-system-directory
                                                      (asdf:system-relative-pathname ,item "./")
                                                      (lambda (,input ,key)
                                                        (setf (getf ,branches ,key) ,input))))))))))))))))))

(defmacro branch (key &body input)
  (list (intern "DEFBRANCH" (package-name *package*))
        key (channel-fns (symbol-value (intern "*SYSTEM*" (package-name *package*)))
                         key input)))

(defun in-system-context (spec system-name)
  (append (list (first spec) (second spec))
          (cons (cons :system system-name) (cddr spec))))

(defun interact (portal branch &optional session-api input)
  (funcall (getf (getf portal :branches) branch)
           session-api input))

(defun with (item &rest props) ;; obsolete
  (append (list :props item) props))

(defun with-meta (item &rest props)
  `(fx ,item ,@props))

(defun build-key-path (value keys)
  (if (rest keys) (list (first keys) (build-key-path value (rest keys)))
      (list (first keys) value)))

(defmacro abind (type keys alist &rest body)
  (let ((alist-sym (gensym)))
    `(let* ((,alist-sym ,alist)
            ,@(loop :for key :in keys
                    :collect (list key `(rest (assoc ,(string (camel-case->lisp-name key)) ,alist-sym
                                                     ,@(case type (:string '(:test #'string=))))))))
       ,@body)))

(defmacro cbind (input item &body clauses)
  ;; TODO: OPTIMIZE, ELIMINATE REDUNDANCY
  `(cond ,@(loop :for c :in clauses
                 :collect (if (eq 't (first c))
                              `(t ,@(rest c))
                              `((assoc ,(first c) ,input :test #'string=)
                                (let ((,item (assoc ,(first c) ,input :test #'string=)))
                                  ,@(rest c)))))))

;; SECTION: data processing functions

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

(defun json-convert-to (form &optional stream)
  (let ((initial (not stream))
        (stream (or stream (make-string-output-stream))))
    ;; (print (list :in initial))
    (if initial (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
                  (json-convert-to form stream)
                  (get-output-stream-string stream))
        (if (not (listp form))
            (if (and (arrayp form) (not (stringp form)))
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

(defmacro astr (key form)
  (let ((key-string (if (stringp key)
                        key (lisp->camel-case key))))
    `(rest (assoc ,key-string ,form :test #'string=))))

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

;; SECTION: basic system interaction tools

(defun adapt-from-alist (&rest properties)
  (lambda (state input)
    (declare (ignore state))
    (if (not (and (listp input) (listp (first input))))
        input (let ((output)
                    (to-port (or (and (keywordp (caar input))
                                      #'identity)
                                 (and (stringp (caar input))
                                      (lambda (i) (intern (string-upcase (camel-case->lisp-name i))
                                                          "KEYWORD"))))))
                (dolist (pair input)
                  (let ((formatted (funcall to-port (first pair))))
                    (when (member formatted properties)
                      (setf (getf output formatted) (rest pair)))))
                output))))

(defun adapt-from-json (&rest properties)
  (let ((strings (mapcar #'lisp->camel-case properties)))
    (lambda (state input)
      (declare (ignore state))
      (if (not (stringp input))
          input (jonathan:parse input :as :plist :normalize-all t :keyword-normalizer
                                (lambda (in) (and (member in strings :test #'string=)
                                                  (string-upcase (camel-case->lisp-name in)))))))))

(defun syspath (system path)
  (asdf:system-relative-pathname system (format nil "./~a" path)))

(defun file-to-string (path)
  (with-open-file (stream path) (let ((contents (make-string (file-length stream))))
                                  (read-sequence contents stream)
                                  contents)))

(defun system-file-to-string (system file)
  (with-open-file (stream (if (eq :absolute (first (pathname-directory (pathname file))))
                              (pathname file)
                              (asdf:system-relative-pathname system (format nil "./~a" file))))
    (let ((contents (make-string (file-length stream))))
      (read-sequence contents stream)
      contents)))

(defun from-system-file (system file key &key as-string)
  "Read a form from a file in the manner of a plist (but not requiring a strict key, value structure)."
  (with-open-file (stream (if (eq :absolute (first (pathname-directory (pathname file))))
                              (pathname file)
                              (asdf:system-relative-pathname system (format nil "./~a" file)))
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
        ;; (file-path (format nil "./~a" file))
        (file-path (if (eq :absolute (first (pathname-directory (pathname file))))
                       (pathname file)
                       (asdf:system-relative-pathname system (format nil "./~a" file)))))
    (with-open-file (stream file-path :direction :input)
      (loop :while (not form-start) :for item := (read stream) :while item
            :when  (and (symbolp item) (eq key item))
              :do  (setf form-start (file-position stream)))
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
        nil (progn (with-open-file (output file-path :direction :output :element-type '(unsigned-byte 8)
                                           :if-does-not-exist :create :if-exists :supersede)
                     (write-sequence before-bytes output))
                   (with-open-file (output file-path :direction :output :if-does-not-exist :create
                                           :if-exists :overwrite)
                     (file-position output form-start)
                     (if as-string (write-string new-value output)
                         (let ((*print-case* :downcase))
                           (write new-value :stream output)
                           (princ #\Newline output)))
                     (setf form-end (file-position output)))
                   (with-open-file (output file-path :direction :output :element-type '(unsigned-byte 8)
                                           :if-does-not-exist :create :if-exists :overwrite)
                     (file-position output form-end)
                     (write-sequence after-bytes output))
                   new-value))))

(defun at-path (path function &optional data)
  (if (rest path) (at-path (rest path) function (nth (first path) data))
      (funcall function (first path) data)))

(defun seek-key (form key)
  (let ((to-return))
    (loop :for item :in form :for i :from 0 :until to-return
          :do (if (listp item)
                  (let ((next (seek-key item key)))
                    (when next (setf to-return (cons i next))))
                  (when (eq key item) (setf to-return (list i)))))
    to-return))

(defun set-key (form value path)
  (if (rest path) (set-key (nth (first path) form) value (rest path))
      (setf (nth (first path) form) value)))

(defun build-templater (form &rest keys)
  (let ((paths) (assigners))
    (dolist (key keys)
      (setf (getf paths key) (seek-key form key)))
    (lambda (&rest pairs)
      (let ((output (copy-tree form)))
        (loop :for (key value) :on pairs :by #'cddr
              :do (set-key output value (getf paths key)))
        output))))

(defun get-template-metadata (path)
  "Read metadata from a Seed system template."
  (let ((template-name) (description))
    (with-open-file (instream (concatenate 'string (enough-namestring path) "/system.asd"))
      (loop :until template-name
            :do (let ((this-line (read-line instream)))
                  ;; it's expected that Seed templates have a commented data block starting with
                  ;; the text ";;; Seed template: " followed by the name of the template. The 
                  ;; following lines contain other pieces of metadata including a template description.
                  (when (and (< 19 (length this-line))
                             (string= ";;; Seed template: " (subseq this-line 0 19)))
                    (setf template-name (subseq this-line 19)
                          this-line     (read-line instream)
                          description   (subseq this-line 4)))))
      (values template-name description))))

(defun clone-system (name path template &rest params)
  "Clone a system from one of the Seed installation's collected templates."
  (quickproject:make-project path :template-directory (asdf:system-relative-pathname template "./")
                                  :name name :template-parameters params))

(defmacro psl (form)
  "A macro for denoting inline Parenscript code."
  `(subseq (parenscript:ps-inline ,form) 11))

;; SECTION: building block functions for rendering HTML interfaces

(defun branch-spec-cvdatagrid-tree (stream-out section &rest props)
  (let ((token (format nil "canvas-datagrid-~a-~a"
                       (string-downcase (getf props :system))
                       (string-downcase (getf props :branch))))
        (branch (string-downcase (getf props :branch)))
        (mode (getf props :mode)))
    (case section
      (:body (cl-who:with-html-output (stream-out)
               (:div :id "datagrid-tree" :class (getf props :item-classes)
                     :x-init ;; TODO: add branch push here
                     (psl (fetch-contact ;; TODO: update
                           $el props ;; (lisp (string-upcase (getf props :system)))
                           ;; (lisp (string-upcase (getf props :branch)))
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
                           (psl (fetch-contact $el props ;; (lisp (string-upcase (getf props :system)))
                                               ;; (lisp (string-upcase (getf props :branch)))
                                               (@ (getprop (@ window seed-data) (lisp token))
                                                  data)
                                               (lambda (data) (chain console (log :sv)))))
                           (str (string-downcase (getf props :subsection)))))))))))

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

(defmacro build-directed-graph (&rest nodes)
  (let ((n (gensym)) (link (gensym)) (nodes-out (gensym)))
    (labels ((inline-list (list)
               (cons 'list (loop :for item :in list
                                 :collect (if (listp item)
                                              (if (listp (rest item))
                                                  (inline-list item)
                                                  (list 'cons (first item) (rest item)))
                                              item)))))
      `(let ((,nodes-out (list ,@(loop :for node :in nodes
                                       :collect (cons 'list ;; (cons 'list (mapcar (lambda (i)
                                                            ;;                       (print (list :ii i))
                                                            ;;                       (if (listp (rest i))
                                                            ;;                           (cons 'list i)
                                                            ;;                           (list 'cons (first i)
                                                            ;;                                 (rest i))))
                                                            ;;                     (first node)))
                                                      (cons (inline-list (first node))
                                                            (loop :for item :in (rest node) :when (second item)
                                                               :collect `(list ,(inline-list (first item)) ,(second item)))
                                                            ;; (mapcar (lambda (item)
                                                            ;;           `(list ,(inline-list (first item)) ,(second item)))
                                                            ;;         (rest node))
                                                            )
                                                      ;; `(list ;; (list ,@(mapcar (lambda (i)
                                                      ;;        ;;                   (if (listp (rest i))
                                                      ;;        ;;                       (cons 'list i)
                                                      ;;        ;;                       (list 'cons (first i)
                                                      ;;        ;;                             (rest i))))
                                                      ;;        ;;                 (caadr node)))
                                                      ;;        ,(inline-list (caadr node))
                                                      ;;        ,(cadadr node))
                                                      )))))
         (loop :for ,n :in ,nodes-out
               :do (loop :for ,link :in (rest ,n)
                         :do (rplacd ,link (list (nth (second ,link) ,nodes-out)))))
         ,nodes-out))))

(defmacro setf-value (form)
  `(third ,form))

(defmacro of-array-spec (key spec)
  (if (eq :shape key) `(second ,spec)
      `(getf (cddr ,spec) ,key)))

(defvar *giface-output-stream*)

(defun graph-walker (graph)
  (let ((primary (first graph))
        (options (mapcar #'first (rest graph))))
    (values (list primary options)
            (lambda (index) (graph-walker (second (nth index (rest graph))))))))

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

#|

Process: get view
Display view of system, may have elements pulling from other branches
Portal functions reside in seed system
Portal-linked system functions reside in the portal system

Basic interaction:
(interact (getf *seed-interfaces* :portal.demo1) :systems)

|#
