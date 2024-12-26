;;;; generate.lisp

(in-package #:seed.generate)

;; SECTION: base macros for Seed systems

(defun load-system-directory (directory-path)
  (flet ((check-name (file)
           (string= "SEED" (string-upcase (first (last (cl-ppcre:split "[.]" (namestring file))))))))
    (let ((files (uiop:directory-files directory-path)))
      ;; (print (list :ld *package*))
      (loop :for f :in files :when (check-name f)
            :do (with-open-file (input f)
                  (loop :for i := (read input nil) :while i :do (eval i)))))))

(defmacro seed (name &rest props)
  (let* ((branches (rest (assoc :branches props)))
         (bind (rest (assoc :bind props)))
         (contact-names (rest (assoc :contacts props)))
         (joiner (rest (assoc :joiner props)))
         (contactor (rest (assoc :contactor props)))
         (contacts-api (rest (assoc :contacts-api props)))
         (grow (intern (string (getf bind :to-grow)) (package-name *package*)))
         (of-system (intern (string (getf bind :of-system)) (package-name *package*)))
         (context (gensym "CON")) (channel (gensym "CHN")) (branches-sym (gensym "BRS"))
         (system (gensym "SY")) (key (gensym "KY")) (session (gensym "SS"))
         (input (gensym "IN")) (prsym (gensym "PR")))
    ;; (print contacts)
    `(let ,(append (list (loop :for (key value) :on bind :by #'cddr
                               :append (case key (:package (list value `(find-package ,name))))))
                   `((,prsym (list :point nil ,@(if contact-names
                                                    `(:contacts ,(cons 'list contact-names)))))))
       ,@(if joiner nil `((proclaim '(special ,grow))))
       ,@(loop :for contact-sym :in contact-names
               :collect `(load-system-directory (asdf:system-relative-pathname ,contact-sym "./")))
       (flet ((,of-system (,key &optional ,input)
                (if ,input (setf (getf ,prsym ,key) ,input)
                    (getf ,prsym ,key))))
         (let ((,branches-sym ,(cons 'list branches)))
           ,(if joiner `(funcall ,joiner ,name (lambda (,system ,key &optional ,session ,input)
                                                 (funcall (getf ,branches-sym ,key) ,session ,input)))
                `(setf (symbol-function ',grow)
                       (lambda (,system ,key &optional ,session ,input)
                         (unless ,key
                           (error "Warning: attempt to grow system ~a without a specified branch." ,system))
                         (if (or (eq ,system ,name) (not ,system))
                             (funcall (getf ,branches-sym ,key) ,session ,input)
                             (funcall (funcall ,contactor ,system)
                                      nil ,key ,session ,input))))))))))

(defun in-system-context (spec system-name)
  (append (list (first spec) (second spec))
          (cons (cons :system system-name) (cddr spec))))

(defun interact (portal branch &optional session-api input)
  (funcall (getf (getf portal :branches) branch)
           session-api input))

(defun with (item &rest props) ;; obsolete
  (append (list :props item) props))

(defun with-meta (item &rest props)
  `(meta ,item ,@props))

;; (defun portal-contacts (system)
;;   (getf (getf (if (not (symbolp system))
;;                   system (getf *seed-interfaces* system))
;;               :props) :portal-contacts))

;; (defun portal-endpoint (system)
;;   (getf (getf (if (not (symbolp system))
;;                   system (getf *seed-interfaces* system))
;;               :props) :endpoint))

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

;; SECTION: basic system interaction tools

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

;; (defmacro interface-spec (props &rest elements)
;;   `(generate-interface-spec ,@(loop :for el :in elements :collect (list 'quote el))))

;; (defmacro >> (&rest items)
;;   (cons 'vector items))

;; SECTION: basic UI component features

(defun uic-form-compose (form)
  (if (not (listp form))
      form (if (listp (rest form))
               (if (and (symbolp (first form))
                        (not (keywordp (first form))))
                   form (cons 'list (mapcar #'uic-form-compose form)))
               `(cons ,(first form) ,(rest form)))))

(defmacro uic (props &rest items)
  `(generate-uic (list ,@(mapcar #'uic-form-compose props))
                 ,@items))

;; (defmacro uic (props &rest items)
;;   `(generate-uic (list ,@(loop :for p :in props :collect (if (listp (rest p)) (cons 'list p)
;;                                                              `(cons ,(first p) ,(rest p)))))
;;                        ,@items))

(defun generate-uic (props &rest items)
  `(meta ,(if (rest items) items (first items)) ,@props))

;; (defun generate-uic (props &rest items)
;;   `(meta ,(if (rest items) items (first items))
;;          ,@(loop :for clause :in props :collect (if (or t (not (listp clause))
;;                                                         (not (keywordp (first clause))))
;;                                                     clause (list 'quote clause)))))

(defun mprops-compose (form)
  (if (not (listp form))
      form (if (listp (rest form))
               (if (and (symbolp (first form))
                        (not (keywordp (first form))))
                   form (mapcar #'mprops-compose form))
               `(cons ,(first form) ,(rest form)))))

(defmacro xform (item &rest props)
  `(mf-build ,item ',props))

(defun mf-build (item &optional props)
  (if (not props)
      item (append (list 'meta (if (eql 'xform (first item))
                                   (macroexpand item)
                                   (mapcar #'mf-build item)))
                   (mapcar #'mprops-compose props))))

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
  "A macro for denoting inline Parenscript code."
  `(subseq (parenscript:ps-inline ,form) 11))

;; SECTION: another iteration of the UI component class system, with a simple list/atom foundation

(defclass ui-medium ()
  ((%name   :accessor uim-name
            :initform nil
            :initarg  :name)
   (%portal :accessor uim-portal
            :initform nil
            :initarg  :portal)))

(defclass uim-web (ui-medium)
  ((%stream :accessor uim-web-stream
            :initform nil
            :initarg  :stream)))

(defclass uim-terminal (ui-medium)
  ())

(defclass ui-component ()
  ((%name :accessor uic-name
          :initform nil
          :initarg  :name)
   (%base :accessor uic-base
          :initform nil
          :initarg  :base)
   (%type :accessor uic-type
          :initform nil
          :initarg  :type)
   (%join :accessor uic-join
          :initform nil
          :initarg  :join)
   (%cast :accessor uic-cast
          :initform nil
          :initarg  :cast)
   (%sort :accessor uic-sort
          :initform nil
          :initarg  :sort)))

(defclass uic-access (ui-component)
  ((%system :accessor uica-system
            :initform nil
            :initarg  :system)))

(defclass uic-series (ui-component)
  ((%maps :accessor uic-series-maps
          :initform nil
          :initarg  :maps)
   (%layout :accessor uic-series-layout
            :initform nil
            :initarg  :layout)))

(defclass uic-grid (ui-component)
  ())

(defclass uic-series-form (uic-series)
  ())

(defclass uic-control (ui-component)
  ((%key :accessor uicc-key
         :initform nil
         :initarg  :key)))

(defclass uic-anchor (ui-component)
  ())

(defclass uicc-button (uic-control)
  ())

(defclass uicc-toggle (uic-control)
  ())

(defclass uicc-select (uic-control)
  ())

(defclass uicc-text (uic-control)
  ((%default :accessor uicc-text-default
             :initform nil
             :initarg  :default)))

(defmacro fx (specs &rest form)
  (labels ((format-params (items)
             (loop :for item :in items
                   :collect (if (or (atom item)
                                    (not (keywordp (first item))))
                                item (list 'quote item))))
           (process-spec (item spec-list)
             (let ((generated))
               (case (caar spec-list)
                 (:each
                  (destructuring-bind (class &rest params) (cdar spec-list)
                    (let* ((sub-item (gensym))
                           (params (format-params params)))
                      (setf generated `(mapcar (lambda (,sub-item)
                                                 (make-instance ',class :base ,sub-item ,@params))
                                               ,item)))))
                 (t (destructuring-bind (class &rest params) (first spec-list)
                      (setf generated `(make-instance ',class :base ,item ,@(format-params params))))))
               (if (not (rest spec-list))
                   generated (process-spec generated (rest spec-list))))))
    (let ((evaluated-form (gensym)))
      `(let ((,evaluated-form ,(if (not (second form))
                                   (first form) (cons 'list form))))
         ,(process-spec evaluated-form specs)))))

(defgeneric render (medium component))

(defmethod render ((medium uim-web) (component t))
  (let ((spinneret:*html* (uim-web-stream medium)))
    (spinneret:interpret-html-tree (generate medium component))))

(defgeneric realize (origin medium aspect &key sort))

(defun alist-supersede (new original)
  (loop :for n :in new :do (if (assoc (first n) original)
                               (rplacd (assoc (first n) original)
                                       (rest n))
                               (push n original)))
  original)

(defmethod realize ((origin ui-component) (medium ui-medium) (aspect t)
                    &key sort)
  (unless (not (typep aspect 'ui-component))
    ;; (print (list :ee (uic-join aspect)))
    (when (uic-join aspect)
      (let* ((ajoin (uic-join aspect))
             (ojoin (copy-tree (uic-join origin)))
             (new-list (if (listp ajoin)
                           (if (listp (first ajoin))
                               ajoin (list (cons :in  ajoin)
                                           (cons :out ajoin)))
                           (error "AAA"))))
        ;; adapt for one-symbol join specs
        ;; (print (list :aoa ajoin ojoin new-list))
        (setf ojoin (alist-supersede new-list ojoin))
        (setf (uic-join aspect) ojoin))
      (setf (uic-join aspect) (uic-join origin)))
    (when sort (setf (uic-sort aspect) sort)))
  (generate medium aspect))

(defgeneric generate (medium component))

(defgeneric locate (medium component index item))

(defmethod locate ((medium uim-web) (comp t) index item)
  (declare (ignore medium comp index item))
  "")

(defmethod generate ((medium uim-web) (comp null))
  (declare (ignore medium comp)))

(defmethod generate ((medium uim-web) (comp list))
  (declare (ignore medium))
  comp)

(defmethod generate ((medium uim-web) (comp symbol))
  (declare (ignore medium))
  (string-downcase comp))

(defmethod generate ((medium uim-web) (comp string))
  (declare (ignore medium))
  (list :raw comp))

(defmethod generate ((medium uim-web) (aspect uic-access))
  (let ((last-type-index (1- (length (uic-type aspect))))
        (class-stream (make-string-output-stream))
        (types (funcall (if (listp (uic-type aspect)) #'identity #'list)
                        (uic-type aspect)))
        (face (lisp->camel-case (uic-name aspect)))
        (system (or (uica-system aspect) (uim-portal medium)))
        (branch (string (uic-base aspect))))
    
    (format class-stream "sub-container")
    (loop :for type :in types :for ix :from 0
          :do (format class-stream "~a" (string-downcase type))
              (unless (= ix last-type-index) (format class-stream " ")))
    
    `(:div :hx-post "/render/" :hx-trigger "load, reload consume"
           :id ,(format nil "branch-~a" (lisp->camel-case (uic-name aspect)))
           :class ,(get-output-stream-string class-stream)
           :x-init ,(ps (progn (setf (getprop (@ window seed-elements) (lisp face)) $el)
                               (fetch-contact (lisp (string-upcase system))
                                              (lisp (string-upcase (uic-base aspect)))
                                              (create height (@ $el offset-height)
                                                      width  (@ $el offset-width))
                                              (lambda (data)
                                                ;; (chain console (log :dt data
                                                ;;                     (@ $el offset-height)))
                                                ))))
           :hx-vals ,(json-convert-to (list :system system :face face
                                            :branch (string-upcase (uic-base aspect))))
           ;; :hx-vals ,(print (ps (create system (lisp system) face (lisp face)
           ;;                       branch (lisp (string-upcase (uic-base aspect))))))
           :x-data ,(ps (create branch-frame $el)))))

(defmethod generate ((medium uim-web) (aspect uic-series))
  (let ((last-type-index (1- (length (uic-type aspect))))
        (class-stream (make-string-output-stream))
        (types (funcall (if (listp (uic-type aspect)) #'identity #'list)
                        (uic-type aspect)))
        (join-spec (rest (assoc :out (uic-join aspect))))
        (breadth-default 12))
    (format class-stream "ui ")
    (format class-stream "~a" (typecase aspect (uic-series "series ")
                                        ;; (uic-set-frame "frame ")
                                        (t "")))
    
    (destructuring-bind (&optional ltype lstyle &rest lprops) (uic-series-layout aspect)
      (case ltype
        ((:horizontal :vertical) (format class-stream "series grid-layout ")))

      ;; (print (list :js (uic-join aspect)))

      (flet ((enclose-by-type (types element)
               (loop :for type :in types
                     :do (setf element (case type
                                         (:column
                                          `(:div :class "container column-inner" ,element))
                                         (t element))))
               element))
        (loop :for type :in types :for ix :from 0
              :do (format class-stream "~a" (string-downcase type))
                  (unless (= ix last-type-index) (format class-stream " ")))
        (append (list (typecase aspect (uic-series-form :form) (t :div))
                      :path "" :class (get-output-stream-string class-stream)
                      :style (if (not (member ltype '(:horizontal :vertical)))
                                 "" (let ((ratio (/ 100.0 (or (first lprops) breadth-default))))
                                      (format nil "grid-template-~a: ~{~a% ~};"
                                              (if (eq ltype :horizontal) "columns" "rows")
                                              (loop :for i :below (or (first lprops) breadth-default)
                                                    :collect ratio)))))
                ;; (if nil ; join-spec
                ;;     (destructuring-bind (system &optional branch)
                ;;         (if (listp join-spec) join-spec (list nil join-spec))
                ;;       (list :x-data (ps:ps* `(create ,@(if system `(system ,system))
                ;;                                      ,@(if branch `(branch ,branch))
                ;;                                      ;; local-forms (list)
                ;;                                      ;; allow extension of forms list in some cases
                ;;                                      act (realize ,system ,branch $el))))))
                (loop :for ix :from 0 :for item :in (uic-base aspect)
                      :collect (let ((map (nth ix (uic-series-maps aspect))))
                                 (format class-stream "item ")
                                 (loop :for itype :in (rest (assoc :type map))
                                       :do (format class-stream "~a " (string-downcase itype)))
                                 (locate medium aspect ix
                                         `(:div :class ,(get-output-stream-string class-stream)
                                                ,(enclose-by-type
                                                  types (realize aspect medium item
                                                                 :sort ix)))))))))))

(defmethod generate ((medium uim-web) (aspect uic-grid))
  (destructuring-bind (system branch) (uic-base aspect)
    (let ((token (format nil "canvas-datagrid-~a-~a"
                         (string-downcase system) (string-downcase branch)))
          (branch (string-downcase branch))
          ;; (mode (getf props :mode))
          )
      `(:div :id "datagrid-cells" ;; :class (getf props :item-classes)
             :x-init ,(psl (progn (setf (getprop (@ window seed-elements) (lisp branch)) $el)
                                  (fetch-contact
                                   (lisp (string-upcase system)) (lisp (string-upcase branch))
                                   (list (list "cells" 0))
                                   (lambda (data)
                                     ;; (chain console (log :dd data))
                                     (let ((grid (canvas-datagrid
                                                  (create style (create cell-width 60)))))
                                       (chain document (get-element-by-id "datagrid-cells")
                                              (append-child grid))
                                       (setf (@ grid data) (@ data ct)
                                             (getprop (@ window seed-data) (lisp token))
                                             grid))))))))))

(defmethod generate ((medium uim-web) (aspect uic-anchor))
  (let ((base (uic-base aspect)))
    (case (first (uic-type aspect))
      (:branch (if base `(:h4 (:a :|hx-on:click|
                                  ,(format nil "htmx.trigger(this, 'navigate', { point: ~a });"
                                           (uic-sort aspect))
                                  ,(string base)))
                   '(:hr :class "divider")))
      (t `(:span ,(string-downcase base))))))

(defmethod generate ((medium uim-web) (aspect uicc-button))
  (let* ((base (uic-base aspect))
         (name (if (symbolp base) base)))
    (destructuring-bind (name &optional action &rest props)
        (if name (list name name) (uic-base aspect))
      ;(print (list :aa action))
      (let ((action-props
              (case action
                (:cast-forms
                 `(:|x-on:click|
                    ,(ps (chain htmx (find-all (lisp (format nil "#cast-~a form.xp-form"
                                                             (lisp->camel-case (first props)))))
                               (for-each (lambda (form)
                                           (chain htmx (trigger form "submit")))))))))))
        `(:button :name ,(or (string name) "") :class "ui button"
                  ,@action-props
                  ,(realize aspect medium ;; (uic-base aspect)
                            name))))))

#|
((list :form :branch-navigation)
                ;; (print (list :con contents form))
 (let ((point (or (second (assoc :point (getf form :mt)))
                  (getf (first contents) :ct)))
       ;; (point-index (if (not point) 0 (position point contents
       ;;                                          :test (lambda (a b)
       ;;                                                  (string= a (getf b :ct))))))
       )
   (cl-who:with-html-output (strout)
     (:div :path path-string
           :id "branch-navigation"
           (loop :for c :in contents :for ix :from 0
                 :do (if c (htm (:h4 :hx-post "/render/"
                                     :class (if (string= point (getf c :ct))
                                                "point" "")
                                     :hx-target "#main"
                                     :hx-trigger "click consume"
                                     :hx-vals (json-convert-to
                                               (list :system :portal.demo1
                                                     :branch (rest (assoc :target
                                                                          (getf form :mt)))
                                                     :point (getf c :ct)))
                                     (str (getf c :ct))))
                         (htm (:hr :class "divider"))))))))
|#

(defmethod generate ((medium uim-web) (aspect uicc-text))
  ;; (print (list :ee medium (uic-type aspect)))
  (cond ((member :code (uic-type aspect))
         (destructuring-bind (system branch) (uic-base aspect)
           (let ((token (format nil "cm-texteditor-~a-~a" (string-downcase system)
                                (string-downcase branch))))
             `(:div :id ,token ;; :class ,(uic-type aspect)
                    :x-init ,(psl (progn (setf (@ window codemirror) nil)
                                         (setf (getprop (@ window seed-elements) (lisp branch))
                                               $el)
                                         (fetch-contact (lisp (string system)) (lisp (string branch))
                                                        (list (list "text" 0))
                                                        ;; nil
                                                        ;; ,(string-upcase (getf props :branch))
                                                        (lambda (data) 
                                                          ;; (chain console (log :dt (@ data text)))
                                                          (setf (getprop (@ window seed-data) (lisp token))
                                                                (create-codemirror
                                                                 (chain document
                                                                        (get-element-by-id (lisp token)))
                                                                 (@ data text)))))))))))
        ((member :area (uic-type aspect))
         `(:textarea :class "input" :name ,(or (string (uicc-key aspect)) "")
                     ,(or (uicc-text-default aspect) "")))
        (t `(:input :class "input" :type "text" :value ,(or (uicc-text-default aspect) "")
                    :name ,(or (string (uicc-key aspect)) "")))))

;; (defmethod generate ((medium uim-web) (aspect uicc-text-area))
;;   `(:textarea :class "input" :value ,(or (uicc-text-default aspect) "")
;;               :name ,(or (string (uicc-key aspect)) "")))

(defmethod generate ((medium uim-web) (aspect uicc-select))
  `(:select :class "ui" :name ,(or (string (uicc-key aspect)) "")
     ,@(loop :for item :in (uic-base aspect) :collect `(:option ,item))))

(defmethod locate ((medium uim-web) (aspect uic-series) index item)
  (let ((default-segments 12)) ;; default number of segments for a grid layout
    (if (not (uic-series-layout aspect))
        item (let ((item-props (butlast (rest item) 1)))
               (destructuring-bind (type style &rest props) (uic-series-layout aspect)
                 (case type
                   ((:horizontal :vertical)
                    (case style
                      ((:even :of)
                       (let* ((divisions (or (first props) default-segments))
                              (width (/ divisions (length (uic-base aspect))))
                              (next-index 0))
                         (if (eq :of style)
                             (setf width 1
                                   next-index (if (= index (1- (length (uic-base aspect))))
                                                  (first props)
                                                  (+ index (nth index (rest props))))
                                   index (loop :for i :in (rest props) :for x :below index
                                               :summing i :into r :finally (return r)))
                             (setf next-index (1+ index)))
                         (setf (getf item-props :class)
                               (format nil "~a even" (getf item-props :class))
                               (getf item-props :style)
                               (format nil "~a ~a: ~a; ~a: ~a;" (or (getf item-props :style) "")
                                       (if (eq type :horizontal)
                                           "grid-column-start" "grid-row-start")
                                       (1+ (floor (* width index)))
                                       (if (eq type :horizontal)
                                           "grid-column-end" "grid-row-end")
                                       (1+ (floor (* width next-index)))))))))))
               (cons (first item) (append item-props (last item)))))))

(defmethod generate :around ((medium uim-web) (aspect ui-component))
  ;; (print (list :ava aspect (uic-cast aspect)))
  (if (not (uic-cast aspect))
      (call-next-method)
      (let* ((cast (uic-cast aspect))
             (section-id (if (listp cast) (getf cast :id))))
        (list :form ;; :hx-vals (if (not (listp cast))
                    ;;              "{}" (ps* `(create ,(getf cast :data))))
                    :id (if (not section-id)
                            "" (format nil "cast-~a" (lisp->camel-case section-id)))
                    :hx-inherit "*" :hx-post "/render/" ;; :hx-target "#main"
                    ;; :x-init (psl (progn (if (not (= "undefined" (typeof local-forms)))
                    ;;                         (push-form $el local-forms))))
                    ;; TODO: CHANGE HARDCODED ELEMENT ID
              (call-next-method)))))

(defun express (form)
  (if (atom form)
      form (if (not (string= "META" (string (first form))))
               (make-instance 'uic-series
                              :base (mapcar #'express form))
               (let* ((types (rest (assoc :type (cddr form))))
                      (primary-type (first types))
                      (class (case primary-type
                               (:set 'uic-series)
                               (:select 'uicc-select)
                               (:field  'uicc-text))))
                 (make-instance class :base ;; (first form)
                                (if (eq :set primary-type)
                                    (mapcar #'express (second form))
                                    (if (eq :select primary-type)
                                        (rest (assoc :options (cddr form)))
                                        (second form)))
                                :type (cddr (rest (assoc :type (cddr form)))))))))

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

(defun render-html-interface (form &optional system-id meta path stream)
  (let ((strout (or stream (make-string-output-stream)))
        ;; get ID of applicable system from form metadata
        (system-id (or (rest (assoc :system (getf form :mt)))
                       system-id))
        (path-string (apply #'concatenate 'string
                            (loop :for item :in (reverse path)
                                  :append (list (write-to-string item) " ")))))
    ;; (print (list :fo form))
    (case (getf form :ty)
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
                                                                    system (lisp (string-upcase system-id))
                                                                    BRANCH "SYSTEMS"
                                                                    input (ps:lisp (getf form :ct)))))
                                                      headers (create "Content-type"
                                                                      "application/json; charset=UTF-8")))
                                       (then (lambda (response) (chain response (json))))
                                       (then (lambda (data) (chain htmx (trigger "#main" "reload"))))))
                           (str (lisp->camel-case (getf form :ct))))))
                 ;; (:set-nav-point
                 ;;  (print (list :forma form))
                 ;;  (if form (cl-who:with-html-output (strout)
                 ;;             (:h4 (str (getf form :ct))))
                 ;;      (cl-who:with-html-output (strout) (:p "abcd"))))
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
               ;; ((list :form :branch-navigation)
               ;;  ;; (print (list :con contents form))
               ;;  (let ((point (or (second (assoc :point (getf form :mt)))
               ;;                   (getf (first contents) :ct)))
               ;;        ;; (point-index (if (not point) 0 (position point contents
               ;;        ;;                                          :test (lambda (a b)
               ;;        ;;                                                  (string= a (getf b :ct))))))
               ;;        )
               ;;    (cl-who:with-html-output (strout)
               ;;      (:div :path path-string
               ;;            :id "branch-navigation"
               ;;            (loop :for c :in contents :for ix :from 0
               ;;                  :do (if c (htm (:h4 :hx-post "/render/"
               ;;                                      :class (if (string= point (getf c :ct))
               ;;                                                 "point" "")
               ;;                                      :hx-target "#main"
               ;;                                      :hx-trigger "click consume"
               ;;                                      :hx-vals (json-convert-to
               ;;                                                (list :system :portal.demo1
               ;;                                                      :branch (rest (assoc :target
               ;;                                                                           (getf form :mt)))
               ;;                                                      :point (getf c :ct)))
               ;;                                      (str (getf c :ct))))
               ;;                          (htm (:hr :class "divider"))))))))
               ;; ((list :form :elem)
               ;;  (let ((branch (second (assoc :access (getf form :mt))))
               ;;        (name (rest (assoc :name (getf form :mt))))
               ;;        (controls (rest (assoc :controls (getf form :mt))))
               ;;        (item-classes (apply #'concatenate 'string
               ;;                             (loop :for y :in (rest (assoc :type (getf form :mt)))
               ;;                                   :collect (format nil "~a " (string-downcase y)))))
               ;;        (iface-name (rest (assoc :name (getf form :mt)))))
               ;;    (cl-who:with-html-output (strout)
               ;;      (:div :class "container column-inner"
               ;;            :x-data (psl (let ((main-forms (list)))
               ;;                           (create push-form (lambda (item)
               ;;                                               (chain main-forms (push item)))
               ;;                                   submit-forms (lambda ()
               ;;                                                  ;; (chain console (log :mm main-forms))
               ;;                                                  (chain main-forms
               ;;                                                         (for-each (lambda (form)
               ;;                                                                     (chain htmx
               ;;                                                                            (trigger
               ;;                                                                             form
               ;;                                                                             "submit")))))))))
               ;;            (if (not (assoc :header controls))
               ;;                nil (htm (:div :class "ui medium header"
               ;;                               (:h2 :class "branch-name" (str (lisp->camel-case name)))
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :header controls))
               ;;                                           :do (branch-spec-form
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                :branch branch :name iface-name))))))
               ;;            (branch-spec-form
               ;;             strout :body-svg :system system-id :branch branch
               ;;                              :item-classes item-classes :name iface-name)
               ;;            (if (not (assoc :footer controls))
               ;;                nil (htm (:div :class "ui medium footer"
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :footer controls))
               ;;                                           :do (branch-spec-form
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                :branch branch :name iface-name))))))))))
               ;; ((list :form :text)
               ;;  (let ((branch (second (assoc :access (getf form :mt))))
               ;;        (name (rest (assoc :name (getf form :mt))))
               ;;        (controls (rest (assoc :controls (getf form :mt))))
               ;;        (item-classes (apply #'concatenate 'string
               ;;                             (loop :for y :in (rest (assoc :type (getf form :mt)))
               ;;                                   :collect (format nil "~a " (string-downcase y))))))
               ;;    (cl-who:with-html-output (strout)
               ;;      (:div :class "container column-inner"
               ;;            (if (not (assoc :header controls))
               ;;                nil (htm (:div :class "ui medium header"
               ;;                               (:h2 :class "branch-name" (str (lisp->camel-case name)))
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :header controls))
               ;;                                           :do (branch-spec-codemirror-editor
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                                :branch branch))))))
               ;;            (branch-spec-codemirror-editor strout :body :system system-id
               ;;                                                       :branch branch :item-classes item-classes)
               ;;            (if (not (assoc :footer controls))
               ;;                nil (htm (:div :class "ui medium footer"
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :footer controls))
               ;;                                           :do (branch-spec-codemirror-editor
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                                :branch branch))))))))))
               ((list :form :tree)
                (let ((branch (second (assoc :access (getf form :mt))))
                      (name (rest (assoc :name (getf form :mt))))
                      (controls (rest (assoc :controls (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class "container column-inner"
                          (if (not (assoc :header controls))
                              nil (htm (:div :class "ui medium header"
                                             (:h2 :class "branch-name" (str (lisp->camel-case name)))
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
               ;; ((list :form :cells)
               ;;  (let ((branch (second (assoc :access (getf form :mt))))
               ;;        (name (rest (assoc :name (getf form :mt))))
               ;;        (controls (rest (assoc :controls (getf form :mt))))
               ;;        (item-classes (apply #'concatenate 'string
               ;;                             (loop :for y :in (rest (assoc :type (getf form :mt)))
               ;;                                   :collect (format nil "~a " (string-downcase y))))))
               ;;    (cl-who:with-html-output (strout)
               ;;      (:div :class "container column-inner"
               ;;            (if (not (assoc :header controls))
               ;;                nil (htm (:div :class "ui medium header"
               ;;                               (:h2 :class "branch-name" (str (lisp->camel-case name)))
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :header controls))
               ;;                                           :do (branch-spec-cvdatagrid-sheet
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                                :branch branch))))))
               ;;            (branch-spec-cvdatagrid-sheet strout :body :system system-id
               ;;                                                       :branch branch :item-classes item-classes)
               ;;            (if (not (assoc :footer controls))
               ;;                nil (htm (:div :class "ui medium footer"
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :footer controls))
               ;;                                           :do (branch-spec-cvdatagrid-sheet
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                                :branch branch))))))))))
               ;; ((list :form :vector)
               ;;  (let ((branch (second (assoc :access (getf form :mt))))
               ;;        (controls (rest (assoc :controls (getf form :mt))))
               ;;        (item-classes (apply #'concatenate 'string
               ;;                             (loop :for y :in (rest (assoc :type (getf form :mt)))
               ;;                                   :collect (format nil "~a " (string-downcase y))))))
               ;;    (cl-who:with-html-output (strout)
               ;;      (:div :class "container column-inner"
               ;;            (if (not (assoc :header controls))
               ;;                nil (htm (:div :class "ui medium header"
               ;;                               (:h2 :class "branch-name" (str (lisp->camel-case branch)))
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :header controls))
               ;;                                           :do (branch-spec-d3
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                                :branch branch))))))
               ;;            (branch-spec-d3 strout :body :system system-id
               ;;                                         :branch branch :item-classes item-classes)
               ;;            (if (not (assoc :footer controls))
               ;;                nil (htm (:div :class "ui medium footer"
               ;;                               (:div :class "controls-holder"
               ;;                                     (loop :for c :in (rest (assoc :footer controls))
               ;;                                           :do (branch-spec-d3
               ;;                                                strout :control :subsection c :system system-id
               ;;                                                                :branch branch))))))))))
               ((list :form (guard form-type (keywordp form-type)))
                (print (list :for form))
                (let ((branch (second (assoc :access (getf form :mt))))
                      (item-classes (apply #'concatenate 'string
                                           (loop :for y :in (rest (assoc :type (getf form :mt)))
                                                 :collect (format nil "~a " (string-downcase y))))))
                  (cl-who:with-html-output (strout)
                    (:div :class item-classes :hx-trigger "load, reload"
                          :x-init (psl (setf (getprop (@ window seed-elements) (lisp branch)) $el))
                          :hx-post "/render/" :hx-vals (json-convert-to (list :system :demo.sheet
                                                                              :branch branch))))))
               ((list* :group :linear _)
                ;; (let ((widths (if (eq :sidebar (first members))
                ;;                   '("two" "fourteen") '("seven" "seven"))))
                (cl-who:with-html-output (strout)
                  (:div :class (format nil "ui grid-layout ~a"
                                       (apply #'concatenate
                                              'string (loop :for s :in (cddr type)
                                                            :append (list " " (string-downcase s)))))
                        :path path-string
                        (loop :for c :in contents :for m :in members :for ix :from 0 ; :for w :in widths
                              :do (let ((item-classes
                                          (apply #'concatenate 'string
                                                 (loop :for y :in (rest (assoc :type (getf c :mt)))
                                                       :collect (format nil "~a " y)))))
                                    (htm (:div :class (format nil "~a ~a"
                                                              (string-downcase item-classes)
                                                              (string-downcase m))
                                               (render-html-interface c system-id nil
                                                                      (cons ix path)
                                                                      strout))))))))
               ((list* :set set-subtypes)
                (match set-subtypes
                  ((list* :linear linear-subtypes)
                   (let* ((widths (if (eq :sidebar (first members))
                                      '("two" "fourteen") '("seven" "seven")))
                          (point (second (assoc :point (getf form :mt))))
                          (point-index (if (not point)
                                           0 (position point contents
                                                       :test (lambda (a b)
                                                               (string= a (rest (assoc :name
                                                                                       (getf b :mt))))))))
                          (start-index 0))
                     ;; (print (list :mmm (getf form :mt) contents point-index))
                     (loop :for c :in contents :for ix :from 0 :below point-index
                           :when (string= "PARTITION" (getf c :ct)) :do (setf start-index (1+ ix)))
                     (cl-who:with-html-output (strout)
                       (:div :class (format nil "ui grid-layout ~a"
                                            (apply #'concatenate
                                                   'string (loop :for s :in (cddr type)
                                                                 :append (list " " (string-downcase s)))))
                             :path path-string
                             (loop :for ix :from start-index :for c :in (nthcdr start-index contents)
                                   ;; stop at the partition keyword
                                   :while (not (and (getf c :ty) (string= "KEYWORD" (getf c :pk))
                                                    (string= "PARTITION" (getf c :ct))))
                                   :do (let ((item-classes
                                               (apply #'concatenate 'string
                                                      (loop :for y :in (rest (assoc :type (getf c :mt)))
                                                            :collect (format nil "~a " y)))))
                                         ;; (print (rest (assoc :name (getf c :mt))))
                                         (htm (:div :class (format nil "~acolumn"
                                                                   (string-downcase item-classes))
                                                    (render-html-interface c system-id nil (cons ix path)
                                                                           strout)))))))))))
               ((list* :group :stack _)
                (cl-who:with-html-output (strout)
                  (:div :path path-string :class "stack"
                        (loop :for c :in contents :for m :in members :for ix :from 0
                              :do (let ((item-classes
                                          (apply #'concatenate 'string
                                                 (loop :for y :in (rest (assoc :type (getf c :mt)))
                                                       :collect (format nil "~a " (string-downcase y)))))
                                        ;; (rendered (or (render-html-interface c system-id nil (cons ix path)
                                        ;;                                      strout)
                                        ;;               ;; render either via the html interface methods or 
                                        ;;               ;; (htrender c :branch system-id
                                        ;;               ;;             :params (list :system :system-id
                                        ;;               ;;                           :branch :system-id))
                                        ;;               ))
                                        )
                                    ;; (print (list :cc c system-id))
                                    (htm (:div :class item-classes ;; rendered
                                               (render-html-interface c system-id nil (cons ix path)
                                                                      strout)
                                               )))))))))))
    (if stream nil (get-output-stream-string strout))))


