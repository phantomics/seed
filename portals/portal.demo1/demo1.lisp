;;;; portal.demo1.lisp

(in-package #:portal.demo1)

(defvar *users*)
(defvar *pksym* (intern (package-name *package*) "KEYWORD"))

(setf *users* (make-hash-table :test #'equal))

(defun get-data (user &optional property)
  (if property (getf (gethash user *users*) property)
      (gethash user *users*)))

;; (setf *portal.demo1.session* (make-hash-table :test #'equal))

;; (auth-setup *portal.demo1.session* #'get-data)

(defmacro get-user (username)
  `(gethash ,username *users*))

(defun contact-stop ())
(defun contact-restart ())

(defun contact-start ()
  (let ((pkg-name (intern (package-name *package*) "KEYWORD")))
    (multiple-value-bind (stopper restarter)
        (http-contact-service-start
         :package-name pkg-name :port 9090
         :interactor-fetch (lambda (params session-api)
                             (let* ((portal-form (rest (assoc "portal" params :test #'string=)))
                                    (branch-form (rest (assoc "branch" params :test #'string=))))
                               (json-convert-to (interface-interact
                                                 (if portal-form (intern portal-form "KEYWORD") nil)
                                                 (if branch-form (intern branch-form "KEYWORD") nil)
                                                 session-api (rest (assoc "input" params :test #'string=))))))
         :renderer-fetch (lambda (params session-api)
                           (print (list :par params session-api))
                           (let* ((system-form (string-upcase (rest (assoc "system" params :test #'string=))))
                                  (branch-form (string-upcase (rest (assoc "branch" params :test #'string=)))))
                             ;; (interface-interact (if system-form (intern system-form "KEYWORD") nil)
                             ;;                     (if branch-form (intern branch-form "KEYWORD") nil)
                             ;;                     session-api
                             ;;                     (loop :for p :in params
                             ;;                           :collect (cons (symbol-munger:camel-case->keyword
                             ;;                                           (first p))
                             ;;                                          (rest p))))
                             (grow (intern branch-form "KEYWORD")
                                   session-api (loop :for p :in params
                                                     :collect (cons (symbol-munger:camel-case->keyword
                                                                     (first p))
                                                                    (rest p))))
                             )))
      (setf (symbol-function 'contact-stop)    stopper
            (symbol-function 'contact-restart) restarter))))

;; (defmethod render-web :around ((comp ui-component) &optional stream)
;;   (if stream (call-next-method)
;;       (let ((spinneret:*always-quote* t)
;;             (spinneret:*html* (make-string-output-stream)))
;;         (render-web comp spinneret:*html*)
;;         (get-output-stream-string spinneret:*html*))))

;; (defmethod render-web ((comp string) &optional stream)
;;   (if (not stream) nil (format stream comp)))

;; (defmethod render-web ((comp uic-caption-heading) &optional stream)
;;   (spinneret:with-html (:h2 (lisp (uic-caption-text comp)))))


(defun build-static-page (portal-sym relative-path)
  (with-open-file (spinneret:*html*
                   (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                                  (format nil "./~a/index.html" relative-path))
		   :direction :output :if-exists :supersede :if-does-not-exist :create)
    (spinneret:with-html
      (:html (:head (:script (paren6::ps (defvar |*__PS_MV_REG*|)
                               (setf (@ window seed-data) (create))))
                    (:link :rel "stylesheet" :href "./build/vendor.css")
                    (:link :rel "stylesheet" :href "./build/app.css"))
             (:body (:div :id "main" :class "ui" :hx-post "/render/"
                          :hx-trigger "load, reload, submit, refresh"
                          :hx-vals (json-convert-to (list :system portal-sym
                                                          :branch :view))
                          :x-data (ps (create context (create system (lisp (string portal-sym))
                                                              branch "VIEW"))))
                    (:script :src "./static/misc.js")
                    (:script :src "./build/vendor.js")
                    (:script :src "./npm-interfaces/codemirror/build/iface.bundle.js"))))))


;; (defun build-static-page (portal-sym relative-path)
;;   (with-open-file (stream (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
;;                                                          (format nil "./~a/index.html" relative-path))
;; 			  :direction :output :if-exists :supersede :if-does-not-exist :create)
;;     (cl-who:with-html-output (stream)
;;       (:html (:head (:script (paren6::ps (defvar |*__PS_MV_REG*|)
;;                                (setf (@ window seed-data) (create))))
;;                     (:link :rel "stylesheet" :href "./build/vendor.css")
;;                     (:link :rel "stylesheet" :href "./build/app.css"))
;;              (:body (:div :id "main" :class "ui" :hx-post "/render/"
;;                           :hx-trigger "load, reload, submit"
;;                           :hx-vals (json-convert-to (list :system portal-sym
;;                                                           :branch :view))
;;                           :x-data (ps-inline (create context (create system (lisp (string-downcase portal-sym))
;;                                                                branch "view"
;;                                                                container this))))
;;                     (:script :src "./static/misc.js")
;;                     (:script :src "./build/vendor.js")
;;                     (:script :src "./npm-interfaces/codemirror/build/iface.bundle.js")
;;                     )))))

;; (build-static-page :portal.demo1 "ui-browser")

(defun build-css (relative-path)
  (with-open-file (stream (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                                         (format nil "./~a/build/app.css" relative-path))
			  :direction :output :if-exists :supersede :if-does-not-exist :create)
    (format
     stream
     (lass:compile-and-write
      `(body :background "#f2f2f2")

      `(|#root|	:width "100%")

      
      `((|#main| > .stack)
        :margin "0 auto;"
        :width 24rem
        :height "100%"
        (.heading :text-align center)
        (form :text-align center
              (.input :margin "0 auto")))
      
      `(.container :background "#fff")
      
      `(.sidebar
        :background "#d5d5d5"
        (.heading :font-size "160%" :font-weight "bold"
                  :padding 8px :margin-bottom 6px)
        (.form :font-size "120%" :font-weight "bold" :padding 3px 12px))
      
      `(.ui.grid :height "100%" (.group :height "100%"))

      `(.ui.grid-layout
        :display "grid" :height "100%"
        (.column
         :display grid :overflow auto :grid-template-rows 1fr
         (.container :position "relative" :height "100%" :display grid)
         (.container.column-inner
          :padding 0 :overflow auto :grid-template-columns "100%"
          :grid-template-rows "[header-start] auto [header-end] 1fr [footer-start] auto [footer-end]"
          
          (.header :grid-row-start "header-start" :grid-row-end "header-end")
          ;; (.container-wrap
          ;; :grid-row-start "header-end"
          ;; :grid-row-end   "footer-start"
          (.sub-container :grid-row-start "header-end" :grid-row-end   "footer-start"
                          :overflow-y auto)
          (.footer :grid-row-start "footer-start" :grid-row-end "footer-end")
          ;; ((:and .container.column (:nth-child 1))
          ;;  :grid-row-start "header-start")
          ;; ((:and .container.column (:nth-child 2))
          ;;  :grid-row-start "header-end")
          ;; ((:and .container.column (:nth-child 3))
          ;;  :grid-row-start "footer-start")
          )))

      `(.ui.grid-layout.main
        :grid-template-rows "100%"
        :grid-template-columns "[start] 12% [start-end] 88%")

      `((.ui.grid-layout.main > sidebar)
        :grid-column-start 1)

      `((.ui.grid-layout.main > main)
        :grid-column-start 2)

      `(.ui.grid-layout.workspace.even
        :grid-template-columns "8.333% 8.333% 8.333% 8.333% 8.333% 8.333% 8.333% 8.333% 8.333% 8.333% 8.333% 8.333%")
      
      `((:and (.ui.grid-layout.workspace.even > .column)
              (:nth-child 1))
        :grid-column-start 1 :grid-column-end 7)
      
      `((:and (.ui.grid-layout.workspace.even > .column)
              (:nth-child 2))
        :grid-column-start 7 :grid-column-end 13)

      `(.ui.grid-layout.workspace
        (.column :padding 0 10px))
      
      `((:or .ui.header .ui.footer)
        :width "100%" :padding 8px :margin 0 :background "#eee"
        :display grid :grid-template-columns "20% 80%" :grid-template-rows 100%)

      `(.ui.header
        :border-bottom "2px solid #ccc"
        (h2.branch-name :margin 0 :grid-column-start 1)
        (.controls-holder :text-align right :grid-column-end 3))
      
      `(.ui.footer :bottom 0 :border-top "2px solid #ccc")

      `(.form.text (.cm-editor :height 100%))
      
      ;; `(.container
      ;;   (.sub-container :height 100%
      ;;                   :width 100%))

      `(form :padding 0.64em
             (.input.fluid :margin-bottom 0.32em)
             (.ui.selection.dropdown :min-height 3em :margin-bottom 0.32em)
             )
      
      ;; d3 graph view styles
      
      `((:or .d3view-graph-foldout .svg-visualizer)
        :width 100%
        (.handle (.main :fill "#fff")
                 (.center :fill "#ccc")
                 (.arrow :fill none :stroke "#999" :stroke-width 2)
                 (.outer-arrow :fill none :stroke "#bbb" :stroke-width 4))
        (.link :fill none :stroke "#bbb" :stroke-width 1.5)
        (.node-group
         (.title-frame :cursor "pointer"
                       (rect :opacity 0 :fill "#efefef" :stroke "#ccc" :stroke-width 0)
                       (.description :pointer-events none)
                       (.handle :opacity 0 (.outer-arrow :opacity 0))
                       ((:and .handle :hover)
                        (.outer-arrow :opacity 1))                       
                       (.linker :opacity 0
                                (.main :fill "#fff")
                                (.center :fill "#ccc")
                                (.arrow :fill "#999")
                                (.outer-arrow :opacity 0 :fill none :stroke "#bbb" :stroke-width 4)))
         (.expand-control :cursor "pointer"
                          (.button-backing :fill "#fff")
                          (.button-circle  :fill "#bbb")
                          (rect :fill "#fff"))
         (.circle-glyph :cursor "pointer"
                        (.outer-circle :fill "#ccc")
                        (.inner-circle :fill "#fff")))
        (.node-group.selected
         (.title-frame (rect :opacity 1 :stroke-width 1)))
        ((:and .node-group :hover)
         (.title-frame (rect :opacity 1))
         (.handle :opacity 1)
         (.linker :opacity 1))
        (.drag-indicator :opacity 0 :fill "#000")
        (.mouse-transparent :pointer-events none))

      `(.svg-visualizer.for-node.drag
        ((:and .node-group :|not(.dragging)| :hover)
         (.handle :opacity 0)
         (.title-frame (rect :opacity 0))
         ;; title frame doesn't show in drag-over mode
         (.drag-indicator.for-node :opacity 0.2)))

      `(.svg-visualizer.for-link.drag
        ((:and .node-group.link-group :|not(.dragging)| :hover)
         (.handle :opacity 0)
         (.title-frame (rect :opacity 0))
         ;; title frame doesn't show in drag-over mode
         (.drag-indicator :opacity 0.2)))

      `(.scenario-frame
        :height "100%" :display grid :grid-template-columns "100%"
        :background "#000" :color "#ddd" :font-family serif :font-weight bold
        :line-height 2.6em
        :grid-template-rows "[dialog-start] 60% [dialog-end] 40% [response-end]"
        :text-shadow "2px 2px 0 #333"
        (.setting :grid-row-end "dialog-end" :position relative
                  (.dialog :position absolute :bottom 0 :z-index 6000
                           :font-size 32px :padding 12px))
        (.responses :grid-row-start "dialog-end" :grid-row-end "response-end"
                    :z-index 5000
                    :font-size 22px :padding "16px 64px"
                    (li :cursor pointer)))
      
      ))))

;; (build-css "ui-browser")

(defun build-script-element (&key path imports constructors)
  (with-open-file (stream path :direction :output :if-exists :supersede :if-does-not-exist :create)
    (loop :for import :in imports
          :do (if (not (listp import))
                  (format stream "import '~a'~%" import)
                  (progn (format stream "import ~a" (if (listp (first import)) "{ " ""))
                         (if (listp (first import))
                             (let ((icount (1- (length (first import)))))
                               (loop :for item :in (first import) :for i :from 0
                                     :do (format stream "~a~a " (symbol-munger:lisp->camel-case item)
                                                 (if (> icount i) "," ""))))
                             (format stream "~a" (symbol-munger:lisp->camel-case (first import))))
                         (format stream "~a from '~a'~%" (if (listp (first import)) "}" "")
                                 (second import)))))
    (format stream "~%")
;;     (format stream "import './main.scss'
;; ")
    (loop :for c :in constructors :do (funcall c stream))))

(defun build-script-cmirror ()
  (build-script-element
   :path (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                        "./ui-browser/npm-interfaces/codemirror/cm-app.js")
   :imports `(((minimal-setup -editor-view) "codemirror")
              ;; ((basic-setup -editor-view) "codemirror")
              ((highlight-active-line line-numbers highlight-active-line-gutter) "@codemirror/view")
              ((-extension -editor-state -compartment -facet) "@codemirror/state")
              ((close-brackets close-brackets-keymap) "@codemirror/autocomplete")
              ((bracket-matching fold-gutter) "@codemirror/language")
              ((python) "@codemirror/lang-python")
              ((-lisp) "@codemirror/lang-lisp"))
   :constructors
   (list (lambda (stream)
           (format
            stream (paren6::ps
                     (defvar |*__PS_MV_REG*|)
                     (defvar lisp-setup (funcall (lambda ()
                                                   (list (bracket-matching)
                                                         (close-brackets)
                                                         (line-numbers)
                                                         (highlight-active-line)
                                                         (highlight-active-line-gutter)
                                                         (fold-gutter)))))
                     (setf (@ global python) python
                           (@ global create-codemirror)
                           (lambda (target data)
                             (let* ((language (new -compartment))
                                    (tab-size (new -compartment))
                                    (state
                                      (chain -editor-state
                                             (create (create doc data
                                                             extensions
                                                             (list minimal-setup
                                                                   lisp-setup
                                                                   ;; basic-setup
                                                                   (chain language (of (-lisp)))
                                                                   (chain tab-size
                                                                          (of (chain -editor-state
                                                                                     tab-size (of 4)))))
                                                             ))))
                                    (view (new (-editor-view (create state state
                                                                     parent target
                                                                     doc data)))))
                               view)))))
           ))))

;; (build-script-cmirror)

(defun build-script-misc (relative-path)
  (with-open-file (stream (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                                         (format nil "./~a/static/misc.js"
                                                                 relative-path))
			  :direction :output :if-exists :supersede :if-does-not-exist :create)
    (format
     stream
     (paren6::ps
       (setf (@ window seed-data) (create)
             (@ window seed-elements) (create))
       (defun fetch-contact (system branch input handler)
         (chain (fetch "/contact/"
                       (create method "POST"
                               body (chain -j-s-o-n (stringify (create portal system
                                                                       branch branch
                                                                       input  input)))
                               headers (create "Content-type" "application/json; charset=UTF-8")))
                (then (lambda (response) (chain response (json))))
                (then (lambda (data)
                        (chain console (log :dt data (@ data oob-reload)))
                        (if (@ data oob-reload)
                            (chain data oob-reload (for-each (lambda (item)
                                                               (chain console (log :it item))
                                                               (chain htmx (trigger (getprop seed-elements
                                                                                             item)
                                                                                    "reload"))))))
                        data))
                (then handler)))
       
       (defun fetch-contact2 (context element input)
         (chain console (log :cc context))
         (chain (fetch "/contact/"
                       (create method "POST"
                               headers (create "Content-type" "application/json; charset=UTF-8")
                               body (chain -j-s-o-n (stringify (create portal (@ context system)
                                                                       branch (@ context branch)
                                                                       input  input)))))
                (then (lambda (response) (chain response (json))))
                (then (lambda (data) (chain htmx (trigger element "refresh"))))))
         
         ))))

;; (build-script-misc "ui-browser")

(defun concat-files (out-path &rest in-paths)
  (with-open-file (output out-path :direction :output :if-exists :supersede :if-does-not-exist :create)
    (loop :for path :in in-paths
          :do (with-open-file (input path :direction :input)
                (loop :for char := (read-char input nil :eof) :until (eq char :eof)
                      :do (write-char char output))
                (princ #\Newline output)))
    :complete))

(defmacro provide-browser-script (package-sym &rest tasks)
  (cons 'progn
        (loop :for task :in tasks
              :collect (destructuring-bind (task-id &rest params) task
                         (case task-id
                           (:run-process
                            `(uiop:run-program (format nil ,@params)))
                           (:concat-static
                            `(concat-files ,(asdf:system-relative-pathname
                                             (intern (string package-sym) "KEYWORD")
                                             (rest (assoc :output-to params)))
                                           ,@(mapcar (lambda (p)
                                                       (asdf:system-relative-pathname
                                                        (intern (string package-sym) "KEYWORD") p))
                                                     (rest (assoc :paths params))))))))))

(provide-browser-script
 :portal.demo1
 ;; (:run-process "npm run --prefix '~a' build" (asdf:system-relative-pathname
 ;;                                              :portal.demo1 "./ui-browser/npm-interfaces/codemirror"))
 ;; (:concat-static
 ;;  (:paths "./ui-browser/static/misc.js"
 ;;          "./ui-browser/node_modules/d3/dist/d3.min.js" 
 ;;          "./ui-browser/node_modules/canvas-datagrid/dist/canvas-datagrid.js"
 ;;          "./ui-browser/static/codemirror.bundle.js" "./ui-browser/static/cmApp.bundle.js"
 ;;          "./ui-browser/static/alpine.js" "./ui-browser/node_modules/fomantic-ui/dist/semantic.css")
 ;;  (:output-to . "./ui-browser/build/vendor.js"))
 (:concat-static
  (:paths "./ui-browser/static/htmx.min.js"
          ;; "./ui-browser/node_modules/d3/dist/d3.min.js" 
          "./ui-browser/node_modules/canvas-datagrid/dist/canvas-datagrid.js"
          "./ui-browser/static/alpine.js"
          ;; "./ui-browser/repos/scmindent/scmindent-client.js"
          ;; "./ui-browser/node_modules/fomantic-ui/dist/semantic.js"
          )
  (:output-to . "./ui-browser/build/vendor.js"))
 (:concat-static
  ;; (:paths "./ui-browser/node_modules/fomantic-ui/dist/semantic.css")
  (:paths "./ui-browser/node_modules/bulma/css/bulma.css")
  (:output-to . "./ui-browser/build/vendor.css"))
 )

(defun build-all ()
  (build-static-page :portal.demo1 "ui-browser")
  (build-script-cmirror)
  (build-script-misc "ui-browser"))

;; (build-all)







(defpsmacro sub-view (symbol state)
  (list symbol :form state))

(defpsmacro pcl (&rest items)
  `(chain console (log ,@items)))

(defpsmacro undefp (item)
  `(= "undefined" (typeof ,item)))

;; React stuff

(defpsmacro define-fetch ()
  '(defun transact (portal branch input next-success)
    (chain j-query
     (ajax (create
	    url "./contact/"
	    type "POST"
	    data-type "json"
	    content-type "application/json; charset=utf-8"
            async false
	    data (chain -j-s-o-n (stringify (create portal portal branch branch input input)))
	    success next-success
	    error (lambda (data err) (chain console (log 11 data err))))))))

;; (defpsmacro define-component-view ()
;;   '(progn
;;     (paren6:defclass6 (-seed-view (@ -react -component))
;;      (defun constructor (props)
;;        (let ((self this))
;;          (if (undefp (@ props data))
;;              (transact "PORTAL.DEMO1" "VIEW"
;;                        (create interface-spec (list "browser" "react"))
;;                        (lambda (data)
;;                          (pcl :dt data)
;;                          (setf (@ self state) (create data data))))
;;              (setf (@ self state)
;;                    (create data (@ props data))))
;;          (pcl :load)))

;;      (defun manifest (item)
;;        (let ((component (getprop components (@ item mt react-component))))
;;          ;; (pcl :abc item (@ item mt) (@ item mt react-component) component)
;;          (if (undefp component)
;;              (if (and (= "ar" (@ item ty))
;;                       (stringp (@ item ct)))
;;                  (let ((class-name (chain item mt classes (join " "))))
;;                    (panic:jsl (:h1 :class-name class-name (@ item ct))))
;;                  "abc")
;;              (chain -react (create-element component (create data item))))))
     
;;      (defun layout-stacked (self elements meta)
;;        (panic:jsl (:-c-container
;;                    (chain elements (map (lambda (item index)
;;                                           (let ((lspec (getprop (@ meta specs) index)))
;;                                             (panic:jsl (:div :key (+ "view-tier-" index)
;;                                                              (chain self (manifest item))
;;                                                              )))))))))
     
;;      (defun layout-columnar (self elements meta)
;;        (panic:jsl (:-c-container
;;                    (:-c-row (chain elements (map (lambda (item index)
;;                                                    (let ((lspec (getprop (@ meta specs) index))
;;                                                          (class-name (when (not (undefp (@ item mt type)))
;;                                                                        (chain item mt type (join " ")))))
;;                                                      (panic:jsl (:-c-col :md (@ lspec width)
;;                                                                          :class-name (if (undefp class-name)
;;                                                                                          "" class-name)
;;                                                                          :key (+ "view-column-" index)
;;                                                                          (chain self (manifest item))
;;                                                                          ))))))))))

;;      (defun render ()
;;        (let* ((self this)
;;               (content (and (@ this state) (@ this state data) (@ this state data ct)))
;;               (meta (and (@ this state) (@ this state data) (@ this state data mt)))
;;               (builder (getprop self (@ meta builder))))
;;          (pcl :cl self content meta)
;;          (if (undefp builder) "abc"
;;              (funcall builder self content meta)))))
;;     (setf (@ components -seed-view) -seed-view)))

#|

(defvar *portal*)

(modes (:atom modes-atom-base)
       (:form modes-form-base)
       (:meta modes-meta-common))

(media media-spec-base media-spec-chart-base media-spec-graph-garden-path)

(glyphs glyphs-base)

(test-core-systems)

(browser-interface (:markup (html-index-header "Seed: Demo Portal")
			    (html-index-body))
		   (:script (key-ui keystroke-maps key-ui-base
				    key-ui-map-apl-meta-specialized)
			    (react-ui (with (:url "portal")
					    (:component :-portal)
					    (:glyph-sets material-design-glyph-set-common))
				      (react-portal-core (component-set interface-units interface-units)
							 (component-set view-modes
									form-view-mode
									text-view-mode
									(html-view-mode :script-effects
											standard-form-effects)
									document-view-mode
									sheet-view-mode
									block-space-view-mode
									dygraph-chart-view-mode
									(graph-shape-view-mode
									 :effects standard-vector-effects)))))
		   (:style (css-styles (with (:palettes (:standard palette-hicontrast-solarized)
							(:adjunct palette-medcontrast-adjunct)
							(:backdrop palette-medcontrast-dropcloth)))
			   	       css-base css-overview css-adjunct css-column-view
				       (css-form-view (with (:palette-contexts :holder)))
				       (css-form-view-interface-elements (with (:palette-contexts :element)))
			   	       css-text-view css-ivector-standard css-font-spec-ddin
				       (css-glyph-display (with (:palette-contexts :element)))
				       css-symbol-style-camel-case)
			   css-animation-silicon-sky)
		   (:foundation (:scripts foundational-browser-script-base
					  foundational-browser-script-dygraphs)
				(:styles foundational-browser-style-base
					 foundational-browser-style-material-design-icons
					 foundational-browser-style-dygraphs)))

(portal)

(stage (simple-stage :branches
		     (simple-branch-layout :menu (stage-extension-menu-base)
					   :controls (stage-control-set :by-spec (stage-controls-base-contextual)
									:by-parameters
									(stage-controls-graph-base
									 stage-controls-document-base
									 stage-controls-chart-base)))
		     :sub-nav (simple-sub-navigation-layout :omit (:stage :clipboard :history))))

|#

(seed2 :portal.demo1
       (:bind :package package :of-portal of-portal :to-grow grow :to-contact of-contact)
       (:contacts :demo.sheet) ;; :demo-image)
       (:contacts-api . grow)
       (:branches
        :view
        (lambda (session input)
          ;; (print (list :aaa session input))
          (let ((key-input (rest (assoc :key input :test #'eq))))
            (when (and key-input (string= "demo" (string-downcase key-input)))
              (funcall session :user :hello)))

          (when (and session (assoc :point input))
            ;; when a point is selected, assign it
            (funcall session :branch-point (intern (string-upcase (rest (assoc :point input)))
                                                   "KEYWORD")))

          (when (and session (assoc "point" input :test #'string=))
            ;; when a system is selected, assign it - case of new selector controls
            (let ((epsym (intern (string-upcase (rest (assoc "point" input :test #'string=)))
                                 "KEYWORD")))
              (setf (of-portal :point) epsym)
              ;; (instantiate-priority-macro-reader (asdf:load-system epsym))
              (load-seed-system epsym)))
          ;;; (print (list :bbb session input (package-name package)))

          (authorize (funcall session :user)
            (render-web
             (uispec (:series
                      :type (:ui :grid-layout :linear :main :split :left-sidebar)
                      :layout (list :sidebar :main)
                      (:frame :type (:group :stack :form)
                              (:head (string-downcase (package-name package)))
                              (-<> (uic ((:type :form) (:app :set-endpoint))
                                        (of-portal :contacts))
                                (in-system-context <> (package-name package))
                                (render-html-interface (encode <>)))
                              "<h3 x-on:click=\" fetchContact2(context, $el, { point: 'demo.sheet' })\">demo.sheet</h3>"
                              ;; (:expr (uic ((:type :form) (:app :set-endpoint))
                              ;;             (portal-contacts portal)))
                              (render-html-interface
                               (encode (uic ((:type :form :branch-navigation)
                                             (:app :set-nav-point)
                                             (:target . :view)
                                             (:point (funcall session :branch-point)))
                                            (if (not (of-portal :point))
                                                "" (render-nav-menu (interface-interact (of-portal :point)
                                                                                        :view)))))))
                      
                      (if (not (of-portal :point))
                          nil (-<> (interface-interact (of-portal :point) :view session)
                                ;; (in-system-context <> (package-name package))
                                (render-html-interface (encode <>)))))))
            
            (-<> (uic ((:type :group :stack :main)
                       (:members :heading :main))
                      (uic ((:type :heading))
                           (string-downcase (package-name package)))
                      (let ((out (make-string-output-stream)))
                        (spinneret:interpret-html-tree
                         (htrender '(meta ((meta "Key" (:type :label))
                                           (meta "" (:name :key)
                                            (:type :field :text)))
                                     (:type :set :form))
                                   :params '(:system :portal.demo1 :branch :view))
                         :stream out)
                        (get-output-stream-string out)))
              (in-system-context <> (package-name package))
              (interface-format-form input)
              (render-html-interface (encode <>)))
            ))
        :systems
        (lambda (session input)
          (if input (let ((epsym (intern input "KEYWORD")))
                      (setf (of-portal :point)
                            (intern input "KEYWORD"))
                      ;; (instantiate-priority-macro-reader (asdf:load-system epsym))
                      (load-seed-system epsym)
                      )
              (-<> (with-meta (of-portal :contacts)
                     :type (:form))
                (encode <>))))))

