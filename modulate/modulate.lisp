;;;; seed.modulate.lisp
(in-package #:seed.modulate)

(defmacro psl (form)
  "A macro for denoting inline Parenscript code."
  `(subseq (ps-inline ,form) 11))

(defmacro psl* (form)
  "A macro for denoting inline Parenscript code."
  `(subseq (ps-inline* ,form) 11))

(defmacro fx (form)
  (first form))

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
                       (corresponding (and this-name (getf pairs this-name)))
                       (process (or ;; (match (rest (assoc :type props))
                                    ;;   ((list :field :numeric :integer)
                                    ;;    #'parse-number:parse-number))
                                 #'identity)))
                  
                  ;; (print (list :iii item props corresponding this-name process
                  ;;              :ci cons-items))
                  (if corresponding
                      (if cons-items (setf (second form)
                                           (cons (caadr form)
                                                 (funcall process corresponding)))
                          (setf (second form) (funcall process corresponding)))
                      (when (and (listp item)
                                 (or (not cons-items)
                                     (not (keywordp (first item)))))
                        (loop :for i :in item :do (meta-revise i pairs cons-items))))
                  ;; (print (list :out form))
                  form)))))

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
          :initarg  :name
          :documentation "The component's unique name.")
   (%base :accessor uic-base
          :initform nil
          :initarg  :base
          :documentation "The content within the component, which may determine its appearance and/or function.")
   (%type :accessor uic-type
          :initform nil
          :initarg  :type
          :documentation "The type taxonomy of the component, which helps determine its properties.")
   (%root :accessor uic-root
          :initform nil
          :initarg  :root
          :documentation "The component to which the component belongs.")
   (%path :accessor uic-path
          :initform nil
          :initarg  :path
          :documentation "The path connecting the component to its upstream root component.")
   (%join :accessor uic-join
          :initform nil
          :initarg  :join
          :documentation "Specification for a server-side data structure with which the component is associated.")
   (%call :accessor uic-call
          :initform nil
          :initarg  :call
          :documentation "An effect produced by interaction with the component; this may involve the Seed server or manifest only within the user interface.")
   ;; (%cast :accessor uic-cast ;; may not be needed
   ;;        :initform nil
   ;;        :initarg  :cast
   ;;        :documentation "An event coinciding with use of the component; this affects the UI engine.")
   (%sort :accessor uic-sort ;; TODO: remove this when no uses left
          :initform nil
          :initarg  :sort
          :documentation "")
   (%mode :accessor uic-mode
          :initform nil
          :initarg  :mode
          :documentation "")
   (%role :accessor uic-role
          :initform nil
          :initarg  :role
          :documentation "")))

(defclass uic-frame (ui-component)
  ((%access :accessor uicf-access
            :initform nil
            :initarg  :access)))

(defclass uic-series (ui-component)
  ((%maps   :accessor uic-series-maps
            :initform nil
            :initarg  :maps)
   (%point  :accessor uic-series-point
            :initform nil
            :initarg  :point)
   (%layout :accessor uic-series-layout
            :initform nil
            :initarg  :layout)))

(defclass uic-grid (ui-component)
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
  ((%options :accessor uics-options
             :initform nil
             :initarg  :options)))

(defclass uicc-field (uic-control)
  ((%default :accessor uicc-field-default
             :initform nil
             :initarg  :default)))

(defclass uic-chart (ui-component)
  ((%points :accessor uic-chart-points
            :initform nil
            :initarg  :points)))

(defclass uich-candle (uic-chart)
  ())

(defclass ui-role ()
  ((%name :accessor uir-name
          :initform nil
          :initarg  :name))
  (:documentation "The ui-role class describes roles for ui components, which define their relationships with their subcomponents and neighboring components."))


(defun has-role (component role-sym)
  (let ((pos (position role-sym (uic-role component) :test (lambda (r c) (typep c r)))))
    (and pos (nth pos (uic-role component)))))

(defclass uir-call-form (ui-role)
  ((%options :accessor uircf-options
             :initform nil
             :initarg  :options)))

(defclass uir-sortable (ui-role)
  ((%range :accessor uirsrt-range
           :initform nil
           :initarg  :range))
  (:documentation "A role for a series whose elements may be manually sorted."))

(defclass uir-reducable (ui-role)
  ()
  (:documentation "A role for a series whose elements may be manually removed."))

(defclass uir-toggle ()
  ((%symap :accessor uirt-symap
           :initform nil
           :initarg  :symap))
  (:documentation "A role for a series of toggles of which only one may be on at a time."))

(defmacro dx (specs &rest form)
  "Specify a form expression; this is how data structures intended entirely as interface elements that are not typically composed into code for compilation are formatted."
  (labels (;; (format-list (form)
           ;;   (cons 'list (loop :for item :in form
           ;;                     :collect (if (atom item) item (format-list item)))))
           (format-list2 (form)
             (if (or (atom form) (not (keywordp (first form))))
                 form (cons 'list (loop :for item :in form
                                        :collect (if (atom item) item (format-list2 item))))))
           (format-params (items)
             ;; (print (loop :for item :in items
             ;;              :collect (if (or (atom item)
             ;;                               (not (keywordp (first item))))
             ;;                           item (format-list item))))
             (loop :for (ikey ival) :on items :by #'cddr :append (list ikey (format-list2 ival))))

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
                      ;; (print (list :prr params))
                      (setf generated `(make-instance ',class :base ,item ,@(format-params params))))))
               (if (not (rest spec-list))
                   generated (process-spec generated (rest spec-list))))))
    (let ((evaluated-form (gensym)))
      `(let ((,evaluated-form ,(if (not (second form))
                                   (first form) (cons 'list form))))
         ,(process-spec evaluated-form specs)))))

;; (defmacro dx-assign (params &body item)
;;   (let ((item-sym (gensym)))
;;     `(let ((,item-sym ,item))
;;        ,(loop :for p :in params
;;               :append (destructuring-bind (key &rest values) p
;;                         (case key
;;                           (:type `((setf (rest (uic-type ,item-sym))
;;                                          (append (list ,@values)
;;                                                  (rest (uic-type ,item-sym)))))))))
;;        ,item-sym)))

(defmacro role-cast (&rest roles)
  (cons 'list (loop :for role :in roles
                    :collect (let ((symbol (intern (format nil "UIR-~a" (if (symbolp role)
                                                                            role (first role)))
                                                   (package-name *package*))))
                               `(make-instance ',symbol ,@(and (listp role) (rest role)))))))

(defgeneric render (medium component))

(defgeneric furnish (medium component &optional base))

(defgeneric furnish-type (medium component &optional other-types))

(defgeneric furnish-call (medium component))

(defgeneric of-root-type (aspect type))

(defgeneric realize (origin medium aspect &key sort))

(defmethod render ((medium uim-web) (component t))
  (let* ((out-stream (make-string-output-stream))
         (spinneret:*html* out-stream))
    (spinneret:interpret-html-tree (generate medium component))
    (values (get-output-stream-string out-stream)
            (close out-stream))))

(defmethod of-root-type ((aspect ui-component) type)
  (or (member type (uic-type aspect) :test #'eq)
      (and (uic-root aspect)
           (of-root-type (uic-root aspect) type))))

(defun merge-furnishings (base extend)
  (loop :for (ekey eval) :on extend :by #'cddr
        :do (loop :for (key val) :on eval :by #'cddr
                  :do (setf (getf (getf base ekey)
                                  (intern (string key)))
                            val)))
  base)

(defmethod furnish ((medium uim-web) (aspect ui-component) &optional base)
  (let* ((pairs (if (uic-join aspect)
                    (list :mode (list :system   (first  (uic-join aspect))
                                      :branch   (second (uic-join aspect))
                                      :of-local '(manifest-locality)
                                      :domain   '(create)))))
         (base (merge-furnishings base pairs)))
    (merge-furnishings
     base (case (uic-mode aspect)
            (:chart (list :mode    (list :interaction "select"
                                         :draw-entity "line"
                                         :linked-branch-id "branch-entitiesView"
                                         :moving-from 'nil
                                         :mousedown 'false
                                         :active-entity 'nil
                                         :entities-in-flux '(list)
                                         :entities '(list))
                          :methods (list :save
                                         '(lambda (mode)
                                           (fetch-contact
                                            $el mode (create action "save")
                                            (lambda (data))))
                                         :select
                                         '(lambda (mode)
                                           (setf (@ mode interaction) "select"))
                                         :draw
                                         '(lambda (mode)
                                           (setf (@ mode interaction) "draw"
                                                 (@ mode draw-entity) "line"))
                                         :retrace-x
                                         '(lambda (mode)
                                           (setf (@ mode interaction) "draw"
                                                 (@ mode draw-entity) "retraceX"))
                                         :retrace-y
                                         '(lambda (mode)
                                           (setf (@ mode interaction) "draw"
                                                 (@ mode draw-entity) "retraceY"))
                                         :zoom-actual
                                         '(lambda (mode))
                                         :when-toggled `(lambda (mode)
                                                          (chain console (log 202 mode))))))
            (:meta-code-form (list :mode    (list :form nil)
                                   :methods (list :register-form
                                                  '(lambda (mode)
                                                    (lambda (form)
                                                      (setf (@ mode form) form)))
                                                  :save
                                                  '(lambda (mode)
                                                    ;; (chain htmx (trigger (@ mode form) "submit"))))))
                                                    (let* ((fdata (new (-form-data (@ mode form))))
                                                           (obj (chain -object
                                                                       (from-entries
                                                                        (chain fdata (entries))))))
                                                      (setf (@ obj action) "saveNode")
                                                      (fetch-contact
                                                       $el mode obj
                                                       (lambda (data)
                                                         (chain htmx (trigger (@ mode domain main)
                                                                              "reload")))))))))
            (:graph-breadth (list :methods (list :add-node
                                                 '(lambda (mode)
                                                   (fetch-contact
                                                    $el mode (create action "addNode")
                                                    (lambda (data)
                                                      (chain mode (of-local "trigger" "main" "reload")))))
                                                 :add-link
                                                 '(lambda (mode)
                                                   (fetch-contact
                                                    $el mode (create action "addLink")
                                                    (lambda (data)
                                                      (chain mode (of-local "trigger" "main" "reload"))))))))
            ))))

