(defpackage #:seed.branch.demo.sheet
  (:use #:cl)
  (:shadowing-import-from #:seed.generate #:seed #:branch
                          #:interface-format-form #:load-seed-system
                          #:syspath #:file-to-string
                          #:system-file-to-string #:adapt-from-alist #:adapt-from-json
                          #:from-system-file #:build-templater #:get-template-metadata
                          #:astr #:setf-value #:abind #:cbind #:text-wrap #:of-array-spec)
  (:shadowing-import-from #:seed.modulate #:dx #:render #:uim-web #:uim-web-stream
                          #:uic-anchor #:uic-frame #:uic-series #:uic-grid
                          #:uicc-button #:uicc-field #:uicc-select #:uich-candle #:spec-graph-interface
                          #:role-cast #:uir-call #:uir-call-c #:uir-call-b #:uir-call-form
                          #:uir-actuatable #:uir-sortable #:uir-reducable #:uir-toggle)
  (:shadowing-import-from #:pla.browser.maple #:*flat-sources* #:retrieve-flat-source
                          #:implement-start-controls #:write-to-file
                          #:build-static-page #:concat-files #:build-styles #:build-script-pdnd
                          #:build-script-cmirror #:build-script-pmirror #:build-script-misc)
  (:shadowing-import-from #:seed.access #:authorize))

(in-package :seed.branch.demo.sheet)

(defparameter *system* :demo.sheet)

(seed :seed.branch.demo.sheet
  (:linking . :demo.sheet)
  (:access :systems systems :to-grow grow :staccess (state . of-state)))

(defun buttonize (item index)
  (declare (ignore index))
  (make-instance 'uicc-button :base item :type '(:local)))

(defun buttonize-calling (item index)
  (declare (ignore index))
  (make-instance 'uicc-button :base item))

(defun buttonize-calling-remote (item index)
  (declare (ignore index))
  (make-instance 'uicc-button :base item :type '(:remote)))

(branch :summary
  (let ((layout '((:main :code-view) (:cells :cells-view) nil
                  (:graph :graph-overview) (:graph :graph-node) nil
                  (:code :edit-view) (:main :code-view))))
    (lambda (state input)
      (declare (ignore state input))
      layout)))

(branch :view
  (adapt-from-json :path :session)
  (lambda (state input)
    (destructuring-bind (&key session &allow-other-keys) input
      ;; (print (list :bp package (funcall state :view-point)))
      (let ((context (first session))
            (summary (grow :demo.sheet :summary))
            (branch-point (or (of-state :- :view-point) 0))
            (start-point 0) (interval-found) (search-complete))
        
        (loop :for s :in summary :for sx :from 0 :until search-complete 
              :do (unless s (if interval-found (setf search-complete t)
                                (setf start-point (1+ sx))))
                  (when (= sx branch-point) (setf interval-found t)))

        (dx (uic-series :layout (:horizontal :even) :type (:workspace :even))
            (loop :for l :in (nthcdr start-point summary) :while l
                  :collect (dx (uic-series :layout (:vertical :of 3 1 1 1)
                                            :join   (list :demo.sheet (first l))
                                            :type   (:column)
                                            :mode   (grow :demo.sheet (first l)
                                                          context (list :identity (second l))))
                               (dx (uic-series :type (:ui :header))
                                   (second l)
                                   (grow :demo.sheet (first l)
                                         context (list :uimod :header-controls)))
                               (dx (uic-frame :name (second l) :type (:body)
                                               :access :demo.sheet)
                                   (first l))
                               (dx (uic-series :type (:ui :footer))
                                   (list (grow :demo.sheet (first l)
                                               context (list :uimod :footer-controls)))))))))))

(branch :main
  (adapt-from-json :text)
  (lambda (state input)
    (destructuring-bind (&key identity uimod text &allow-other-keys) input
      (cond (identity)
            (uimod (case uimod (:header-controls (dx (uic-series :map #'buttonize :type (:ui :controls))
                                                     (list :save :abc)))
                         (:footer-controls (dx (uic-series :map #'buttonize :type (:ui :controls))
                                               (list :save)))))
            (t (if text
                   (if (zerop (first text))
                       (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
                                                                :main :as-string t)
                                              :unwrap t :syntax :progn :trailing-newlines 2))
                       (let ((input (apply #'concatenate 'string
                                           (loop :for i :in text :append (list i '(#\Newline))))))
                         (setf (from-system-file :demo.sheet "sheet.lisp" :main :as-string t)
                               (text-wrap input :syntax :progn))
                         (load-seed-system package)
                         (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
                                                                  :main :as-string t)
                                                :unwrap t :syntax :progn))))
                   (render (funcall state nil :medium)
                           (dx (uicc-field :type (:code))
                               :demo.sheet :main))))))))
  
(branch :cells
  (adapt-from-json :cells)
  (lambda (state input)
    (destructuring-bind (&key identity uimod cells &allow-other-keys) input
      (cond (identity)
            (uimod (case uimod (:header-controls (dx (uic-series :map #'buttonize :type (:ui :controls))
                                                     (list :save :abc)))
                         (:footer-controls (dx (uic-series :map #'buttonize :type (:ui :controls))
                                               (list :save)))))
            (cells (let ((display-baseline))
                     (if (not (zerop (first cells)))
                         (if (symbolp (first input))
                             (cond ((eq :toggle-baseline (first input))
                                    (setf display-baseline (not display-baseline))))
                             (let ((original (from-system-file :demo.sheet "sheet.lisp" :cells)))
                               (setf (of-array-spec :initial-contents (setf-value original))
                                     `(quote ,(loop :for row :in input
                                                    :collect (loop :for cell :in row
                                                                   :collect (parse-number:parse-number
                                                                             cell))))
                                     (from-system-file :demo.sheet "sheet.lisp" :cells) original)
                               ;; (instantiate-priority-macro-reader (asdf:load-system package))
                               (load-seed-system :demo.sheet)))
                         (if display-baseline
                             (encode (symbol-value (intern "*CELL-MATRIX*" (string :demo.sheet))))
                             (list :ty :ar :ct
                                   (second (of-array-spec :initial-contents
                                                          (setf-value
                                                           (from-system-file
                                                            :demo.sheet "sheet.lisp" :cells)))))))))
            (t (render (funcall state nil :medium)
                       (dx (uic-grid :type (:code))
                           :demo.sheet :cells)))))))

(let ((interactor
        (spec-graph-interface
         :package :demo.sheet :file-name "sheet.lisp" :holder-id "graphOverview"
         :associated-node-ids #("graphNode") :node-template-key :graph-node-template
         :link-template-key :graph-link-template :graph-key :graph
         :node-indices-key :graph-node-indices)))
  (branch :graph
    (adapt-from-json :action :index :target :width :height :path :face
                             :title :image :dialog)
    (adapt-from-alist :system :branch :face)
    (lambda (state input)
      (destructuring-bind (&key identity uimod action index target width height path face &allow-other-keys)
          input
        (cond (identity (case identity
                          (:graph-overview :graph-breadth)
                          (:graph-node     :meta-code-form)))
              ((eq uimod :header-controls) (dx (uic-series :type (:ui :controls)
                                                           :map #'buttonize-calling-remote)
                                               (list :add-node :add-link)))
              ((eq uimod :footer-controls) (dx (uic-series :map #'buttonize-calling :type (:ui :controls))
                                               (list :save)))
              (t (funcall interactor (funcall state nil :medium) input)))))))


(branch :play
  (adapt-from-json :index)
  (adapt-from-alist :system :branch :index)
  (lambda (state input)
    (destructuring-bind (&key system branch index &allow-other-keys) input
      (unless (and (find-package 'demo.sheet)
                   (boundp (intern "*GRAPH-NODES*" "DEMO.SHEET")))
        (instantiate-priority-macro-reader (asdf:load-system :demo.sheet)))
      (unless (of-state :- :node)
        (multiple-value-bind (this-node selector-out)
            (seed.generate::graph-walker
             (first (symbol-value (intern "*GRAPH-NODES*" "DEMO.SHEET"))))
          (of-state :- :node     this-node)
          (of-state :- :selector selector-out)))
      (when index
        (multiple-value-bind (this-node selector-out)
            (funcall (of-state :- :selector) (read-from-string index))
          (of-state :- :node     this-node)
          (of-state :- :selector selector-out)))
      (let* ((out (make-string-output-stream))
             (dialog (rest (assoc :dialog (first (of-state :- :node)))))
             (image (rest (assoc :image (first (of-state :- :node)))))
             (imsym (intern (string-upcase image) "KEYWORD"))
             (responses (mapcar (lambda (item) (rest (assoc :dialog item)))
                                (second (of-state :- :node)))))
        (spinneret:interpret-html-tree
         `(:div :class "scenario-frame"
                ,@(unless (eq imsym :none)
                    `(:style ,(format nil "background-image: url(./static/characters/~a.jpg); background-size: 500px; background-position-y: top; background-position-x: right; background-repeat: no-repeat;"
                                      image)))
                (:div :class "setting"
                      (:div :class "dialog" ,dialog)
                      (:ol :class "responses"
                           ,@(loop :for response :in responses :for ix :from 0
                                   :collect
                                   (list :li :|hx-on:click|
                                         (parenscript:ps (parenscript:chain
                                                          htmx (trigger this "reload"
                                                                        (parenscript:create
                                                                         index (parenscript:lisp ix))))
                                           (parenscript:chain console (log "hello")))
                                         :hx-vals (seed.generate::json-convert-to (list :index ix))
                                         response)))))
         :stream out)
        (get-output-stream-string out)))))

(let ((files (list :setup :sheet)))
  (branch :code
    (adapt-from-json :text :select)
    (lambda (state input)
      (destructuring-bind (&key select text uimod &allow-other-keys) input
        (print (list :ddd (macroexpand `(of-state :- :open-file))))
        (when state
          (unless (of-state :- :open-file)
            (print :eee)
            (of-state :- :open-file (first files))
            (with-open-file (stream (asdf:system-relative-pathname
                                     *system* (format nil "./~a.lisp" (string-downcase (first files))))
			            :direction :input)
              (let ((contents (make-string (file-length stream))))
                (print (list :ccc))
                (read-sequence contents stream)
                (print (list :rrs stream))
                (of-state :- :code contents))))
          (print (list :st (of-state :- :code)))
          (cond (select (of-state :- :open-file (nth select files))
                  (with-open-file (stream (asdf:system-relative-pathname
                                           *system* (format nil "./~a.lisp"
                                                            (string-downcase (nth select files))))
			                  :direction :input)
                    (let ((contents (make-string (file-length stream))))
                      (read-sequence contents stream)
                      (of-state :- :code contents))))
                (uimod (case uimod (:header-controls (dx (uic-series :map #'buttonize :type (:ui :controls))
                                                         (list :save :abc)))
                             (:footer-controls (dx (uic-series :map #'buttonize :type (:ui :controls))
                                                   (list :save)))))
                (t (of-state :- :view-point)
                   (if text (list :text (of-state :- :code))
                       (render (funcall state nil :medium)
                               (dx (uicc-field :type (:code))
                                   :demo.sheet :code))))))))))
