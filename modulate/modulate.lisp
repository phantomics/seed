;;;; seed.modulate.lisp
(in-package #:seed.modulate)

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

(defmacro psl (form)
  "A macro for denoting inline Parenscript code."
  `(subseq (parenscript:ps-inline ,form) 11))

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

(defclass uic-chart (ui-component)
  ((%points :accessor uic-chart-points
            :initform nil
            :initarg  :points)))

(defclass uich-candle (uic-chart)
  ())

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
  (let* ((out-stream (make-string-output-stream))
         (spinneret:*html* out-stream))
    (spinneret:interpret-html-tree (generate medium component))
    (values (get-output-stream-string out-stream)
            (close out-stream))))

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
        (setf ojoin (alist-supersede new-list ojoin)
              (uic-join aspect) ojoin))
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
                            
(defmethod generate ((medium uim-web) (aspect uicc-text))
  ;; (print (list :ee medium (uic-type aspect)))
  (flet ((wrap-label (label base) `(:div (:h2 ,label) ,base)))
    (let ((base (uic-base aspect)))
      (cond ((member :code (uic-type aspect))
             (destructuring-bind (system branch) (uic-base aspect)
               (let ((token (format nil "cm-texteditor-~a-~a" (string-downcase system)
                                    (string-downcase branch))))
                 `(:div :id ,token ;; :class ,(uic-type aspect)
                        :x-init ,(psl (progn (setf (@ window codemirror) nil)
                                             (setf (getprop (@ window seed-elements) (lisp branch))
                                                   $el)
                                             (fetch-contact (lisp (string system))
                                                            (lisp (string branch))
                                                            (list (list "text" 0))
                                                            ;; nil
                                                            ;; ,(string-upcase (getf props :branch))
                                                            (lambda (data) 
                                                              ;; (chain console (log :dt (@ data text)))
                                                              (setf (getprop (@ window seed-data)
                                                                             (lisp token))
                                                                    (create-codemirror
                                                                     (chain document (get-element-by-id
                                                                                      (lisp token)))
                                                                     (@ data text)))))))))))
            ((member :area (uic-type aspect))
             `(:textarea :class "input" :name ,(or (string (uicc-key aspect)) "")
                         ,(or (uicc-text-default aspect) "")))
            (t (destructuring-bind (field-name &rest field-content)
                   (if (listp base) base (cons nil base))
                 (wrap-label (lisp->camel-case field-name)
                             `(:input :class "input" :type "text" :value ,(or field-content
                                                                              (uicc-text-default aspect)
                                                                              "")
                                      :name ,(or (string (uicc-key aspect)) "")))))))))

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

(defmethod generate ((medium uim-web) (aspect uich-candle))
  (destructuring-bind (system branch) (uic-base aspect)
    `(:div :id ,(format nil "~a-~a" system branch)
           :x-init ,(ps (let ((config (create plotter candle-plotter
                                              labels (list))))
                          (fetch-contact (lisp (string-upcase system))
                                         (lisp (string-upcase branch))
                                         (create mode "chart-data")
                                         (lambda (data)
                                           (chain console (log :dd data config))
                                           ;; (chain
                                           ;;  window (-dygraph $el data config))
                                           ))
                          )))))

;; (chain window (-dygraph (@ self container-element)

#|

(destructuring-bind (system branch) (uic-base aspect)
               (let ((token (format nil "cm-texteditor-~a-~a" (string-downcase system)
                                    (string-downcase branch))))
                 `(:div :id ,token ;; :class ,(uic-type aspect)
                        :x-init ,(psl (progn (setf (@ window codemirror) nil)
                                             (setf (getprop (@ window seed-elements) (lisp branch))
                                                   $el)
                                             (fetch-contact (lisp (string system))
                                                            (lisp (string branch))
                                                            (list (list "text" 0))
                                                            (lambda (data) 

|#

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

(defvar *giface-output-stream*)

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
              ;; (instantiate-priority-macro-reader (asdf:load-system package)) ;; RESTORE THIS
              )
            
            ;; (print (list :af (assoc :face input :test #'eq)))
            ;; (print (list :ew el-width))
            ;; the output-stream is created in the seed package - best elsewhere?
            (if (and (assoc :face input :test #'eq)
                     (string= "graphNode" (rest (assoc :face input :test #'eq))))
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
                (if (or network-changed (assoc :system input))
                    (progn (setf *giface-output-stream* (make-string-output-stream))
                           ;; (print (list :nc input))
                           ;; (print (list :form formatted))
                           (eval `(cl-who:with-html-output (*giface-output-stream*)
                                    ,(svrender-graph
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