(defun alist-supersede (new original)
  (loop :for n :in new :do (if (assoc (first n) original)
                               (rplacd (assoc (first n) original)
                                       (rest n))
                               (push n original)))
  original)

(defmethod realize ((origin ui-component) (medium ui-medium) (aspect t) &key sort)
  (unless (not (typep aspect 'ui-component))
    (when sort (setf (uic-sort aspect) sort)))
  (generate medium aspect))

(defgeneric generate (medium component))

(defgeneric locate (medium component index item))

(defmethod locate ((medium uim-web) (comp t) index item)
  (declare (ignore medium comp index item))
  "")

(defmethod generate ((medium uim-web) (aspect null))
  (declare (ignore medium aspect)))

(defmethod generate ((medium uim-web) (aspect list))
  (declare (ignore medium))
  aspect)

(defmethod generate ((medium uim-web) (aspect symbol))
  (declare (ignore medium))
  (list :span :class "symbol" (symbol-munger:lisp->camel-case aspect)))

(defmethod generate ((medium uim-web) (aspect string))
  (declare (ignore medium))
  ;; (list :raw aspect)
  aspect)

(defmethod generate ((medium uim-web) (aspect uic-frame))
  (let ((types (funcall (if (listp (uic-type aspect)) #'identity #'list)
                        (uic-type aspect)))
        (face (lisp->camel-case (uic-name aspect)))
        (system (uicf-access aspect)))

    (cons :div (if system
                   (list :hx-post "/render/" :hx-trigger "load, reload consume, submit consume"
                         :id (format nil "branch-~a" (lisp->camel-case (uic-name aspect)))
                         :class (furnish-type medium aspect '(:access))
                         :x-init (ps (progn (setf (getprop (@ window seed-elements) (lisp face)) $el)
                                            (chain mode (of-local "register" "main" $el))
                                            (setf (@ mode domain main) $el)
                                            (fetch-contact $el mode (create height (@ $el offset-height)
                                                                            width  (@ $el offset-width))
                                                           (lambda (data)))))
                         :hx-vals (format nil "js:{...ejoin(~a,event)}"
                                          (json-convert-to (list :system system :face face
                                                                 :branch (string (uic-base aspect)))))
                         ;; :hx-vals (json-convert-to (list :system system :face face
                         ;;                                 :branch (string (uic-base aspect))))
                         :x-data (psl (create branch-frame $el)))
                   (progn (when (typep (uic-base aspect) 'ui-component)
                            (setf (uic-root (uic-base aspect)) aspect))
                          (list :class (furnish-type medium aspect '(:access))
                                (realize aspect medium (uic-base aspect))))))))

(defmethod generate ((medium uim-web) (aspect uic-series))
  (let ((last-type-index (1- (length (uic-type aspect))))
        (class-stream (make-string-output-stream))
        (types (funcall (if (listp (uic-type aspect)) #'identity #'list)
                        (uic-type aspect)))
        (breadth-default 12) (call (uic-call aspect))
        (is-list-table (member :list-table (uic-type aspect)))
        (layout (uic-series-layout aspect))
        (x-inits))
    
    (destructuring-bind (&optional ltype &rest lprops) (uic-series-layout aspect)

      (flet ((enclose-by-type (types item index)
               ;; (print (list :el item types (and (typep item 'ui-component)
               ;;                                  (uic-type item))))
               (let ((output-unlisted)
                     (is-interstitial-row (and (typep item 'ui-component)
                                               (listp (uic-type item))
                                               (member :table-interstitial (uic-type item)))))
                 (dolist (type types)
                   (setf item (case type
                                (:column `(:div :class "column-inner"
                                                ,(realize aspect medium item :sort index)))
                                (:list-table
                                 ;; NOTE: this depends on list-table not being the first style;
                                 ;; if it is the first style, it will not yet be rendered as HTML
                                 (if (and (listp item) (eq :div (first item)))
                                     (let ((content-index (loop :for i :in item :for ix :from 0
                                                                :when (and i (listp i)) :return ix)))
                                       (setf output-unlisted t)
                                       (loop :for i :in (nthcdr content-index item)
                                             :collect (list :td i)))
                                     (append (list :td)
                                             (if is-interstitial-row (list :colspan "100%"))
                                             (list (realize aspect medium item :sort index)))))
                                (t (realize aspect medium item :sort index)))))
                 (unless types (setf item (realize aspect medium item :sort index)))
                 (if output-unlisted item (list item)))))
        
        (loop :for item :in (uic-base aspect) ;; :do (print (list :it item (uic-base aspect)))
              :when (and (typep item 'ui-component) (not (uic-root item)))
                :do (setf (uic-root item) aspect))

        ;; (when (and (listp (uic-base aspect))
        ;;            (symbolp (first (uic-base aspect)))
        ;;            (string= "CHART-VIEW" (string (first (uic-base aspect)))))
        ;;   (print (list :iio (uic-base aspect) (mapcar #'uic-base (nthcdr 3 (uic-base aspect))))))
        
        (when (member :enum types)
          (push (psl (if (and (not (= "undefined" (typeof methods)))
                              (not (= "undefined" (typeof (@ methods register-form)))))
                         (funcall (chain methods (register-form mode)) $el)))
                x-inits))

        (when (and (member :controls types)
                   (has-role aspect 'uir-toggle))
          (push (psl (setf this-toggle (register-exclusive-toggle-array mode methods toggle-state)))
                x-inits))

        (when (and (typep    aspect 'ui-component)
                   (has-role aspect 'uir-sortable))
          ;; (print (list :ty types :r (uic-type (uic-root aspect))))
          (push (psl (let ((handle-container) (handle) (item))
                       ;; (chain console (log :aa (@ $el child-nodes) (@ $el child-nodes length)))
                       (dolist (n (@ $el child-nodes))
                         ;; (chain console (log :cc n (@ n class-name) (@ n class-list)
                         ;;                     (and (@ n class-list)
                         ;;                          (chain n class-list (contains "item")))))
                         (when (and (/= "undefined" (typeof (@ n class-list)))
                                    (chain n class-list (contains "item")))
                           (setf item n)
                           ;; (chain console (log :bbb n (chain n (get-attribute "index"))
                           ;;                     (chain n (query-selector ".control.drag-handle"))))
                           (setf handle-container (chain n (query-selector ".control.drag-handle")))
                           
                           (when handle-container
                             (dolist (h (@ handle-container child-nodes))
                               (when (and (/= "undefined" (typeof (@ h class-list)))
                                          (chain h class-list (contains "drag-handle")))
                                 (setf handle h)
                                 (break)))
                           
                             (let ((drops (create element item drag-handle handle
                                                  on-drag-start (mcode-handler-on-drag $el mode))))
                               ;; (chain console (log :dd item drops (@ item class-list)
                               ;;                     (typeof (@ item class-list))
                               ;;                     (/= "undefined" (typeof (@ item class-list)))))
                               (draggable drops)))))))
                x-inits))

        (when (and (typep    aspect 'ui-component)
                   (has-role aspect 'uir-reducable))
          ;; (print (list :ty types :r (uic-type (uic-root aspect))))
          (push (psl (let* ((remover) (item) (meta-path (chain $el (get-attribute "meta-path")))
                            (interactor (lambda (element index)
                                          (fetch-contact element mode (create path meta-path remove index)
                                                         (lambda () (chain console (log "ee" element $el))
                                                           (chain htmx (trigger $el "reload")))))))
                       (dolist (n (@ $el child-nodes))
                         ;; (chain console (log :nnn n))
                         (when (and (/= "undefined" (typeof (@ n class-list)))
                                    (chain n class-list (contains "item")))
                           ;; (chain console (log :bbb n (chain n (get-attribute "index"))
                           ;;                     (chain n (query-selector ".control.drag-handle"))))
                           (setf item    n
                                 remover (chain n (query-selector ".control.to-remove")))
                           (when remover
                             (chain remover (add-event-listener
                                             "click" (lambda () (funcall interactor remover 0)))))))))
                x-inits))

        (let* ((items (loop :for ix :from 0
                            ;; if this is a call-form, the form's head symbol is not displayed
                            ;; with the others; in most cases it is either not shown or displayed
                            ;; in a special manner as in a series header
                            :for item :in (funcall (if (has-role aspect 'uir-call-form)
                                                       #'rest #'identity)
                                                   (uic-base aspect))
                            :collect (let ((map (nth ix (uic-series-maps aspect))))
                                       (format class-stream "item ")
                                       (when (and (uic-series-point aspect)
                                                  (= ix (uic-series-point aspect)))
                                         (format class-stream "point "))
                                       (loop :for itype :in (rest (assoc :type map))
                                             :do (format class-stream "~a " (string-downcase itype)))
                                       ;; (print (list :it item))
                                       (locate medium aspect ix
                                               (append (list (cond (is-list-table :tr)
                                                                   (t :div))
                                                             :class (get-output-stream-string class-stream)
                                                             :index ix)
                                                       ;; (and (of-root-type aspect :meta-code)
                                                       ;;      (list :x-data
                                                       ;;            (psl (create in-series
                                                       ;;                         containing-series))))
                                                       (and (and (of-root-type aspect :meta-code)
                                                                 (member :sortable (uic-type aspect)))
                                                            (list :x-init
                                                                  (psl (initialize-draggable
                                                                        $el mode in-series))))
                                                      (enclose-by-type types item ix))))))
               (parent-sortable (and (typep    (uic-root aspect) 'ui-component)
                                     (has-role (uic-root aspect) 'uir-sortable)))
               (header (let ((segments))
                         (when (and parent-sortable (of-root-type aspect :meta-code))
                           (push '(:p :class "control drag-handle" (:a :class "button is-static" "≣"))
                                 segments))
                         (when (has-role aspect 'uir-call-form)
                           (push `(:p :class "control is-expanded"
                                      (:a :class "button is-static" ,(first (uic-base aspect))))
                                 segments))
                         ;; place the X button to remove a list item if its
                         ;; parent list has the reducable role
                         (when (and (uic-root aspect)
                                    (has-role (uic-root aspect) 'uir-reducable))
                           (push `(:p :class "control to-remove"
                                      (:a :class "button is-static" "X"))
                                 segments))
                         (if segments (list (append (list :div :class "series-heading field has-addons")
                                                    (reverse segments)))))))

          ;; (when (and (listp (uic-base aspect))
          ;;            (symbolp (first (uic-base aspect)))
          ;;            (string= "CHART-VIEW" (string (first (uic-base aspect)))))

          ;; (print (list :it items (of-root-type aspect :meta-code)
          ;;              (uic-type aspect)))
          
          (loop :for type :in types :for ix :from 0
                :do (format class-stream "~a" (string-downcase type))
                    (unless (= ix last-type-index) (format class-stream " ")))
          
          (append (list (cond ((or (eq t call) (member :enum types))
                               :form)
                              (is-list-table :table)
                              (t :div))
                        ;; the series should be expressed as a form if it is conveying an
                        ;; enum structure or if its :call property is set to t indicating
                        ;; that it is a form whose submission causes its rerendering
                        :path "" :class (furnish-type medium aspect
                                                      (append '(:ui :series)
                                                              (case ltype
                                                                ((:horizontal :vertical)
                                                                 '(:series :grid-layout)))
                                                              (and is-list-table '(:table))))
                        :style (if (and ;; (not (member ltype '(:horizontal :vertical)))
                                        ;; (not (eql :even (first lprops)))
                                        t
                                        )
                                   ;; TODO: this needs more rigorous logic for partitioning according
                                   ;; to params and numbers in lprops, currently it only supports
                                   ;; the :even (number) case
                                   "" (let ((ratio (/ 100.0 (or (second lprops) breadth-default))))
                                        (format nil "grid-template-~a: ~{~a% ~};"
                                                (if (eq ltype :horizontal) "columns" "rows")
                                                (loop :for i :below (or (second lprops) breadth-default)
                                                      :collect ratio))))
                        :x-data (if (of-root-type aspect :meta-code)
                                    (psl (create containing-series $el))))
                  
                  (and (eq t call)
                       (list :hx-inherit "*" :hx-post "/render/"))

                  (and x-inits (list :x-init (apply #'concatenate 'string (mapcar (lambda (str)
                                                                                    (format nil "~a;~%" str))
                                                                                  x-inits))))
                  
                  (and (and (member :controls types)
                            (has-role aspect 'uir-toggle))
                       (list :x-data (psl (create this-toggle null
                                                  toggle-state (create index null)))))

                  ;; header

                  (if (eq :groups ltype)
                      (let ((envelopes) (item-index 0)
                            (rows (getf lprops :rows)))

                        (dolist (item rows)
                          ;; (print (list :tt item))
                          (let ((in-header (and header (zerop item-index) (minusp item))))
                            (push nil envelopes)
                            (when in-header (push (first header)
                                                  (first envelopes)))
                            (loop :for c :below (abs item)
                                  :do (push (list :div :class (if in-header "following" "column")
                                                  (nth (+ c item-index) items))
                                            (first envelopes)))
                            (setf (first envelopes) (append (list :div :class "columns")
                                                            (reverse (first envelopes))))
                            (incf item-index (max 1 (abs item)))))
                        
                        (append (reverse envelopes)
                                (if (< item-index (- (length items) 0))
                                    (nthcdr item-index items))))
                      (funcall (cond (is-list-table (lambda (form) (list (cons :tbody form))))
                                     (t #'identity))
                               (append header items)))))))))

;; (and (member :enum types)
;;      (list :x-init (psl (if (and (not (= "undefined" (typeof methods)))
;;                                  (not (= "undefined" (typeof (@ methods register-form)))))
;;                             (funcall (chain methods (register-form mode)) $el)))))

;; (and (and (member :controls types) (member :extog types))
;;      (list :x-data (psl (create this-toggle null
;;                                 toggle-state (create index null)))
;;            :x-init (psl (setf this-toggle (register-exclusive-toggle-array
;;                                            mode methods toggle-state)))))

#|

(when (and (of-root-type aspect :meta-code)
                             (member :sortable (uic-type aspect))
                             ;; (of-root-type aspect :sortable)
                             )
                    ;; (print (list :ty types))
                    (list :x-init (psl (let ((handle-container) (handle))
                                         (chain console (log :aa $el))
                                           (loop :for n :in (@ $el child-nodes)
                                                 :do (when (= (@ n class-name) "field has-addons")
                                                       (chain console (log :bbb n))
                                                       (setf handle-container
                                                             (chain n (query-selector
                                                                       ".control.drag-handle")))
                                                       (break)))
                                           (chain console (log 77 (@ $el child-nodes) handle-container))
                                           (when handle-container
                                             (loop :for n :in (@ handle-container child-nodes)
                                                   :do (when (= (@ n class-name) "control drag-handle")
                                                         (setf handle n)
                                                         (break))))
                                           
                                           (when (/= "undefined" (typeof in-series))
                                             (let ((drops (create element $el drag-handle handle
                                                                  on-drag-start
                                                                  (mcode-handler-on-drag
                                                                   in-series mode))))
                                               ;; (chain console (log :dd drops))
                                               (draggable drops)
                                               nil))))))

4 5 0 2

(⍳10){(⍺×⊂10 0)+¨⍵}¨⊂(0 0)(0 600)

(⍳10){(⍺×⊂0 60)+¨⍵}¨⊂(0 0)(100 0)

((⍳10)×⊂10 0){⍵+¨⊂⍺}¨⊂(0 0)(0 600)

((⍳10)×⊂10 0 10 0)+¨⊂0 0 0 600

((⍳10)×⊂0 60 0 60)+¨⊂0 0 100 0
|#

;; (defun grid-lines (spans)
;;   (let ((hlines (make-array (list 20 4) :element-type '(unsigned-byte 16)))
;;         (vlines (make-array (list 20 4) :element-type '(unsigned-byte 16)))
;;         (hsize 60) (vsize 10) (hstart 60) (vstart 10)
;;         (lindex 0) (hindex 0) (vindex 0))
;;     (dotimes (n (1- 10))
;;       (setf (row-major-aref hlines (+ lindex 0)) hstart
;;             (row-major-aref hlines (+ lindex 2)) hstart
;;             (row-major-aref hlines (+ lindex 3)) 100
;;             (row-major-aref vlines (+ lindex 1)) vstart
;;             (row-major-aref vlines (+ lindex 3)) vstart
;;             (row-major-aref vlines (+ lindex 2)) 600)
;;       (incf hstart hsize)
;;       (incf vstart vsize)
;;       (incf lindex 4))
;;     (setf hindex (setf vindex lindex))
    
;;     (dolist (span spans)
;;       (destructuring-bind (x y xspan yspan) span
;;         (setf (row-major-aref hlines (+ 3 (ash x 2))) (* x vsize)
;;               (row-major-aref vlines (+ 2 (ash y 2))) (* x hsize))
;;         (dotimes (n 4)
;;           (setf (row-major-aref hlines (+ n hindex))
;;                 (if (= n 0) (row-major-aref hlines (+ n (ash x 2)))
;;                     (if (= 1 n) (* (+ x xspan) vsize)
;;                         (if (= 2 n) (row-major-aref hlines (+ n (ash x 2)))
;;                             100))))
;;           (setf (row-major-aref vlines (+ n vindex))
;;                 (if (= n 0) (* (+ y yspan) hsize)
;;                     (if (= 1 n) (row-major-aref vlines (+ n (ash y 2)))
;;                         (if (= 2 n) 600
;;                             (row-major-aref vlines (+ n (ash y 2))))))))
;;         (incf hindex 4)
;;         (incf vindex 4)))
;;     (list hlines vlines)))

(defun grid-lines (spans)
  (let ((hlines (make-array (list 20 4) :element-type '(unsigned-byte 16)))
        (vlines (make-array (list 20 4) :element-type '(unsigned-byte 16)))
        (hsize 60) (vsize 10) (hstart 60) (vstart 10)
        (lindex 0) (hindex 0) (vindex 0))
    (dotimes (n (1- 10))
      (setf (row-major-aref hlines (+ lindex 0)) hstart
            (row-major-aref hlines (+ lindex 2)) hstart
            (row-major-aref hlines (+ lindex 3)) 100
            (row-major-aref vlines (+ lindex 1)) vstart
            (row-major-aref vlines (+ lindex 3)) vstart
            (row-major-aref vlines (+ lindex 2)) 600)
      (incf hstart hsize)
      (incf vstart vsize)
      (incf lindex 4))
    (setf hindex (setf vindex lindex))
    
    (dolist (span spans)
      (destructuring-bind (x y xspan yspan) span
        (dotimes (xs xspan)
          (setf (row-major-aref hlines (+ 3 (ash (+ x xs) 2))) (* x vsize))
          (dotimes (n 4)
            (setf (row-major-aref hlines (+ n hindex))
                  (if (= n 0) (row-major-aref hlines (+ n (ash (+ x xs) 2)))
                      (if (= 1 n) (* (+ x xspan) vsize)
                          (if (= 2 n) (row-major-aref hlines (+ n (ash (+ x xs) 2)))
                              100)))))
          (incf hindex 4))
        (dotimes (ys yspan)
          (setf (row-major-aref vlines (+ 2 (ash (+ y ys) 2))) (* x hsize))
          (dotimes (n 4)
            (setf (row-major-aref vlines (+ n vindex))
                  (if (= n 0) (* (+ y yspan) hsize)
                      (if (= 1 n) (row-major-aref vlines (+ n (ash (+ y ys) 2)))
                          (if (= 2 n) 600
                              (row-major-aref vlines (+ n (ash (+ y ys) 2))))))))
          (incf vindex 4))))
    (list hlines vlines)))

;; (seed.modulate::grid-lines '((3 4 2 2)))

(defmethod generate ((medium uim-web) (aspect uic-grid))
  (destructuring-bind (system branch) (uic-base aspect)
    (let ((token (format nil "canvas-datagrid-~a-~a"
                         (string-downcase system) (string-downcase branch)))
          (branch (string-downcase branch)))
      `(:div :id "datagrid-cells" ;; :class (getf props :item-classes)
             :x-init ,(psl (progn (setf (getprop (@ window seed-elements) (lisp branch)) $el)
                                  (fetch-contact
                                   $el mode ;; (list (list "cells" 0))
                                   (create cells (list 0))
                                   (lambda (data)
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
                                  ,(psl (chain htmx (trigger this "navigate"
                                                             (create point (lisp (uic-sort aspect))))))
                                  ,(generate medium base)))
                   '(:hr :class "divider")))
      (t (generate medium base)))))

(defmethod generate ((medium uim-web) (aspect uicc-button))
  (let* ((base (uic-base aspect))
         (name (if (or (symbolp base) (stringp base))
                   base))
         (root-types (funcall (if (listp (uic-type aspect)) #'identity #'list)
                              (uic-type (uic-root aspect)))))
    (destructuring-bind (name &optional action &rest props)
        (if name (list name name) (uic-base aspect))
      ;; (print (list :bs base (and (listp base) (second base))
      ;;              (and (has-role aspect 'uir-toggle)
      ;;                   (uirt-symap (has-role aspect 'uir-toggle)))))
      ;; (when (has-role aspect 'uir-toggle)
      ;;   (setf portal.demo1::aaa aspect))
      `(:button :name ,(string (or name "")) ,@(furnish-call medium aspect)
                ,@(and (member :controls root-types)
                       (has-role (uic-root aspect) 'uir-toggle)
                       (list :|x-on:click| (psl (funcall this-toggle (lisp (lisp->camel-case name))
                                                         (lisp (uic-sort aspect))))
                             :|x-bind:class|
                          ;; ,(psl (if (= (@ toggle-state index) (lisp (uic-sort aspect)))
                          ;;                           "is-focused"))
                             (format nil "toggleState.index === ~a ? 'is-focused' : ''"
                                     (uic-sort aspect))))
                ;; ,@(and (has-role aspect 'uir-toggle)
                ;;        (list :|x-on:click|
                ;;              (psl (fetch-contact element mode (create path meta-path
                ;;                                                       toggle (lisp (uic-sort aspect)))
                ;;                                  (lambda () (chain console (log "ee" element $el))
                ;;                                    (chain htmx (trigger $el "reload")))))))
                :class ,(furnish-type medium aspect '(:ui :button))
                ,(if (and (has-role aspect 'uir-toggle) (listp base)
                          (eql 'nth (first base))) ;;  (integerp (second base)))
                     (progn
                       ;; (print (length (second (uirt-symap (has-role aspect 'uir-toggle)))))
                       (string (nth (second base) (or (second (uirt-symap (has-role aspect 'uir-toggle)))
                                                      (third (third base))))))
                     (realize aspect medium name))))))
                            
(defmethod generate ((medium uim-web) (aspect uicc-field))
  ;; (print (list :ee medium (uic-type aspect)))
  (flet ((wrap-label (label base) `(:div (:label (:span ,label)) ,base)))
    (let ((base (uic-base aspect)))
      (destructuring-bind (field-name &rest field-content)
          (if (listp base) base (cons (uic-name aspect) base))
        (cond ((member :code (uic-type aspect))
               (destructuring-bind (system branch) (uic-base aspect)
                 (let ((token (format nil "cm-texteditor-~a-~a" (string-downcase system)
                                      (string-downcase branch))))
                   `(:div :id ,token ;; :class ,(uic-type aspect)
                          :x-init ,(psl (progn (setf (@ window codemirror) nil)
                                               (setf (getprop (@ window seed-elements) (lisp branch))
                                                     $el)
                                               (fetch-contact
                                                $el mode (create text (list 0))
                                                (lambda (data) 
                                                  (setf (getprop (@ window seed-data) (lisp token))
                                                        (create-codemirror
                                                         (chain document (get-element-by-id (lisp token)))
                                                         (@ data text)))))))))))
              ((member :area (uic-type aspect))
               (wrap-label (lisp->camel-case field-name)
                           `(:textarea :class "textarea" :name ,(or (lisp->camel-case field-name) "")
                                       ,(or field-content (uicc-field-default aspect)
                                            ""))))
              (t 
               ;; (print (list :fi field-name base))
               (wrap-label (lisp->camel-case field-name)
                           `(:input :class "input" :type "text" :value ,(or field-content
                                                                            (uicc-field-default aspect)
                                                                            "")
                                    :name ,(or (lisp->camel-case field-name) "")))))))))

(defmethod generate ((medium uim-web) (aspect uicc-select))
  (let* ((base (uic-base aspect))
         (original-type (uic-type aspect))
         (types (if (listp original-type) original-type (list original-type))))
    (destructuring-bind (field-name &rest field-content)
        (if (and base (listp base))
            base (cons (uic-name aspect) base))
      `(:div :class "field has-addons"
             ,@(if field-name `((:p :class "control"
                                    (:a :class "button is-static" ,(lisp->camel-case field-name)))))
             (:p :class "control"
                 (:span :class "select"
                        (:select :name ,(or (lisp->camel-case field-name) "")
                          :class ,(furnish-type medium aspect)
                          ,@(furnish-call medium aspect)
                          ,@(append (and (member :default-blank types)
                                         (not field-content)
                                         `((:option "")))
                                    (loop :for item :in (uics-options aspect)
                                          :collect (let* ((item-out (if (not (symbolp item))
                                                                        item (lisp->camel-case item)))
                                                          (selected (if (equalp item field-content)
                                                                        `(:selected "selected"))))
                                                     `(:option ,@selected ,item-out)))))))))))

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

;; (defmethod generate ((medium uim-web) (aspect uic-anchor))
;;   (let ((base (uic-base aspect)))
;;     (case (first (uic-type aspect))
;;       (:branch (if base `(:h4 (:a :|hx-on:click|
;;                                   ,(psl (chain htmx (trigger this "navigate"
;;                                                              (create point (lisp (uic-sort aspect))))))
;;                                   ,(generate medium base)))
;;                    '(:hr :class "divider")))
;;       (t (generate medium base)))))

(defmethod furnish-type ((medium uim-web) (aspect ui-component) &optional other-types)
  (let* ((original-type (uic-type aspect))
         (types (if (listp original-type) original-type (list original-type)))
         (class-stream (make-string-output-stream))
         (last-type-index (1- (length types))))
    
    (dolist (ot other-types) (format class-stream "~a " (string-downcase ot)))

    (loop :for type :in types :for ix :from 0
          :do (format class-stream "~a" (string-downcase type))
              (unless (= ix last-type-index) (format class-stream " ")))

    (get-output-stream-string class-stream)))

(defgeneric build-call (medium component))

(defmethod build-call ((medium uim-web) (aspect ui-component)) ;; TODO: merge this in later
  (let* ((base (uic-base aspect))
         (call (uic-call aspect)))
    (labels ((js-format-plist (items)
               (if (not (and items (listp items)))
                   items (cons 'parenscript:create
                               (loop :for item :in items
                                     :collect (if (listp item)
                                                  (js-format-plist item)
                                                  (case item
                                                    (:.base (typecase aspect
                                                              (uicc-select `(@ $event target value))
                                                              (t base)))
                                                    (t item))))))))
      (if (listp call)
          (let* ((call-namespace (case (first call)
                                   (:@ :global)
                                   (t nil)))
                 (call (if (not call-namespace)
                           call (rest call))))
            (destructuring-bind (method &rest args) call
              `(funcall ,(case method
                           (:.fetch 'fetch-contact)
                           (t (case call-namespace
                                (:global (intern (string method)))
                                (t (:.base `(@ methods (@ $event target value)))
                                 `(@ methods ,(intern (string method)))))))
                        $el mode ,@(mapcar #'js-format-plist args))))
          `(funcall ,(case call ;; method
                       (:.fetch 'fetch-contact)
                       (:.base `(@ $event target value))
                       (t `(@ methods ,call)))
                    $el mode)))))

(defmethod furnish-call ((medium uim-web) (aspect ui-component))
  (let ((base (uic-base aspect)))
    (and (uic-call aspect)
         (not (atom (uic-call aspect)))
         (destructuring-bind (method &rest args) (uic-call aspect)
           (let* ((action (typecase aspect
                            (uicc-button :|x-on:click|)
                            (uicc-select :|x-on:change|)
                            (t :|x-on:click|))))
             (list action (ps* (build-call medium aspect))))))))

;; (defmethod furnish-call ((medium uim-web) (aspect ui-component))
;;   (let ((base (uic-base aspect)))
;;     (labels ((js-format-plist (items)
;;                (if (not (listp items))
;;                    items (cons 'parenscript:create
;;                                (loop :for item :in items
;;                                      :collect (if (listp item)
;;                                                   (js-format-plist item)
;;                                                   (case item
;;                                                     (:@base (typecase aspect
;;                                                               (uicc-select
;;                                                                `(@ $event target value))
;;                                                               (t base)))
;;                                                     (t item))))))))
;;       (and (uic-call aspect)
;;            (not (atom (uic-call aspect)))
;;            (destructuring-bind (method &rest args) (uic-call aspect)
;;              (let* ((action (typecase aspect
;;                               (uicc-button :|x-on:click|)
;;                               (uicc-select :|x-on:change|)
;;                               (t :|x-on:click|)))
;;                     (to-address (if (eq :@domain (first args)) 'domain 'mode))
;;                     (args (mapcar #'js-format-plist
;;                                   (if (not (eq :@domain (first args)))
;;                                       args (rest args))))
;;                     (method (if (eq :@fetch method)
;;                                 'fetch-contact method)))
;;                (list action (ps* (if (eq :@fetch method)
;;                                      (list method '$el to-address args)
;;                                      (funcall (if (eql 'fetch-contact method)
;;                                                   #'identity (lambda (item)
;;                                                                (list 'chain 'methods item)))
;;                                               (append (list method '$el to-address)
;;                                                       args)))))))))))

(defmethod generate :around ((medium uim-web) (aspect ui-component))
  "Generation method qualifier manifesting call effects for UI components."
  (let* ((main (call-next-method))
         (call (uic-call aspect))
         (base (uic-base aspect))
         (furnishing (furnish medium aspect)))
    ;; (print (list :ava aspect furnishing (uic-call aspect)))
    ;; (if pairs (list :x-data (ps* `(create mode (create ,@pairs)
    ;;                                                   of-local (manifest-locality)))))

    (cons (first main)
          (append (let ((action (typecase aspect
                                  (uicc-button :|x-on:click|)
                                  (uicc-select :|x-on:change|)
                                  (t :|x-on:click|))))
                    (typecase call
                      (atom (case call
                              (:@base (list action (ps* `(chain methods (,(intern (string base)) mode)))))))
                      ))
                  (if furnishing
                      (list :x-data (ps* `(create ,@(loop :for f :in furnishing
                                                          :collect (if (symbolp f)
                                                                   f (cons 'create f)))
                                              of-local (manifest-locality)))))
                  
                  (if (uic-path aspect)
                      (list :meta-path (format nil "~{~a ~}" (uic-path aspect))))
                  (rest main)))))

(defmethod generate ((medium uim-web) (aspect uich-candle))
  (destructuring-bind (system branch) (uic-base aspect)
    `(:div :class "chart-holder" :id ,(format nil "~a-~a" system branch)
           :x-init ,(ps (progn
                          (let ((config (create plotter (funcall get-candle-plotter mode)
                                                height (@ $el offset-height)
                                                width  (@ $el offset-width)
                                                interaction-model
                                                (create mousedown  (funcall interactor-mousedown  mode)
                                                        mouseup    (funcall interactor-mouseup    mode)
                                                        mousemove  (funcall interactor-mousemove  mode)
                                                        mousewheel (funcall interactor-mousewheel mode)))))

                            (fetch-contact
                             $el mode (create mode "chart-data")
                             (lambda (data)
                               ;; (chain console (log :dd data config $el))
                               (setf (getprop (@ window seed-elements) (lisp branch))
                                     (setf (@ mode chart)
                                           (new (chain window (-dygraph $el data config)))))
                               
                               ;; perform the initial entity commit to draw existing lines on the chart
                               (commit-entities mode (lambda () (chain mode chart (draw-graph_))))))))))))

(defun meta-combine (form template)
  (let ((to-append))
    (loop :for property :in template :unless (assoc (first property) (cddr form))
          :do (push property to-append))
    (append form to-append)))

(defun express (form &optional params path) ;; TODO: this will not grow well with the metaform topology
  (if (atom form)
      form (let ((path (or path '(0))))
             ;; (print (list :ff form))
             (if (not (and (symbolp (first form))
                           (string= "FX" (string (first form)))))
                 (make-instance 'uic-series :path (reverse path)
                                            :base (loop :for i :from 0 :for f :in form
                                                        :collect (express f params (cons i path))))
                 ;; TODO: URGENT: remove 2 explicit interns below
                 (let* ((form (if (not (assoc :template (cddr form)))
                                  form (let ((out form))
                                         (loop :for template :in (rest (assoc :template (cddr form)))
                                               :do (setf out (meta-combine
                                                              out (symbol-value (intern (string template)
                                                                                        "DEMO.SHEET")))))
                                         out)))
                        (fx-property (rest (assoc :fx (cddr form))))
                        (fx-class (first fx-property))
                        ;; (layout (rest (assoc :layout (cddr form))))
                        (class (when fx-class (intern (string fx-class) "SEED.MODULATE")))
                        (props (list :base (if (eql class 'uic-series)
                                               (loop :for i :from 0 :for f :in (second form)
                                                     :collect (express f params (cons i path)))
                                               (second form))
                                     :path (reverse path)
                                     :type (rest (assoc :type (cddr form)))
                                     :role (loop :for r :in (rest (assoc :role (cddr form)))
                                                 :collect (if (atom r)
                                                              (make-instance
                                                               (intern (string r) (package-name *package*)))
                                                              (apply #'make-instance
                                                                     (intern (string (first r))
                                                                             (package-name *package*))
                                                                     (rest r))))))
                        (out))
                   ;; (when roles (setf portal.demo1::iioo out))
                   (setf out (apply #'make-instance class (append props (rest fx-property))))
                   ;; (when layout
                   ;;   (if (typep out 'uic-series)
                   ;;       (setf (uic-series-layout out) layout)
                   ;;       (error "Assigned layout to a component that's not a uic-series.")))
                   (when (eql class 'uicc-select)
                     (setf (uics-options out) (rest (assoc :options (cddr form)))))
                   out)))))

(defvar *giface-output-stream*)

(defun format-graph-spec-to-edit (dgraph order)
  (let ((nodes (copy-tree (rest dgraph))))
    (cons (first dgraph)
          (loop :for index :across order :for nx :from 0
                ;; remove (meta) forms; should this be factored into a dedicated function?
                :collect (let ((node (nth index nodes)))
                           (cons (cons (cons :index nx) (first node))
                                 (if (rest node)
                                     (cons :closed (rest node)))
                                 ;; (cons :closed (rest node))
                                 ))))))

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
    
    (lambda (medium input)
      (unless graph-base
        (setf graph-base  (from-system-file package file-name graph-key)
              orig-data   (third graph-base)
              nodes-order (let* ((indices (second indices-form)))
                            ;; TODO: Make this just (apply #'vector ...)
                            (make-array (length indices) :initial-contents indices))
              graph-data  (format-graph-spec-to-edit (copy-tree orig-data) nodes-order)
              formatted   (copy-graph-spec graph-data)))

      ;; (print (list :abcd orig-data graph-data formatted))
      (destructuring-bind (&key action target width height path face system &allow-other-keys) input
        ;; (print (list :ac action path))
        (if (and action
                 (string= "open" action))
            (let* ((path-str (and path (make-string-input-stream path)))
                   (path (loop :for c := (read path-str nil) :while c :collect c)))
              (if (not (second path)) (setf index (first path) sub-index nil)
                  (destructuring-bind (i si) path
                    (setf index i sub-index si)))
              ;; (print (list :nnn index))
              ;; (close path-str)
              (list :oob-reload associated-node-ids))
            (let ((network-changed))
              (when width
                (setf el-width  width
                      el-height height))

              (when path
                (let ((inst (make-string-input-stream path)))
                  (dgraph-interface
                   graph-data formatted nodes-order
                   :path (loop :for c := (read inst nil) :while c :collect c)
                   :to-open (and action (string= action "expand"))
                   :at-path (if (not (and action (string= action "open")))
                                nil (lambda (item)
                                      ;; (setf (symbol-value
                                      ;;        (intern "*ACTIVE-GRAPH-ITEM*" (string package)))
                                      ;;       item)
                                      )))
                  (setf network-changed t)))

              (when (and action (string= "saveNode" action))
                (meta-revise (if sub-index (first (nth sub-index (rest (nth index (rest formatted)))))
                                 (cdar (nth index (rest formatted))))
                             input t)
                (meta-revise (first (if sub-index (nth sub-index (rest (nth index (rest orig-data))))
                                        (nth index (rest orig-data))))
                             input t)
                ;; (print (list :aabb formatted orig-data))
                (setf network-changed t))

              (when action
                (setf network-changed t)

                ;; add a node
                (when (and action (string= "addNode" action))
                  ;; add newest node index to end of indices
                  (let ((indices (from-system-file package file-name node-indices-key)))
                    (rplacd (last formatted)
                            (list (list (cons (cons :index (length (second indices-form)))
                                              (first node-template)))))
                    (rplacd (last (second indices-form))
                            (list (length (second indices-form))))
                    (rplacd (last orig-data) (list node-template))
                    (setf nodes-order (let* ((indices (second indices-form)))
                                        (make-array (length indices)
                                                    :initial-contents indices))
                          (from-system-file package file-name node-indices-key)
                          (list (first indices)
                                (append (second indices) (list (length (second indices))))))))

                ;; add a link between nodes
                (when (and action (string= "addLink" action))
                  ;; (print (list :si sub-index (rest (nth index (rest orig-data)))
                  ;;              (nth index (rest orig-data))))
                  (if sub-index (rplacd (nth sub-index (rest (nth index (rest orig-data))))
                                        (cons link-template
                                              (nthcdr (1+ sub-index)
                                                      (rest (nth index (rest orig-data))))))
                      (if (rest (nth index (rest orig-data)))
                          (rplacd (last (rest (nth index (rest orig-data))))
                                  (list link-template))
                          (rplacd (nth index (rest orig-data))
                                  (list link-template))))
                  (if sub-index (rplacd (nth sub-index (rest (nth index (rest graph-data))))
                                        (cons link-template
                                              (nthcdr (1+ sub-index)
                                                      (rest (nth index (rest graph-data))))))
                      (if (rest (nth index (rest graph-data)))
                          (rplacd (last (rest (nth index (rest graph-data))))
                                  (list link-template))
                          (rplacd (nth index (rest graph-data))
                                  (list link-template))))
                  (if sub-index (rplacd (nth sub-index (rest (nth index (rest formatted))))
                                        (cons link-template
                                              (nthcdr (1+ sub-index)
                                                      (rest (nth index (rest formatted))))))
                      (if (rest (nth index (rest formatted)))
                          (rplacd (last (rest (nth index (rest formatted))))
                                  (list link-template))
                          (rplacd (nth index (rest formatted))
                                  (list link-template)))))

                ;; delete a node or link
                (when (and action (string= "deleteItem" action))
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
                (when (and action (string= "shiftNode" action))
                  ;; add newest node index to end of indices
                  (setf network-changed nil)
                  (let* ((index-str (make-string-input-stream index))
                         (pos-str (make-string-input-stream target))
                         (indices (loop :for c := (read index-str nil) :while c :collect c))
                         (posx (loop :for c := (read pos-str nil) :while c :collect c))
                         (index (or (second indices) (first indices)))
                         (node-index (if (second indices) (first indices) nil))
                         (position (or (second posx) (first posx)))
                         (pos-parent (if (second posx) (first posx) nil)))
                    
                    (symbol-macrolet ((formatted2 (rest formatted))
                                      (graph-data2 (rest graph-data)))

                      (if node-index ;; links are being sorted
                          (when (and pos-parent (= node-index pos-parent))
                            (let ((orig-link (nth index (rest (nth node-index graph-data2))))
                                  (orig-flink (nth index (rest (nth node-index (rest orig-data))))))

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

                (when (and action (string= "connect" action))
                  (let ((this-index (read-from-string index)))
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

                (when network-changed ;; assign changes to the file when they happen
                  ;; (print (list :ch "CHANGED" graph-base))
                  (setf (from-system-file package file-name graph-key) graph-base)
                  ;; (instantiate-priority-macro-reader (asdf:load-system package)) ;; RESTORE THIS
                  )
                
                ;; (print (list :af (assoc :face input :test #'eq)))
                ;; (print (list :ew el-width formatted))
                ;; the output-stream is created in the seed package - best elsewhere?
                (if (and face (string= "graphNode" face))
                    (render medium
                            (dx ((uic-frame :type (:meta-code)))
                                (express
                                 (funcall (lambda (items)
                                            `(fx ,items (:type :enum) (:fx :uic-series)))
                                          (loop :for item :in (funcall
                                                               ;; nodes have an (index . N)
                                                               ;; form to omit, links don't
                                                               (if sub-index #'identity #'rest)
                                                               (first (if sub-index
                                                                          (nth sub-index
                                                                               (rest (nth index
                                                                                          (rest formatted))))
                                                                          (nth index (rest formatted)))))
                                                :collect item)))))
                    (if (or network-changed system)
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
                        (list :oob-reload associated-node-ids)))))))))

;; (defun spec-graph-interface (&key package file-name graph-key holder-id associated-node-ids
;;                                node-template-key link-template-key node-indices-key)
;;   (let ((el-width) (el-height) (formatted)
;;         (graph-base) (graph-data) (orig-data) (index 0) (sub-index) (nodes-order)
;;         (node-template (second (from-system-file package file-name node-template-key)))
;;         (link-template (second (from-system-file package file-name link-template-key)))
;;         (indices-form (from-system-file package file-name node-indices-key)))
    
;;     (lambda (context input)
;;       (unless graph-base
;;         (setf graph-base  (from-system-file package file-name graph-key)
;;               orig-data   (third graph-base)
;;               nodes-order (let* ((indices (second indices-form)))
;;                             ;; TODO: Make this just (apply #'vector ...)
;;                             (make-array (length indices) :initial-contents indices))
;;               graph-data  (format-graph-spec-to-edit (copy-tree orig-data) nodes-order)
;;               formatted   (copy-graph-spec graph-data)))

;;       ;; (print (list :abcd orig-data graph-data formatted))
;;       ;; (print (list :in input))
;;       (if (and (assoc "action" input :test #'string=)
;;                (string= "open" (rest (assoc "action" input :test #'string=))))
;;           (let* ((path-str (make-string-input-stream
;;                             (rest (assoc "path" input :test #'string=))))
;;                  (path (loop :for c := (read path-str nil) :while c :collect c)))
;;             (if (not (second path)) (setf index (first path) sub-index nil)
;;                 (destructuring-bind (i si) path
;;                   (setf index i sub-index si)))
;;             ;; (print (list :nnn index))
;;             ;; (close path-str)
;;             (list :oob-reload associated-node-ids))
;;           (let ((network-changed))
;;             (when (and input (assoc "width" input :test #'string=))
;;               (setf el-width  (rest (assoc "width"  input :test #'string=))
;;                     el-height (rest (assoc "height" input :test #'string=))))

;;             (when (and input (assoc "path" input :test #'string=))
;;               (let ((action (rest (assoc "action" input :test #'string=)))
;;                     (inst (make-string-input-stream
;;                            (rest (assoc "path" input :test #'string=)))))
;;                 (dgraph-interface
;;                  graph-data formatted nodes-order
;;                  :path (loop :for c := (read inst nil) :while c :collect c)
;;                  :to-open (string= action "expand")
;;                  :at-path (if (not (string= action "open"))
;;                               nil (lambda (item)
;;                                     ;; (setf (symbol-value
;;                                     ;;        (intern "*ACTIVE-GRAPH-ITEM*" (string package)))
;;                                     ;;       item)
;;                                     )))
;;                 (setf network-changed t)))

;;             (when (and (assoc :action input :test #'eq)
;;                        (string= "saveNode" (rest (assoc :action input :test #'eq))))
;;               (meta-revise (if sub-index (first (nth sub-index
;;                                                      (rest (nth index (rest formatted)))))
;;                                (cdar (nth index (rest formatted))))
;;                            input t)
;;               (meta-revise (first (if sub-index
;;                                       (nth sub-index (rest (nth index (rest orig-data))))
;;                                       (nth index (rest orig-data))))
;;                            input t)
;;               ;; (print (list :aabb formatted orig-data))
;;               (setf network-changed t))

;;             (when (assoc "action" input :test #'string=)
;;               (setf network-changed t)

;;               ;; add a node
;;               (when (string= "addNode" (rest (assoc "action" input :test #'string=)))
;;                 ;; add newest node index to end of indices
;;                 (let ((indices (from-system-file package file-name node-indices-key)))
;;                   (rplacd (last formatted)
;;                           (list (list (cons (cons :index (length (second indices-form)))
;;                                             (first node-template)))))
;;                   (rplacd (last (second indices-form))
;;                           (list (length (second indices-form))))
;;                   (rplacd (last orig-data) (list node-template))
;;                   (setf nodes-order (let* ((indices (second indices-form)))
;;                                       (make-array (length indices)
;;                                                   :initial-contents indices))
;;                         (from-system-file package file-name node-indices-key)
;;                         (list (first indices)
;;                               (append (second indices) (list (length (second indices))))))))

;;               ;; add a link between nodes
;;               (when (string= "addLink" (rest (assoc "action" input :test #'string=)))
;;                 ;; (print (list :si sub-index (rest (nth index (rest orig-data)))
;;                 ;;              (nth index (rest orig-data))))
;;                 (if sub-index (rplacd (nth sub-index (rest (nth index (rest orig-data))))
;;                                       (cons link-template
;;                                             (nthcdr (1+ sub-index)
;;                                                     (rest (nth index (rest orig-data))))))
;;                     (if (rest (nth index (rest orig-data)))
;;                         (rplacd (last (rest (nth index (rest orig-data))))
;;                                 (list link-template))
;;                         (rplacd (nth index (rest orig-data))
;;                                 (list link-template))))
;;                 ;; (print 700)
;;                 (if sub-index (rplacd (nth sub-index (rest (nth index (rest graph-data))))
;;                                       (cons link-template
;;                                             (nthcdr (1+ sub-index)
;;                                                     (rest (nth index (rest graph-data))))))
;;                     (if (rest (nth index (rest graph-data)))
;;                         (rplacd (last (rest (nth index (rest graph-data))))
;;                                 (list link-template))
;;                         (rplacd (nth index (rest graph-data))
;;                                 (list link-template))))
;;                 (if sub-index (rplacd (nth sub-index (rest (nth index (rest formatted))))
;;                                       (cons link-template
;;                                             (nthcdr (1+ sub-index)
;;                                                     (rest (nth index (rest formatted))))))
;;                     (if (rest (nth index (rest formatted)))
;;                         (rplacd (last (rest (nth index (rest formatted))))
;;                                 (list link-template))
;;                         (rplacd (nth index (rest formatted))
;;                                 (list link-template)))))

;;               ;; delete a node or link
;;               (when (string= "deleteItem" (rest (assoc "action" input :test #'string=)))
;;                 (if sub-index (rplaca (nth sub-index (rest (nth index orig-data)))
;;                                       (nth (1+ sub-index)
;;                                            (rest (nth index orig-data))))
;;                     (rplaca (nth index orig-data) (nth (1+ index) orig-data)))
;;                 (if sub-index (rplaca (nth sub-index (rest (nth index formatted)))
;;                                       (nth (1+ sub-index)
;;                                            (rest (nth index formatted))))
;;                     (rplaca (nth index formatted) (nth (1+ index) formatted))))

;;               ;; shifting a node is the most complicated operation,
;;               ;; requiring that the graph be rebuilt
;;               (when (string= "shiftNode" (rest (assoc "action" input :test #'string=)))
;;                 ;; add newest node index to end of indices
;;                 (setf network-changed nil)
;;                 (let* ((index-str (make-string-input-stream
;;                                    (rest (assoc "index" input :test #'string=))))
;;                        (pos-str (make-string-input-stream
;;                                  (rest (assoc "target" input :test #'string=))))
;;                        (indices (loop :for c := (read index-str nil) :while c :collect c))
;;                        (posx (loop :for c := (read pos-str nil) :while c :collect c))
;;                        (index (or (second indices) (first indices)))
;;                        (node-index (if (second indices) (first indices) nil))
;;                        (position (or (second posx) (first posx)))
;;                        (pos-parent (if (second posx) (first posx) nil)))
                  
;;                   (symbol-macrolet ((formatted2 (rest formatted))
;;                                     (graph-data2 (rest graph-data)))

;;                     (if node-index ;; links are being sorted
;;                         (when (= node-index pos-parent)
;;                           (let ((orig-link (nth index (rest (nth node-index graph-data2))))
;;                                 (orig-flink (nth index (rest (nth node-index (rest orig-data))))))

;;                             (if (zerop index) (setf (rest (nth node-index (rest orig-data)))
;;                                                     (cddr (nth node-index (rest orig-data))))
;;                                 (rplacd (nthcdr (1- index)
;;                                                 (rest (nth node-index (rest orig-data))))
;;                                         (rest (nthcdr index (rest (nth node-index
;;                                                                        (rest orig-data)))))))

;;                             (if (zerop position) (setf (rest (nth node-index (rest orig-data)))
;;                                                        (cons orig-flink
;;                                                              (rest (nth node-index
;;                                                                         (rest orig-data)))))
;;                                 (rplacd (nthcdr (1- position) (rest (nth node-index (rest orig-data))))
;;                                         (cons orig-flink
;;                                               (nthcdr position
;;                                                       (rest (nth node-index (rest orig-data)))))))

;;                             ;; (print (list :tt orig-data))
                            
;;                             (if (zerop index) (setf (cddr (nth node-index graph-data2))
;;                                                     (cdddr (nth node-index graph-data2)))
;;                                 (rplacd (nthcdr (1- index)
;;                                                 (cddr (nth node-index graph-data2)))
;;                                         (rest (nthcdr index (cddr (nth node-index
;;                                                                        graph-data2))))))
                            
;;                             (if (zerop position) (setf (cddr (nth node-index graph-data2))
;;                                                        (cons orig-link
;;                                                              (cddr (nth node-index
;;                                                                         graph-data2))))
;;                                 (rplacd (nthcdr (1- position)
;;                                                 (cddr (nth node-index graph-data2)))
;;                                         (cons orig-link
;;                                               (rest (nthcdr position
;;                                                             (cddr (nth node-index
;;                                                                        graph-data2)))))))
                            
;;                             ;; (if (zerop position) (setf graph-data2 (cons orig-link graph-data2))
;;                             ;;     (rplacd (nthcdr (1- position) graph-data2)
;;                             ;;             (cons orig-link (nthcdr position graph-data2))))

;;                             ;; (print (list :xyz orig-data graph-data formatted2))
                            
;;                             (labels ((lsort (form ix subix)
;;                                        ;; (print (list :fr form))
;;                                        (when (and (eq :index (caaar form))
;;                                                   (= ix (cdaar form)))
;;                                          (let ((olink (nth subix (rest form))))
;;                                            ;; (print (list :ol olink))
;;                                            (if (zerop index) (setf (rest form) (cddr form))
;;                                                (rplacd (nthcdr (1- subix) (rest form))
;;                                                        (rest (nthcdr subix (rest form)))))
;;                                            (if (zerop position)
;;                                                (setf (rest form)
;;                                                      (cons olink (rest form)))
;;                                                (rplacd (nthcdr (1- position) (rest form))
;;                                                        (cons olink (nthcdr position
;;                                                                            (rest form)))))))
;;                                        (loop :for item :in (rest form)
;;                                              :when (and (listp item) (second item)
;;                                                         (listp (second item)))
;;                                                :do ;; (print (list :ri
;;                                                    ;;              form
;;                                                    ;;              (rest item) (rest form)))
;;                                                    (lsort (rest item) ix subix))))
;;                               (loop :for item :in (rest formatted)
;;                                     :do (lsort item node-index index))
;;                               )))
;;                         ;; nodes are being sorted
;;                         (let ((original   (nth index (second indices-form)))
;;                               (orig-node  (nth index formatted2))
;;                               (orig-gnode (nth index graph-data2)))

;;                           (if (zerop index) (setf formatted2 (rest formatted2))
;;                               (rplacd (nthcdr (1- index) formatted2)
;;                                       (rest (nthcdr index formatted2))))

;;                           (if (zerop position) (setf formatted2 (cons orig-node formatted2))
;;                               (rplacd (nthcdr (1- position) formatted2)
;;                                       (cons orig-node (nthcdr position formatted2))))

;;                           (if (zerop index) (setf graph-data2 (rest graph-data2))
;;                               (rplacd (nthcdr (1- index) graph-data2)
;;                                       (rest (nthcdr index graph-data2))))

;;                           (if (zerop position) (setf graph-data2 (cons orig-node graph-data2))
;;                               (rplacd (nthcdr (1- position) graph-data2)
;;                                       (cons orig-node (nthcdr position graph-data2))))

;;                           (if (zerop index) (setf graph-data2 (rest orig-data))
;;                               (rplacd (nthcdr (1- index) orig-data)
;;                                       (rest (nthcdr index orig-data))))

;;                           (if (zerop position) (setf graph-data2 (cons orig-gnode orig-data))
;;                               (rplacd (nthcdr (1- position) orig-data)
;;                                       (cons orig-gnode (nthcdr position orig-data))))

;;                           (if (zerop index) (setf (second indices-form) (cdadr indices-form))
;;                               (rplacd (nthcdr (1- index) (second indices-form))
;;                                       (rest (nthcdr index (second indices-form)))))

;;                           (if (zerop position)
;;                               (setf (second indices-form) (cons original (second indices-form)))
;;                               (rplacd (nthcdr (1- position) (second indices-form))
;;                                       (cons original (nthcdr position
;;                                                              (second indices-form)))))
                          
;;                           (setf nodes-order (let* ((indices (second indices-form)))
;;                                               (make-array (length indices)
;;                                                           :initial-contents indices))
;;                                 (from-system-file package file-name node-indices-key)
;;                                 indices-form))))))

;;               (when (string= "connect" (rest (assoc "action" input :test #'string=)))
;;                 (let ((this-index (read-from-string
;;                                    (rest (assoc "index" input :test #'string=)))))
;;                   ;; (print (list :ti this-index orig-data graph-data))
;;                   (labels ((relink (form new ix subix)
;;                              (if (and (eq :index (caaar form))
;;                                       (= ix (cdaar form)))
;;                                  (setf (second (nth (+ subix (if (eq :closed (second form)) 1 0))
;;                                                     (rest form)))
;;                                        new)
;;                                  (loop :for item :in (rest form)
;;                                        :when (and (listp item) (second item)
;;                                                   (listp (second item)))
;;                                          :do (relink (second item) new ix subix)))))

;;                     ;; (print (list :oo (second (nth sub-index
;;                     ;;                               (rest (nth index (rest orig-data)))))
;;                     ;;              sub-index
;;                     ;;              (nth sub-index (rest (nth index (rest graph-data))))))

;;                     (rplacd (nth sub-index (rest (nth index (rest orig-data))))
;;                             (list (aref nodes-order this-index)))
;;                     (rplacd (nth (1+ sub-index)
;;                                  (rest (nth index (rest graph-data))))
;;                             (list (aref nodes-order this-index)))
                    
;;                     (loop :for item :in (rest formatted)
;;                           :do (relink item (nth this-index (rest graph-data))
;;                                       index sub-index))))))

;;             (when network-changed ;; assign changes to the file when they happen
;;               ;; (print (list :ch "CHANGED" graph-base))
;;               (setf (from-system-file package file-name graph-key) graph-base)
;;               ;; (instantiate-priority-macro-reader (asdf:load-system package)) ;; RESTORE THIS
;;               )
            
;;             ;; (print (list :af (assoc :face input :test #'eq)))
;;             ;; (print (list :ew el-width formatted))
;;             ;; the output-stream is created in the seed package - best elsewhere?
;;             ;; (print (list :eoeo input))
;;             (if (and (assoc :face input :test #'eq)
;;                      (string= "graphNode" (rest (assoc :face input :test #'eq))))
;;                 (render (funcall context :medium)
;;                         (dx ((uic-frame :type (:meta-code)))
;;                             (express
;;                              (funcall (lambda (items)
;;                                         `(meta ,items (:type :enum) (:fx :uic-series)))
;;                                       (loop :for item :in (funcall
;;                                                            ;; nodes have an (index . N)
;;                                                            ;; form to omit, links don't
;;                                                            (if sub-index #'identity #'rest)
;;                                                            (first (if sub-index
;;                                                                       (nth sub-index
;;                                                                            (rest (nth index
;;                                                                                       (rest formatted))))
;;                                                                       (nth index (rest formatted)))))
;;                                             :collect item)))))
;;                 (if (or network-changed (assoc :system input))
;;                     (progn (setf *giface-output-stream* (make-string-output-stream))
;;                            ;; (print (list :nc input))
;;                            ;; (print (list :form formatted))
;;                            (eval `(cl-who:with-html-output (*giface-output-stream*)
;;                                     ,(svrender-graph
;;                                       (rest formatted)
;;                                       :width el-width :height el-height
;;                                       :point (list index sub-index)
;;                                       :id-string holder-id :branch-name graph-key)))
;;                            (let ((output (get-output-stream-string *giface-output-stream*)))
;;                              ;; (print (list :out output))
;;                              ;; (close output-stream)
;;                              output))
;;                     (list :oob-reload associated-node-ids))))))))

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
                                              $el mode (create action "open" path path)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id "reload")))))
                             expand-node   (lambda (path)
                                             (fetch-contact
                                              $el mode (create action "expand" path path)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id "reload")))))
                             contract-node (lambda (path)
                                             (fetch-contact
                                              $el mode (create action "contract" path path)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id "reload")))))
                             connect-node  (lambda (index)
                                             (fetch-contact
                                              $el mode (create action "connect" index index)
                                              (lambda (data)
                                                (chain htmx (trigger ,branch-id "reload")))))
                             enable-drag   (lambda (svg)
                                             (let ((selected-element null) (dragging-link false)
                                                   (drag-node null) (dragging-index nil))
                                               (defun shift-node (index target)
                                                 (fetch-contact
                                                  $el mode (create action "shiftNode" index index target target)
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
           (loop :for item :in form :collect (if (not (string= "FX" (string (first item))))
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
                    ;; (print (list :exp is-expandable item))
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
                                   (:circle :class "inner-circle" :cx 16 :cy 0 :r 12)
                                   (:text :class "icon" :x 10.5 :y 8 "?"))
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