(defun render-nav-menu (form)
  (loop :for item :in (second form)
        :collect (if (eq item :partition)
                     nil (rest (assoc :name (cddr item))))))

(defun set-in-element-spec (name form value)
  (if (not (listp form))
      nil (destructuring-bind (_ item &rest props) form
            (let ((this-name (rest (assoc :name props))))
              (if (eql name this-name)
                  (setf (second form) value)
                  (if (not (listp item))
                      nil (let ((output))
                            (loop :for i :in item :while (not output)
                                  :do (setf output (set-in-element-spec name i value)))
                            output)))))))

(defun meta-revise (form pairs &optional cons-items)
  "Revise contents of a meta-form according to titles, optionally expressed by cons cells whose heads are symbols corresponding to keys in the pairs list."
  ;; (print (list :fo form pairs))
  (if (not (listp form))
      nil (if (and (listp (first form))
                   (or (not cons-items)
                       (not (keywordp (first form)))))
              (progn (loop :for f :in form :do (meta-revise f pairs cons-items))
                     form)
              (destructuring-bind (_ item &rest props) form
                (let* ((this-name (if cons-items (first item)
                                      (rest (assoc :name props))))
                       (corresponding (if (not this-name)
                                          nil (rest (assoc this-name pairs))))
                       (process (or (match (rest (assoc :type props))
                                      ((list :field :numeric :integer)
                                       #'parse-number:parse-number))
                                    #'identity)))
                  (if corresponding
                      (if cons-items (setf (rest (second form))
                                           (funcall process corresponding))
                          (setf (second form) (funcall process corresponding)))
                      (when (and (listp item)
                                 (or (not cons-items)
                                     (not (keywordp (first item)))))
                        (loop :for i :in item :do (meta-revise i pairs cons-items))))
                  form)))))

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

(defun format-graph-spec-to-edit (dgraph order)
  (let ((nodes (copy-tree (rest dgraph))))
    (cons (first dgraph)
          (loop :for index :across order :for nx :from 0
                ;; remove (meta) forms; should this be factored into a dedicated function?
                :collect (let ((node (nth index nodes)))
                           (cons (cons (cons :index nx) (first node))
                                 (cons :closed (rest node))))))))

(defun copy-graph-spec (original)
  (cons (first original)
        (loop :for item :in (rest original)
              :collect (cons (first item)
                             (loop :for sub-item :in (rest item)
                                   :collect (if (not (listp sub-item))
                                                sub-item (list (first sub-item)
                                                               (second sub-item))))))))

(defun dgraph-interface (dgraph interface orig-indices &key path to-open at-path)
  (if (rest path)
      (setf (nth (first path) (rest interface))
            (dgraph-interface dgraph (nth (first path) (rest interface))
                              orig-indices :path (rest path) :to-open to-open :at-path at-path))
      (let ((point (nth (first path) (rest interface)))
            (output (cons (first interface) (rest interface))))
        (setf (nth (first path) (rest output))
              (if (numberp (second point))
                  (list (first point)
                        (nth (aref orig-indices (second point)) (rest dgraph)))
                  (cons (first point)
                        (if at-path (rest point)
                            (if to-open (if (not (eq :closed (second point)))
                                            (rest point) (cddr point))
                                (if (eq :closed (second point))
                                    (rest point) (cons :closed (rest point)))))))
              interface output)))
  interface)

(defvar *giface-output-stream*)

(defun spec-graph-interface (&key package file-name graph-key holder-id associated-node-ids
                               node-template-key link-template-key node-indices-key)
  (let ((el-width) (el-height) (formatted)
        (graph-base) (graph-data) (orig-data) (index 0) (sub-index) (nodes-order)
        (node-template (second (from-system-file package file-name node-template-key)))
        (link-template (second (from-system-file package file-name link-template-key)))
        (indices-form (from-system-file package file-name node-indices-key)))
    (lambda (context input)
      
      (unless graph-base
        (setf graph-base  (from-system-file package file-name graph-key)
              orig-data   (third graph-base)
              nodes-order (let* ((indices (second indices-form)))
                            ;; TODO: Make this just (apply #'vector ...)
                            (make-array (length indices) :initial-contents indices))
              graph-data  (format-graph-spec-to-edit (copy-tree orig-data) nodes-order)
              formatted   (copy-graph-spec graph-data)))
      
      ;; (print (list :abcd orig-data graph-data formatted))
      (if (and (assoc "action" input :test #'string=)
               (string= "open" (rest (assoc "action" input :test #'string=))))
          (let* ((path-str (make-string-input-stream
                            (rest (assoc "path" input :test #'string=))))
                 (path (loop :for c := (read path-str nil) :while c :collect c)))
            ;; (print (list :pa path))
            (if (not (second path)) (setf index (first path) sub-index nil)
                (destructuring-bind (i si) path
                  (setf index i sub-index si)))
            ;; (print (list :nnn index))
            ;; (close path-str)
            (list :oob-reload associated-node-ids))
          (let ((network-changed))
            (when (and input (assoc "width" input :test #'string=))
              (setf el-width  (rest (assoc "width"  input :test #'string=))
                    el-height (rest (assoc "height" input :test #'string=))))

            ;; (print (list :f1 formatted))
            (when (and input (assoc "path" input :test #'string=))
              (let ((action (rest (assoc "action" input :test #'string=)))
                    (inst (make-string-input-stream
                           (rest (assoc "path" input :test #'string=)))))
                (dgraph-interface
                 graph-data formatted nodes-order
                 :path (loop :for c := (read inst nil) :while c :collect c)
                 :to-open (string= action "expand")
                 :at-path (if (not (string= action "open"))
                              nil (lambda (item)
                                    ;; (setf (symbol-value
                                    ;;        (intern "*ACTIVE-GRAPH-ITEM*" (string package)))
                                    ;;       item)
                                    )))
                (setf network-changed t)))

            (when (and (assoc :action input :test #'eq)
                       (string= "formSubmit" (rest (assoc :action input :test #'eq))))
              (meta-revise (if sub-index (first (nth sub-index
                                                     (rest (nth index (rest formatted)))))
                               (cdar (nth index (rest formatted))))
                           input t)
              (meta-revise (first (if sub-index
                                      (nth sub-index (rest (nth index (rest orig-data))))
                                      (nth index (rest orig-data))))
                           input t)
              (setf network-changed t))

            (when (assoc "action" input :test #'string=)
              (setf network-changed t)

              ;; add a node
              (when (string= "addNode" (rest (assoc "action" input :test #'string=)))
                ;; add newest node index to end of indices
                (rplacd (last formatted)
                        (list (list (cons (cons :index (length (second indices-form)))
                                          (first node-template)))))
                (rplacd (last (second indices-form))
                        (list (length (second indices-form))))
                (rplacd (last orig-data) (list node-template))
                (setf nodes-order (let* ((indices (second indices-form)))
                                    (make-array (length indices)
                                                :initial-contents indices))))

              ;; add a link between nodes
              (when (string= "addLink" (rest (assoc "action" input :test #'string=)))
                (if sub-index (rplacd (nth sub-index (rest (nth index (rest orig-data))))
                                      (cons link-template
                                            (nthcdr (1+ sub-index)
                                                    (rest (nth index (rest orig-data))))))
                    (rplacd (last (rest (nth index (rest orig-data))))
                            (list link-template)))
                (if sub-index (rplacd (nth sub-index (rest (nth index (rest graph-data))))
                                      (cons link-template
                                            (nthcdr (1+ sub-index)
                                                    (rest (nth index (rest graph-data))))))
                    (rplacd (last (rest (nth index (rest graph-data))))
                            (list link-template)))
                (if sub-index (rplacd (nth sub-index (rest (nth index (rest formatted))))
                                      (cons link-template
                                            (nthcdr (1+ sub-index)
                                                    (rest (nth index (rest formatted))))))
                    (rplacd (last (rest (nth index (rest formatted))))
                            (list link-template))))

              ;; delete a node or link
              (when (string= "deleteItem" (rest (assoc "action" input :test #'string=)))
                (if sub-index (rplaca (nth sub-index (rest (nth index orig-data)))
                                      (nth (1+ sub-index)
                                           (rest (nth index orig-data))))
                    (rplaca (nth index orig-data) (nth (1+ index) orig-data)))
                (if sub-index (rplaca (nth sub-index (rest (nth index formatted)))
                                      (nth (1+ sub-index)
                                           (rest (nth index formatted))))
                    (rplaca (nth index formatted) (nth (1+ index) formatted))))

              ;; shifting a node is the most complicated operation,
              ;; requiring that the graph be rebuilt
              (when (string= "shiftNode" (rest (assoc "action" input :test #'string=)))
                ;; add newest node index to end of indices
                (setf network-changed nil)
                ;; (print (list :bbb))
                (let* ((index-str (make-string-input-stream
                                   (rest (assoc "index" input :test #'string=))))
                       (pos-str (make-string-input-stream
                                 (rest (assoc "target" input :test #'string=))))
                       (indices (loop :for c := (read index-str nil) :while c :collect c))
                       (posx (loop :for c := (read pos-str nil) :while c :collect c))
                       (index (or (second indices) (first indices)))
                       (node-index (if (second indices) (first indices) nil))
                       (position (or (second posx) (first posx)))
                       (pos-parent (if (second posx) (first posx) nil)))
                  
                  (symbol-macrolet ((formatted2 (rest formatted))
                                    (graph-data2 (rest graph-data)))
                    ;; (print (list :ia index position input
                    ;;              node-index pos-parent
                    ;;              graph-data2 (rest orig-data)
                    ;;              formatted2))

                    (if node-index ;; links are being sorted
                        (when (= node-index pos-parent)
                          (let ((orig-link (nth index (rest (nth node-index graph-data2))))
                                (orig-flink (nth index (rest (nth node-index (rest orig-data))))))

                            ;; (print (list :oo orig-link
                            ;;              (nth node-index (rest orig-data))))
                            
                            (if (zerop index) (setf (rest (nth node-index (rest orig-data)))
                                                    (cddr (nth node-index (rest orig-data))))
                                (rplacd (nthcdr (1- index)
                                                (rest (nth node-index (rest orig-data))))
                                        (rest (nthcdr index (rest (nth node-index
                                                                       (rest orig-data)))))))

                            (if (zerop position) (setf (rest (nth node-index (rest orig-data)))
                                                       (cons orig-flink
                                                             (rest (nth node-index
                                                                        (rest orig-data)))))
                                (rplacd (nthcdr (1- position) (rest (nth node-index (rest orig-data))))
                                        (cons orig-flink
                                              (nthcdr position
                                                      (rest (nth node-index (rest orig-data)))))))

                            ;; (print (list :tt orig-data))
                            
                            (if (zerop index) (setf (cddr (nth node-index graph-data2))
                                                    (cdddr (nth node-index graph-data2)))
                                (rplacd (nthcdr (1- index)
                                                (cddr (nth node-index graph-data2)))
                                        (rest (nthcdr index (cddr (nth node-index
                                                                       graph-data2))))))
                            
                            (if (zerop position) (setf (cddr (nth node-index graph-data2))
                                                       (cons orig-link
                                                             (cddr (nth node-index
                                                                        graph-data2))))
                                (rplacd (nthcdr (1- position)
                                                (cddr (nth node-index graph-data2)))
                                        (cons orig-link
                                              (rest (nthcdr position
                                                            (cddr (nth node-index
                                                                       graph-data2)))))))
                            
                            ;; (if (zerop position) (setf graph-data2 (cons orig-link graph-data2))
                            ;;     (rplacd (nthcdr (1- position) graph-data2)
                            ;;             (cons orig-link (nthcdr position graph-data2))))

                            ;; (print (list :xyz orig-data graph-data formatted2))
                            
                            (labels ((lsort (form ix subix)
                                       ;; (print (list :fr form))
                                       (when (and (eq :index (caaar form))
                                                  (= ix (cdaar form)))
                                         (let ((olink (nth subix (rest form))))
                                           ;; (print (list :ol olink))
                                           (if (zerop index) (setf (rest form) (cddr form))
                                               (rplacd (nthcdr (1- subix) (rest form))
                                                       (rest (nthcdr subix (rest form)))))
                                           (if (zerop position)
                                               (setf (rest form)
                                                     (cons olink (rest form)))
                                               (rplacd (nthcdr (1- position) (rest form))
                                                       (cons olink (nthcdr position
                                                                           (rest form)))))))
                                       (loop :for item :in (rest form)
                                             :when (and (listp item) (second item)
                                                        (listp (second item)))
                                               :do ;; (print (list :ri
                                                   ;;              form
                                                   ;;              (rest item) (rest form)))
                                                   (lsort (rest item) ix subix))))
                              (loop :for item :in (rest formatted)
                                    :do (lsort item node-index index))
                              )))
                        ;; nodes are being sorted
                        (let ((original   (nth index (second indices-form)))
                              (orig-node  (nth index formatted2))
                              (orig-gnode (nth index graph-data2)))

                          (if (zerop index) (setf formatted2 (rest formatted2))
                              (rplacd (nthcdr (1- index) formatted2)
                                      (rest (nthcdr index formatted2))))

                          (if (zerop position) (setf formatted2 (cons orig-node formatted2))
                              (rplacd (nthcdr (1- position) formatted2)
                                      (cons orig-node (nthcdr position formatted2))))

                          (if (zerop index) (setf graph-data2 (rest graph-data2))
                              (rplacd (nthcdr (1- index) graph-data2)
                                      (rest (nthcdr index graph-data2))))

                          (if (zerop position) (setf graph-data2 (cons orig-node graph-data2))
                              (rplacd (nthcdr (1- position) graph-data2)
                                      (cons orig-node (nthcdr position graph-data2))))

                          (if (zerop index) (setf graph-data2 (rest orig-data))
                              (rplacd (nthcdr (1- index) orig-data)
                                      (rest (nthcdr index orig-data))))

                          (if (zerop position) (setf graph-data2 (cons orig-gnode orig-data))
                              (rplacd (nthcdr (1- position) orig-data)
                                      (cons orig-gnode (nthcdr position orig-data))))

                          ;; (print (list :odd orig-data))

                          (if (zerop index) (setf (second indices-form) (cdadr indices-form))
                              (rplacd (nthcdr (1- index) (second indices-form))
                                      (rest (nthcdr index (second indices-form)))))

                          (if (zerop position)
                              (setf (second indices-form) (cons original (second indices-form)))
                              (rplacd (nthcdr (1- position) (second indices-form))
                                      (cons original (nthcdr position
                                                             (second indices-form)))))
                          
                          (setf nodes-order (let* ((indices (second indices-form)))
                                              (make-array (length indices)
                                                          :initial-contents indices))
                                (from-system-file package file-name node-indices-key)
                                indices-form))))))

              (when (string= "connect" (rest (assoc "action" input :test #'string=)))
                (let ((this-index (read-from-string
                                   (rest (assoc "index" input :test #'string=)))))
                  ;; (print (list :ti this-index orig-data graph-data))
                  (labels ((relink (form new ix subix)
                             (if (and (eq :index (caaar form))
                                      (= ix (cdaar form)))
                                 (setf (second (nth (+ subix (if (eq :closed (second form)) 1 0))
                                                    (rest form)))
                                       new)
                                 (loop :for item :in (rest form)
                                       :when (and (listp item) (second item)
                                                  (listp (second item)))
                                         :do (relink (second item) new ix subix)))))

                    ;; (print (list :oo (second (nth sub-index
                    ;;                               (rest (nth index (rest orig-data)))))
                    ;;              sub-index
                    ;;              (nth sub-index (rest (nth index (rest graph-data))))))

                    (rplacd (nth sub-index (rest (nth index (rest orig-data))))
                            (list (aref nodes-order this-index)))
                    (rplacd (nth (1+ sub-index)
                                 (rest (nth index (rest graph-data))))
                            (list (aref nodes-order this-index)))
                    
                    (loop :for item :in (rest formatted)
                          :do (relink item (nth this-index (rest graph-data))
                                      index sub-index))))))

            (when network-changed
              ;; (print (list :ch "CHANGED" graph-base))
              (setf (from-system-file package file-name graph-key) graph-base)
              (instantiate-priority-macro-reader (asdf:load-system package)))
            
            ;; (print (list :af (assoc :face input :test #'eq)))
            ;; (print (list :ew el-width))
            ;; the output-stream is created in the seed package - best elsewhere?
            (if (and (assoc :face input :test #'eq)
                     (string= "graphNode" (rest (assoc :face input :test #'eq))))
                (progn
                  (render
                   (funcall context :medium)
                   (express (funcall (if network-changed
                                         #'list (lambda (items) `(meta ,items (:type :set :form))))
                                     (loop :for item :in (funcall
                                                          ;; nodes have an (index . N)
                                                          ;; form to omit, links don't
                                                          (if sub-index #'identity #'rest)
                                                          (first (if sub-index
                                                                     (nth sub-index
                                                                          (rest (nth index
                                                                                     (rest formatted))))
                                                                     (nth index (rest formatted)))))
                                           :collect item))))
                  (get-output-stream-string (seed.generate::uim-web-stream (funcall context :medium))))
                (if (or network-changed (assoc :system input))
                    (progn (setf *giface-output-stream* (make-string-output-stream))
                           ;; (print (list :nc input))
                           ;; (print (list :form formatted))
                           (eval `(cl-who:with-html-output (*giface-output-stream*)
                                    ,(seed.generate::svrender-graph
                                      (rest formatted)
                                      :width el-width :height el-height
                                      :point (list index sub-index)
                                      :id-string holder-id :branch-name graph-key)))
                           (let ((output (get-output-stream-string *giface-output-stream*)))
                             ;; (print (list :out output))
                             ;; (close output-stream)
                             output))
                    (list :oob-reload associated-node-ids))))))))

(defun svrender-graph (gmodel &key x-offset y-offset point branch-name id-string
                                (path-string "") (height 400) (width 400))
  (multiple-value-bind (nodes-markup y-offset)
      (svrender-layer gmodel :x-offset x-offset :y-offset y-offset :point point
                             :path-string path-string :height height :width width)
    (let ((branch-string (string branch-name))
          (branch-id (format nil "#branch-~a" id-string)))
      ;; (print (list :hi id-string point branch-string))
      `(:svg
        :class "svg-visualizer" :width ,width :height ,(max height y-offset)
        :x-init (psl (enable-drag $el))
        :x-data (psl (create open-node     (lambda (path)
                                             (fetch-contact
                                              "DEMO.SHEET" ,branch-string
                                              (create action "open" path path)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id "reload")))))
                             expand-node   (lambda (path)
                                             (fetch-contact
                                              "DEMO.SHEET" ,branch-string
                                              (create action "expand" path path)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id "reload")))))
                             contract-node (lambda (path)
                                             (fetch-contact
                                              "DEMO.SHEET" ,branch-string
                                              (create action "contract" path path)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id"reload")))))
                             connect-node  (lambda (index)
                                             (fetch-contact
                                              "DEMO.SHEET" ,branch-string
                                              (create action "connect" index index)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id "reload")))))
                             enable-drag   (lambda (svg)
                                             (let ((selected-element null) (dragging-link false)
                                                   (drag-node null) (dragging-index nil))
                                               (defun shift-node (index target)
                                                 (fetch-contact
                                                  "DEMO.SHEET" ,branch-string
                                                  (create action "shiftNode" index index target target)
                                                  (lambda (data)
                                                    (chain htmx (trigger ,branch-id "reload")))))
                                               
                                               (defun get-mouse-position (evt)
                                                 (let ((ctm (chain svg (get-screen-c-t-m))))
                                                   (create x (/ (- (@ evt client-x) (@ ctm e)) (@ ctm a))
                                                           y (/ (- (@ evt client-y) (@ ctm f)) (@ ctm d)))))
                                               
                                               (chain svg (add-event-listener
                                                           "mousedown"
                                                           (lambda (event)
                                                             (when (chain event target class-list
                                                                          (contains "draggable"))
                                                               (chain $el class-list (add "drag"))

                                                               (if (chain event target class-list
                                                                          (contains "for-node"))
                                                                   (chain $el class-list (add "for-node"))
                                                                   (progn (chain $el class-list
                                                                                 (add "for-link"))
                                                                          (setf dragging-link true)))
                                                               
                                                               (setf selected-element
                                                                     (chain event target parent-node
                                                                            (clone-node true))
                                                                     drag-node
                                                                     (@ event target parent-node
                                                                              parent-node parent-node)
                                                                     dragging-index
                                                                     (chain event target
                                                                            (get-attribute "index")))
                                                               
                                                               (chain drag-node class-list (add "dragging"))
                                                               (chain selected-element class-list
                                                                      (add "mouse-transparent"))
                                                               (chain svg (append-child selected-element))))))
                                               
                                               (chain svg (add-event-listener
                                                           "mousemove"
                                                           (lambda (event)
                                                             ;; (chain console (log :aa selected-element))
                                                             ;; (chain console (log :se drag-var))
                                                             (when (/= selected-element null)
                                                               (chain event (prevent-default))
                                                               (let ((coord (get-mouse-position event)))
                                                                 ;; (chain console (log :sel selected-element))
                                                                 (chain selected-element
                                                                        (set-attribute-n-s
                                                                         null "transform"
                                                                         (+ "translate(" (@ coord x)
                                                                            "," (@ coord y) ")"))))))))
                                               
                                               (chain svg (add-event-listener
                                                           "mouseup"
                                                           (lambda (event)
                                                             (when (/= selected-element null)
                                                               (when (chain event target class-list
                                                                            (contains "drag-target"))

                                                                 (if (and (not dragging-link)
                                                                          (chain event target class-list
                                                                                 (contains "for-node")))
                                                                     (shift-node dragging-index
                                                                                 (chain event target
                                                                                        (get-attribute
                                                                                         "index")))
                                                                     (if (and dragging-link
                                                                              (chain event target class-list
                                                                                     (contains "for-link")))
                                                                         (shift-node dragging-index
                                                                                     (chain event target
                                                                                            (get-attribute
                                                                                             "index")))))
                                                                 ;; (chain console
                                                                 ;;        (log :ii dragging-index
                                                                 ;;             (chain event target
                                                                 ;;                    (get-attribute
                                                                 ;;                     "index")
                                                                 ;;                    )))
                                                                 )
                                                               (chain $el class-list (remove "drag"))
                                                               (chain $el class-list (remove "for-node"))
                                                               (chain $el class-list (remove "for-link"))
                                                               (setf dragging-link false)
                                                               (chain selected-element (remove))
                                                               (chain drag-node class-list
                                                                      (remove "dragging"))
                                                               (setf selected-element null
                                                                     drag-node null)))))
                                               (chain svg (add-event-listener
                                                           "mouseleave"
                                                           (lambda ()
                                                             (when (/= selected-element null)
                                                               (chain $el class-list (remove "drag"))
                                                               (chain $el class-list (remove "for-node"))
                                                               (chain $el class-list (remove "for-link"))
                                                               (setf dragging-link false)
                                                               (chain selected-element (remove))
                                                               (chain drag-node class-list (remove "dragging"))
                                                               (setf selected-element null
                                                                     drag-node null)))))))))
        ,@nodes-markup))))

(let ((x-start 10) (y-start 30) (x-increment 40) (y-increment 40)
      (expander-code   (psl (expand-node   (chain $el (get-attribute "path")))))
      (contracter-code (psl (contract-node (chain $el (get-attribute "path")))))
      (opener-code (psl (open-node (chain $el (get-attribute "index")))))
      (connector-code (psl (connect-node (chain $el (get-attribute "index"))))))
  (flet ((meta-strip (form)
           (loop :for item :in form :collect (if (not (string= "META" (string (first item))))
                                                 item (second item)))))
    (defun svrender-layer (gmodel &key x-offset y-offset parent point (path-string "")
                                    (height 400) (width 400) (depth 1)
                                    (depth-store (cons :depth 0)))
      (let ((y-offset (or y-offset y-start)) (x-offset (or x-offset x-start))
            (main-radius 16) (output) (link-specs) (l2-specs) (interval (/ (- width 350))))
        ;; (print (list :gg gmodel))
        (setf (rest depth-store)
              (max depth (rest depth-store)))
        (loop :for item :in gmodel :for ix :from 0 :when (listp item)
              :do (let* ((is-expandable (or (and (eq :closed (second item))
                                                 (second item))
                                            (and (listp (second item))
                                                 (caadr item))
                                            (and (numberp (second item))
                                                 (second item))))
                         (is-root (zerop (length path-string)))
                         (is-closed (or (eq :closed is-expandable)
                                        (numberp is-expandable)))
                         (path-string (if is-root (format nil "~a"  ix)
                                          (format nil "~a ~a" path-string ix)))
                         (title (rest (assoc :title (meta-strip (first item)))))
                         (num-index (rest (assoc :index (first item))))
                         (is-link (not num-index))
                         (index (or num-index (format nil "~a ~a" (third parent) ix)))
                         (group-class (format nil "node-group~a~a"
                                              (if (or (and (not (second point))
                                                           (and num-index (= index (first point))))
                                                      (and (second point)
                                                           (= ix (second point))
                                                           (numberp (third parent))
                                                           (= (third parent) (first point))))
                                                  " selected" "")
                                              (if is-link " link-group" ""))))
                    (push `(:g :class ,group-class
                               :transform ,(format nil "translate(~a,~a)" x-offset y-offset)
                               (:g :class "title-frame"
                                   :transform ,(format nil "translate(36,-12)")
                                   (:rect :x 0 :y 0 :height 24 :rx 12
                                          :|x-on:click| ,opener-code :index ,index
                                          ,@(if (not (or is-root (and is-link (/= 1 (length gmodel)))))
                                                nil (list :class (format nil "drag-target ~a"
                                                                         (if is-root "for-node"
                                                                             "for-link"))))
                                          :width ,(- width x-offset 36 20))
                                   ,@(if (not (or is-root (and is-link (/= 1 (length gmodel)))))
                                         nil `((:g :class "handle" ;; drag control
                                                   :transform ,(format nil "translate(~a,12)"
                                                                       (- width x-offset 52 40))
                                                   (:circle :class "main"   :cx 0 :cy 0 :r 9)
                                                   (:circle :class "center" :cx 0 :cy 0 :r 2)
                                                   (:path :class "arrow" :d "M-3,-3 0,-6 3,-3")
                                                   (:path :class "arrow" :d "M-3,3 0,6 3,3")
                                                   (:path :class "outer-arrow"
                                                          :d "M-6,-6 0,-12 6,-6")
                                                   (:path :class "outer-arrow"
                                                          :d "M-6,6 0,12 6,6")
                                                   (:circle :class ,(format nil "draggable ~a"
                                                                            (if is-root "for-node"
                                                                                "for-link"))
                                                            :index ,index :cx 0 :cy 0 :r 10 :opacity 0 ))))
                                   ,@(if (not (and num-index (second point))) ;; linking control
                                         nil `((:g :class "linker"
                                                   :transform ,(format nil "translate(~a,12)"
                                                                       (- width x-offset 32 40))
                                                   (:circle :class "main"   :cx 0 :cy 0 :r 9)
                                                   (:circle :class "center" :cx 0 :cy 0 :r 2)
                                                   (:path :class "arrow" :d "M-3,6 3,0 -3,-6 -3,6")
                                                   (:circle :index ,num-index :cx 0 :cy 0 :r 10
                                                            :opacity 0 :|x-on:click| ,connector-code))))
                                   (:g :class "description"
                                       :index ,index (:text :y 16
                                                            :x ,(if is-expandable 26 6) ,title)))
                               (:g :class "circle-glyph" :index ,index
                                   (:circle :class "outer-circle" :cx 16 :cy 0 :r ,main-radius)
                                   (:circle :class "inner-circle" :cx 16 :cy 0 :r 12))
                               ,@(if (not is-expandable)
                                     nil `((:g :class "expand-control" :path ,path-string
                                               :|x-on:click| ,(if is-closed expander-code contracter-code)
                                               (:circle :class "button-backing" :cx 48 :cy 0 :r 10)
                                               (:circle :class "button-circle"  :cx 48 :cy 0 :r 8)
                                               (:rect :class "indicator" :x 43.5 :y -1.5 :height 3 :width 9)
                                               ,@(if (not is-closed)
                                                     nil `((:rect :class "indicator" :x 46.5 :y -4.5
                                                                  :height 9 :width 3))))))
                               ,@(if (not (or is-root (and is-link (/= 1 (length gmodel)))))
                                     nil `((:rect :x 32 :y -17 :height 3 :width ,(- width x-offset 36 28)
                                                  :rx 1 :class ,(format nil "drag-indicator ~a"
                                                                        (if is-root "for-node"
                                                                            "for-link"))))))
                          output)
                    
                    (when parent (destructuring-bind (parent-x parent-y &rest _) parent
                                   (let ((mid-x (+ parent-x (* 0.5 (- x-offset parent-x)))))
                                     (push `(:path :class "link"
                                                   :d ,(format nil "M~a,~aC~a,~a,~a,~a,~a,~a"
                                                               parent-x parent-y mid-x parent-y
                                                               mid-x y-offset x-offset y-offset))
                                           link-specs)
                                     (push (list parent-x parent-y)
                                           l2-specs))))
                    ;; (print (list :si parent (second item)))
                    (if (and (rest item) (listp (second item))
                             (not (eq :closed (caadr item))))
                        (multiple-value-bind (out-list new-y-offset new-link-specs)
                            (svrender-layer
                             (rest item) :x-offset (+ x-increment x-offset)
                             :y-offset (+ y-increment y-offset) :depth (1+ depth)
                             :height height :width width :point point :depth-store depth-store
                             :path-string path-string :parent (list x-offset y-offset index))
                          (setf output     (append out-list output)
                                link-specs (append new-link-specs link-specs)
                                y-offset   new-y-offset))
                        (incf y-offset y-increment))))
        ;; (print (list :dep depth-store))
        (flet ((build-link (spec)
                 (destructuring-bind (parent-x parent-y) spec
                   (let ((mid-x (+ parent-x (* 0.5 (- x-offset parent-x)))))
                     (list :path :class "link"
                                 :d (format nil "M~a,~aC~a,~a,~a,~a,~a,~a"
                                            parent-x parent-y mid-x parent-y
                                            mid-x y-offset x-offset y-offset))))))
          (values (if (not (zerop (length path-string)))
                      ;; link specs are appended at the final stage, the reversal causes
                      ;; them to be drawn first so they'll be underneath the node graphics
                      output (reverse (append output link-specs)))
                  y-offset link-specs))))))

(defun graph-walker (graph)
  (let ((primary (first graph))
        (options (mapcar #'first (rest graph))))
    (values (list primary options)
            (lambda (index) (graph-walker (second (nth index (rest graph))))))))

;; (defun render-console (form &key branch)
;;   "Render a 'console'; a set of fields that independently update the server state when changed as opposed to requiring a specific 'submit' action to update all field values."
;;   (htrender form :input-processor (lambda (item)
;;                                     (let ((item-name (getf (cdar item) :name)))
;;                                       (list (append (first item)
;;                                                     (list :hx-post "/render/"
;;                                                           :id (format nil "branch-~a"
;;                                                                       (lisp->camel-case branch))
;;                                                           :hx-vals (json-convert-to
;;                                                                     (list :system :portal.demo1
;;                                                                           :branch branch
;;                                                                           :name item-name)))))))
;;             :branch branch))

;; (defun htrender (form &key branch input-processor form-parameters params)
;;   ;; (print (list :fo form))
;;   (if (listp (first form))
;;       (cons :div (loop :for f :in form :collect (htrender f :input-processor input-processor
;;                                                             :form-parameters form-parameters
;;                                                             :params params)))
;;       (destructuring-bind (_ item &rest props) form
;;         (let ((title (rest (assoc :title props)))
;;               (name (rest (assoc :name props)))
;;               (type (rest (assoc :type props)))
;;               (input-processor (or input-processor #'identity))
;;               (system (getf params :system))
;;               (branch (getf params :branch)))
;;           (labels ((build-elem (class item &optional multiple)
;;                      `(:div :class ,class ,@(if (not title) nil `((:span :class "title" ,title)))
;;                             ,@(funcall (if (and (listp item) (not multiple))
;;                                            input-processor #'identity)
;;                                        (if (and multiple (listp item))
;;                                            item (list item))))))
;;             ;; (print (list :sys system item))
;;             (case (first type)
;;               (:set (case (second type)
;;                       (:form
;;                        (if (not system)
;;                            `(:div ,@(loop :for sub-item :in item
;;                                           :append (let ((output (htrender sub-item :params params)))
;;                                                     (if (not output) nil (list output)))))
;;                            `(:form :hx-post "/render/"
;;                                    :hx-trigger "reload consume, submit"
;;                                    :class "xp-form"
;;                                    :x-data ,(psl (create this-form $el action "formSubmit"))
;;                                    ;; :x-init ,(psl (progn (if (not (= "undefined" (typeof push-form)))
;;                                    ;;                          (push-form $el local-forms))))
;;                                    :hx-vals ,(json-convert-to
;;                                               (list :system (string-upcase system)
;;                                                     :branch (string-upcase branch)
;;                                                     :action :form-submit))
;;                                    ,@(funcall (case (third type)
;;                                                 (:tabular
;;                                                  (lambda (form)
;;                                                    (list
;;                                                     (cons :table
;;                                                           (loop :for row :in item
;;                                                                 :collect
;;                                                                 (cons :tr (loop :for cell :in row
;;                                                                                 :collect
;;                                                                                 (list :td (htrender
;;                                                                                            cell :params
;;                                                                                            params)))))))))
;;                                                 (t (lambda (form)
;;                                                      (loop :for item :in form
;;                                                            :collect (htrender item :params params)))))
;;                                               item))))
;;                       ;; (:form (htrender
;;                       ;;         item :form-parameters :params params
;;                       ;;         (list :hx-post "/render/"
;;                       ;;               :hx-vals (json-convert-to
;;                       ;;                         (list :system (string-upcase system)
;;                       ;;                               :branch (string-upcase branch))))))
;;                       (:table (cons :table
;;                                     (loop :for row :in item
;;                                           :collect (cons :tr (loop :for cell :in row
;;                                                                    :collect (list :td (htrender
;;                                                                                        cell
;;                                                                                        :params params)))))))))
;;               ;; (:field
;;               ;;  (let ((labeled  (member :labeled (rest type) :test #'eq))
;;               ;;        (is-block (member :block   (rest type) :test #'eq))
;;               ;;        (name (symbol-munger:lisp->camel-case (if (not (member :pair (rest type)
;;               ;;                                                               :test #'eq))
;;               ;;                                                  name (first item)))))
;;               ;;    (if (member :pair (rest type) :test #'eq)
;;               ;;        `(:div :class ,(format nil "ui ~a~ainput" (if labeled "labeled " "")
;;               ;;                               (if is-block "fluid " ""))
;;               ;;               ,@(if labeled `((:div :class "ui label" ,name)))
;;               ;;               (:input :type "text" :name ,name :value ,(rest item)))
;;               ;;        (build-elem "ui input" (list :input :type "text"
;;               ;;                                            :name (symbol-munger:lisp->camel-case name)
;;               ;;                                            :value item)))))
;;               (:field
;;                (let ((labeled  (member :labeled (rest type) :test #'eq))
;;                      (is-block (member :block   (rest type) :test #'eq))
;;                      (name (symbol-munger:lisp->camel-case (if (not (member :pair (rest type)
;;                                                                             :test #'eq))
;;                                                                name (first item)))))
;;                  (if (member :pair (rest type) :test #'eq)
;;                      `(:div :class ,(format nil "field~a" (if is-block " has-addons" ""))
;;                             ,@(if labeled `((:div :class "control" (:div :class "button is-static" ,name))))
;;                             (:div :class "control"
;;                                   (:input :class "input" :type "text" :name ,name :value ,(rest item))))
;;                      (build-elem "input" (list :input :type "text"
;;                                                       :name (symbol-munger:lisp->camel-case name)
;;                                                       :value item)))))
;;               (:code-area
;;                (let ((labeled  (member :labeled (rest type) :test #'eq))
;;                      (is-block (member :block   (rest type) :test #'eq))
;;                      (name (symbol-munger:lisp->camel-case (if (not (member :pair (rest type)
;;                                                                             :test #'eq))
;;                                                                name (first item)))))
;;                  `(:div ;; :class (getf props :item-classes)
;;                    :id "abc"
;;                    :x-init ,(psl (progn (setf (@ window codemirror) nil)
;;                                        (setf (getprop (@ window seed-elements) (lisp branch)) $el)
;;                                        (setf (getprop (@ window seed-data) (lisp "abc"))
;;                                              (create-codemirror
;;                                               (chain document (get-element-by-id (lisp "abc")))
;;                                               (lisp (rest item)))))))))
;;               (:select (case (second type)
;;                          (:dropdown
;;                           (let ((title (rest (assoc :title props)))
;;                                 (options (rest (assoc :options props)))
;;                                 (action (rest (assoc :action props))))
;;                             ;; `(:div :class "ui labeled button dropdown"
;;                             ;;        (:span :class "text" ,name)
;;                             ;;        (:div :class "menu"
;;                             ;;              ,@(if (not (eq action :branch-reload))
;;                             ;;                    nil (list :|x-on:change|
;;                             ;;                              (psl (progn
;;                             ;;                                     (chain console (log this-form))
;;                             ;;                                     (chain htmx (trigger this-form "submit"))))))
;;                             ;;              ,@(loop :for o :in options
;;                             ;;                      :collect `(:option :value ,o
;;                             ;;                                         ,@(if (not (string= o item))
;;                             ;;                                               nil `(:selected 1))
;;                             ;;                                         ,o)))
;;                             `(:select :class "ui selection dropdown"
;;                                :name ,name
;;                                ,@(if (not (eq action :branch-reload))
;;                                      nil (list :|x-on:change|
;;                                                (psl (progn
;;                                                       (chain console (log this-form))
;;                                                       (chain htmx (trigger this-form "submit"))))))
;;                                ,@(loop :for o :in options
;;                                        :collect `(:option :value ,o
;;                                                           ,@(if (not (string= o (rest item)))
;;                                                                 nil `(:selected 1))
;;                                                           ,o)))
;;                             ))))
;;               (:trigger `(:button :class "ui button" ,title))
;;               (:boolean `(:button :class "ui button" ,title))
;;               (:submit-control `(:button :class "ui button" :type "submit" "Submit"))))))))


;; `(:div :class "ui vertical menu"
;;        (:div :class "ui dropdown item"
;;              ,(rest (assoc :title props))
;;              (:i :class "dropdown icon")
;;              (:div :class "menu"
;;                    ,@(loop :for o :in options
;;                            :collect `(:a :class "item" ,o)))))

(defmacro setf-value (form)
  `(third ,form))

(defmacro of-array-spec (key spec)
  (if (eq :shape key) `(second ,spec)
      `(getf (cddr ,spec) ,key)))

;; SECTION: branch specs for rendering main branch interfaces

;; (defun branch-spec-form (stream-out section &rest props)
;;   (let ((system (getf props :system))
;;         (branch (getf props :branch))
;;         (face (lisp->camel-case (getf props :name))))
;;     (case section
;;       (:body (cl-who:with-html-output (stream-out)
;;                (:form :class "container" :hx-post "/render/" :hx-trigger "load, reload consume, submit"
;;                       :x-init (psl (progn ;; (push-form $el local-forms)
;;                                           (setf (getprop (@ window seed-elements) (lisp face))
;;                                                 $el)))
;;                       :id (format nil "branch-~a" face)
;;                       :x-data (psl (create branch-frame $el))
;;                       :hx-vals (json-convert-to (list :system system :branch branch
;;                                                       :action :form-submit :face face)))))
;;       (:body-svg (let ((this-id (format nil "branch-~a" face)))
;;                    (cl-who:with-html-output (stream-out)
;;                      (:div :hx-post "/render/" :hx-trigger "load, reload consume"
;;                            :class "sub-container"
;;                            :x-init (psl (progn (setf (getprop (@ window seed-elements) (lisp face)) $el)
;;                                                (fetch-contact (lisp (string-upcase (getf props :system)))
;;                                                               (lisp (string-upcase (getf props :branch)))
;;                                                               (create height (@ $el offset-height)
;;                                                                       width  (@ $el offset-width))
;;                                                               (lambda (data)
;;                                                                 (chain console (log :dt data
;;                                                                                     (@ $el offset-height)))
;;                                                                 ))))
;;                            :hx-vals (json-convert-to (list :system system :branch branch :face face))
;;                            :id this-id :x-data (psl (create branch-frame $el))))))
;;       (:control
;;        (case (getf props :subsection)
;;          (:submit (cl-who:with-html-output (stream-out)
;;                     (:button :class "ui button"
;;                              :|x-on:click| (psl (submit-forms))
;;                              (str (string-downcase (getf props :subsection))))))
;;          (:save (cl-who:with-html-output (stream-out)
;;                   (:button :class "ui button"
;;                            :|x-on:click| (psl (submit-forms))
;;                            (str (string-downcase (getf props :subsection))))))
;;          (:add-node (cl-who:with-html-output (stream-out)
;;                       (:button :class "ui button"
;;                                :|x-on:click|
;;                                (psl (fetch-contact (lisp (string-upcase (getf props :system)))
;;                                                    (lisp (string-upcase (getf props :branch)))
;;                                                    (create action "addNode")
;;                                                    (lambda (data)
;;                                                      (chain console (log :dt data (@ $el offset-height)))
;;                                                      (chain htmx (trigger (lisp (format nil "#branch-~a"
;;                                                                                         face))
;;                                                                           "reload"))
;;                                                      ;; (chain htmx (trigger "#main" "reload"))
;;                                                      )))
;;                                (str (string-downcase (getf props :subsection))))))
;;          (:add-link (cl-who:with-html-output (stream-out)
;;                       (:button :class "ui button"
;;                                :|x-on:click|
;;                                (psl (fetch-contact (lisp (string-upcase (getf props :system)))
;;                                                    (lisp (string-upcase (getf props :branch)))
;;                                                    (create action "addLink")
;;                                                    (lambda (data)
;;                                                      (chain console (log :dt data (@ $el offset-height)))
;;                                                      (chain htmx (trigger (lisp (format nil "#branch-~a"
;;                                                                                         face))
;;                                                                           "reload"))
;;                                                      )))
;;                                (str (string-downcase (getf props :subsection))))))
;;          (:delete-item
;;           (cl-who:with-html-output (stream-out)
;;             (:button :class "ui button"
;;                      :|x-on:click|
;;                      (psl (fetch-contact (lisp (string-upcase (getf props :system)))
;;                                          (lisp (string-upcase (getf props :branch)))
;;                                          (create action "deleteItem")
;;                                          (lambda (data)
;;                                            (chain console (log :dt data (@ $el offset-height)))
;;                                            (chain htmx (trigger (lisp (format nil "#branch-~a"
;;                                                                               face))
;;                                                                 "reload"))
;;                                            ;; (submit-forms)
;;                                            )))
;;                      (str (string-downcase (getf props :subsection)))))))))))

;; (defun branch-spec-codemirror-editor (stream-out section &rest props)
;;   (let ((token (format nil "cm-texteditor-~a-~a"
;;                        (string-downcase (getf props :system))
;;                        (string-downcase (getf props :branch))))
;;         (branch (string-downcase (getf props :branch))))
;;     (case section
;;       (:body (cl-who:with-html-output (stream-out)
;;                (:div :id (lisp token) :class (getf props :item-classes)
;;                      :x-init (psl (progn (setf (@ window codemirror) nil)
;;                                          (setf (getprop (@ window seed-elements) (lisp branch)) $el)
;;                                          (fetch-contact (lisp (string-upcase (getf props :system)))
;;                                                         (lisp (string-upcase (getf props :branch)))
;;                                                         nil (lambda (data) 
;;                                                               ;; (chain console (log :dt (@ data text)))
;;                                                               (setf (getprop (@ window seed-data)
;;                                                                              (lisp token))
;;                                                                     (create-codemirror
;;                                                                      (chain document
;;                                                                             (get-element-by-id (lisp token)))
;;                                                                      (@ data text))))))))))
;;       (:control
;;        (case (getf props :subsection)
;;          (:save (cl-who:with-html-output (stream-out)
;;                   (:button :class "ui button"
;;                            :|x-on:click|
;;                            ;; (psl (fetch-contact (lisp (string-upcase (getf props :system)))
;;                            ;;                     (lisp (string-upcase (getf props :branch)))
;;                            ;;                     (@ (getprop (@ window seed-data)
;;                            ;;                                 (lisp token))
;;                            ;;                        state doc text)
;;                            ;;                     ;; (@ window codemirror state doc text)
;;                            ;;                     (lambda (data) (chain console (log :sv)))))
;;                            (psl (fetch-contact2 context $el (create text (@ (getprop (@ window seed-data)
;;                                                                                      (lisp token))
;;                                                                             state doc text))))
;;                            (str (string-downcase (getf props :subsection)))))))))))

;; (defun branch-spec-cvdatagrid-sheet (stream-out section &rest props)
;;   (let ((token (format nil "canvas-datagrid-~a-~a"
;;                        (string-downcase (getf props :system))
;;                        (string-downcase (getf props :branch))))
;;         (branch (string-downcase (getf props :branch)))
;;         (mode (getf props :mode)))
;;     (case section
;;       (:body (cl-who:with-html-output (stream-out)
;;                (:div :id "datagrid-cells" :class (getf props :item-classes)
;;                      :x-init
;;                      (psl (progn (setf (getprop (@ window seed-elements) (lisp branch)) $el)
;;                                  (fetch-contact
;;                                   (lisp (string-upcase (getf props :system)))
;;                                   (lisp (string-upcase (getf props :branch)))
;;                                   nil (lambda (data)
;;                                         ;; (chain console (log :dd data))
;;                                         (let ((grid (canvas-datagrid (create style (create cell-width 60)))))
;;                                           (chain document (get-element-by-id "datagrid-cells")
;;                                                  (append-child grid))
;;                                           (setf (@ grid data) (@ data ct)
;;                                                 (getprop (@ window seed-data) (lisp token))
;;                                                 grid)))))))))
;;       (:control
;;        (case (getf props :subsection)
;;          (:save (cl-who:with-html-output (stream-out)
;;                   (:button :class "ui button"
;;                            :|x-on:click|
;;                            (psl (fetch-contact (lisp (string-upcase (getf props :system)))
;;                                                (lisp (string-upcase (getf props :branch)))
;;                                                (@ (getprop (@ window seed-data) (lisp token))
;;                                                   data)
;;                                                (lambda (data) (chain console (log :sv)))))
;;                            (str (string-downcase (getf props :subsection))))))
;;          (:toggle-baseline
;;           (cl-who:with-html-output (stream-out)
;;             (:button :class "ui button"
;;                      :|x-on:click|
;;                      (psl (fetch-contact (lisp (string-upcase (getf props :system)))
;;                                          (lisp (string-upcase (getf props :branch)))
;;                                          (create toggle-baseline t)
;;                                          (lambda (data) (chain console (log :tb)))))
;;                      (str (string-downcase (getf props :subsection)))))))))))

;; (defmacro build-directed-graph (&rest nodes)
;;   (let ((n (gensym)) (link (gensym)) (nodes-out (gensym)))
;;     `(let ((,nodes-out (list ,@(loop :for node :in nodes
;;                                      :collect (list 'list (cons 'list (mapcar (lambda (i)
;;                                                                                 (print (list :ii i))
;;                                                                                 (if (listp (rest i))
;;                                                                                     (cons 'list i)
;;                                                                                     (list 'cons (first i)
;;                                                                                           (rest i))))
;;                                                                               (first node)))
;;                                                     `(list (list ,@(mapcar (lambda (i)
;;                                                                              (if (listp (rest i))
;;                                                                                  (cons 'list i)
;;                                                                                  (list 'cons (first i)
;;                                                                                        (rest i))))
;;                                                                            (caadr node)))
;;                                                            ,(cadadr node)))))))
;;        (loop :for ,n :in ,nodes-out
;;              :do (loop :for ,link :in (rest ,n)
;;                        :do (rplacd ,link (list (nth (second ,link) ,nodes-out)))))
;;        ,nodes-out)))

;; (defun dgraph-interface (dgraph interface orig-indices &key path to-open at-path)
;;   ;; (print (list :ii interface))
;;   (if (rest path)
;;       (setf (nth (first path) (rest interface))
;;             (dgraph-interface dgraph (print (nth (first path) (rest interface)))
;;                               orig-indices :path (rest path) :to-open to-open :at-path at-path))
;;       (let ((point (nth (first path) (rest interface)))
;;             (output (cons (first interface) (rest interface))))
;;         (setf (nth (first path) (rest output))
;;               (if (listp (second point))
;;                   (cons (first point)
;;                         (if at-path (rest point)
;;                             (loop :for item :in (rest point)
;;                                   :collect (if (not (and (listp item) (eq :closed (first item))))
;;                                                item (second item)))))
;;                   (let ((index (second point)))
;;                     (list (first point)
;;                           (nth (aref orig-indices index) (rest dgraph)))))
;;               interface output)))
;;   interface)

;; (defun dgraph-interface (dgraph interface orig-indices &key path to-open at-path)
;;   (print (list :ii interface))
;;   (if path
;;       (progn (setf (nth (first path) (rest interface))
;;                    (dgraph-interface dgraph (nth (first path) (rest interface))
;;                                      orig-indices :path (rest path) :to-open to-open :at-path at-path))
;;              interface)
;;       (if (listp (second interface))
;;           (cons (first interface)
;;                 (if at-path (rest interface)
;;                     (loop :for item :in (rest interface)
;;                           :collect (if (not (and (listp item) (eq :closed (first item))))
;;                                        item (second item)))))
;;           (let ((index (second interface)))
;;             (setf (second interface) (nth (aref orig-indices index) (rest dgraph)))
;;             interface))))

;; (defun dgraph-interface (dgraph interface orig-indices &key path to-open at-path)
;;   (print (list :ii interface))
;;   (if path (setf (nth (first path) (rest interface))
;;                  (dgraph-interface dgraph (nth (first path) (rest interface))
;;                                     orig-indices :path (rest path) :to-open to-open :at-path at-path))
;;       (if (listp (second interface))
;;           (cons (first interface)
;;                 (if at-path (rest interface)
;;                     (loop :for item :in (rest interface)
;;                           :collect (if (not (and (listp item) (eq :closed (first item))))
;;                                        item (second item)))))
;;           (let ((index (second interface)))
;;             (setf (second interface) (nth (aref orig-indices index) (rest dgraph)))
;;             interface))))

;; (destructuring-bind (open-index &rest rest-indices) path
;;   (let ((point (nth open-index interface)))
;;     (print (list :po point dgraph))
;;     ;; next-interface
;;     (if rest-indices
;;         (progn (setf (nth open-index interface)
;;                      (cons (first point)
;;                            (dgraph-interface dgraph (rest point) orig-indices
;;                                              :path rest-indices :to-open to-open :at-path at-path)))
;;                interface)
;;         (if (listp point)
;;             (if to-open ;; (list (if (not (eq :closed (first point)))
;;                         ;;           point (second point)))
;;                 (if (not (eq :closed (first point)))
;;                     (list point)
;;                     (mapcar #'second interface))
;;                 (if at-path (funcall at-path point)
;;                     (list (list :closed point))))
;;             (if (numberp point)
;;                 (list (funcall (lambda (form) (if (not (eq :closed (first form)))
;;                                                   form (second form)))
;;                                (print (nth (aref orig-indices point)
;;                                            dgraph))))))))))

;; (defun dgraph-interface (dgraph interface orig-indices &key path to-open at-path)
;;   (destructuring-bind (open-index &rest rest-indices) path
;;     (let ((point (nth open-index interface)))
;;       (print (list :po point dgraph))
;;       ;; next-interface
;;       (if rest-indices
;;           (progn (setf (nth open-index interface)
;;                        (cons (first point)
;;                              (dgraph-interface dgraph (rest point) orig-indices
;;                                                :path rest-indices :to-open to-open :at-path at-path)))
;;                  interface)
;;           (if (listp point)
;;               (if to-open ;; (list (if (not (eq :closed (first point)))
;;                           ;;           point (second point)))
;;                   (if (not (eq :closed (first point)))
;;                       (list point)
;;                       (mapcar #'second interface))
;;                   (if at-path (funcall at-path point)
;;                       (list (list :closed point))))
;;               (if (numberp point)
;;                   (list (funcall (lambda (form) (if (not (eq :closed (first form)))
;;                                                     form (second form)))
;;                                  (print (nth (aref orig-indices point)
;;                                              dgraph))))))))))

;; (defun dgraph-interface2 (interface &key root path to-open at-path)
;;   (destructuring-bind (open-index &rest rest-indices) path
;;     (let ((point (nth open-index interface)))
;;       ;; next-interface
;;       ;; (print (list :rr interface (nth open-index interface) rest-indices))
;;       (print (list :po point))
;;       (if rest-indices
;;           (progn (setf (nth open-index interface)
;;                        (cons (first point)
;;                              (dgraph-interface2 (rest point) :root (or root interface)
;;                                                 :path rest-indices
;;                                                 :to-open to-open :at-path at-path)))
;;                  interface)
;;           (if (listp point)
;;               (if to-open (list (if (not (eq :closed (first point)))
;;                                     point (second point)))
;;                   (if at-path (funcall at-path point)
;;                       (list (list :closed point))))
;;               (if (numberp point)
;;                   (list (funcall (lambda (form) (if (not (eq :closed (first form)))
;;                                                     form (second form)))
;;                                  (nth point root)))))))))

#|

(render-web (uispec (:head "Hello")))

(render-web (uispec (:frame :type (:stack :sidebar)
                            (:head "Hello")
                            (:para "More stuff."))))

(uispec (:set (:series)
              (:set (:frame))
              (:set (:frame))))

|#

;; (dgraph-interface iii bla :open-path '(0 0))
;; (dgraph-interface iii bla :open-path '(1 0 0))

;; (defun of-graph-spec (spec &optional index)
;;   (labels ((alist-to-plist (form)
;;              (loop :for item :in form
;;                    :append (list (first item)
;;                                  (if (not (third item))
;;                                      (second item) (rest item)))))
;;            (listing-format (form)
;;              (append (alist-to-plist (first form))
;;                      (list :children (loop :for link :in (rest form)
;;                                            :collect (append (alist-to-plist (first link))
;;                                                             (list :to (second link))))))))
;;     (if index (listing-format (nth index (rest spec)))
;;         (list :title "root" 
;;               :children (mapcar #'listing-format (rest spec))))))

;; (defun graph-spec-to-json (spec &optional index)
;;   (let ((stream (make-string-output-stream)))
;;     (flet ((listing-format (form)
;;              (com.inuoe.jzon:with-object*
;;                (com.inuoe.jzon:write-key* :data)
;;                (alist-to-json (first form) stream)
;;                (com.inuoe.jzon:write-key* :children)
;;                (com.inuoe.jzon:with-array*
;;                  (loop :for link :in (rest form)
;;                        :do (com.inuoe.jzon:with-object*
;;                              (com.inuoe.jzon:write-key* :data)
;;                              (alist-to-json (rest link) stream)
;;                              (com.inuoe.jzon:write-key* :to)
;;                              (com.inuoe.jzon:write-value* (first link))))))))
;;       (com.inuoe.jzon:with-writer* (:stream stream :pretty nil)
;;         (if index (listing-format (nth index (rest spec)))
;;             (com.inuoe.jzon:with-object*
;;               (com.inuoe.jzon:write-key* :data)
;;               (alist-to-json '((:title "root")) stream)
;;               (com.inuoe.jzon:write-key* :children)
;;               (com.inuoe.jzon:with-array*
;;                 (mapcar #'listing-format (rest spec))))))
;;       (get-output-stream-string stream))))

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
