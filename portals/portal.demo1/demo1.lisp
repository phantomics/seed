;;;; portal.demo1.lisp

(in-package #:portal.demo1)

(defvar *pksym* (intern (package-name *package*) "KEYWORD"))

(defun contact-stop ())
(defun contact-restart ())

(defun contact-start ()
  (let ((pkg-name (intern (package-name *package*) "KEYWORD")))
    (multiple-value-bind (stopper restarter)
        (http-contact-service-start
         :package-name pkg-name :port 9090
         :interactor-fetch (lambda (params)
                             ;; (print (list :par params))
                             (let* ((portal-form (rest (assoc "portal" params :test #'string=)))
                                    (branch-form (rest (assoc "branch" params :test #'string=)))
                                    (input (rest (assoc "input" params :test #'string=)))
                                    (portal (when portal-form (intern portal-form "KEYWORD")))
                                    (branch (when branch-form (intern branch-form "KEYWORD"))))
                               (json-convert-to (interface-interact portal branch input))))
         :renderer-fetch (lambda (params)
                           (let* ((system-form (string-upcase (rest (assoc "system" params
                                                                           :test #'string=))))
                                  (branch-form (string-upcase (rest (assoc "branch" params
                                                                           :test #'string=))))
                                  (input (loop :for p :in params
                                               :collect (cons (symbol-munger:camel-case->keyword (first p))
                                                              (rest p))))
                                  (system (when system-form (intern system-form "KEYWORD")))
                                  (branch (when branch-form (intern branch-form "KEYWORD"))))
                             (interface-interact system branch input))))
      (setf (symbol-function 'contact-stop) stopper
            (symbol-function 'contact-restart) restarter))))

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

(defpsmacro define-component-view ()
  '(progn
    (paren6:defclass6 (-seed-view (@ -react -component))
     (defun constructor (props)
       (let ((self this))
         (if (undefp (@ props data))
             (transact "PORTAL.DEMO1" "VIEW"
                       (create interface-spec (list "browser" "react"))
                       (lambda (data)
                         (pcl :dt data)
                         (setf (@ self state) (create data data))))
             (setf (@ self state)
                   (create data (@ props data))))
         (pcl :load)))

     (defun manifest (item)
       (let ((component (getprop components (@ item mt react-component))))
         ;; (pcl :abc item (@ item mt) (@ item mt react-component) component)
         (if (undefp component)
             (if (and (= "ar" (@ item ty))
                      (stringp (@ item ct)))
                 (let ((class-name (chain item mt classes (join " "))))
                   (panic:jsl (:h1 :class-name class-name (@ item ct))))
                 "abc")
             (chain -react (create-element component (create data item))))))
     
     (defun layout-stacked (self elements meta)
       (panic:jsl (:-c-container
                   (chain elements (map (lambda (item index)
                                          (let ((lspec (getprop (@ meta specs) index)))
                                            (panic:jsl (:div :key (+ "view-tier-" index)
                                                             (chain self (manifest item))
                                                             )))))))))
     
     (defun layout-columnar (self elements meta)
       (panic:jsl (:-c-container
                   (:-c-row (chain elements (map (lambda (item index)
                                                   (let ((lspec (getprop (@ meta specs) index))
                                                         (class-name (when (not (undefp (@ item mt type)))
                                                                       (chain item mt type (join " ")))))
                                                     (panic:jsl (:-c-col :md (@ lspec width)
                                                                         :class-name (if (undefp class-name)
                                                                                         "" class-name)
                                                                         :key (+ "view-column-" index)
                                                                         (chain self (manifest item))
                                                                         ))))))))))

     (defun render ()
       (let* ((self this)
              (content (and (@ this state) (@ this state data) (@ this state data ct)))
              (meta (and (@ this state) (@ this state data) (@ this state data mt)))
              (builder (getprop self (@ meta builder))))
         (pcl :cl self content meta)
         (if (undefp builder) "abc"
             (funcall builder self content meta)))))
    (setf (@ components -seed-view) -seed-view)))

(defun build-static-page (portal-sym relative-path)
  (with-open-file (stream (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                                         (format nil "./~a/index.html" relative-path))
			  :direction :output :if-exists :supersede :if-does-not-exist :create)
    (cl-who:with-html-output (stream)
      (:html (:head (:script (paren6::ps (defvar |*__PS_MV_REG*|)
                               (setf (@ window seed-data) (create))))
                    (:link :rel "stylesheet" :href "./build/vendor.css")
                    (:link :rel "stylesheet" :href "./build/app.css"))
             (:body (:div :id "main" :class "ui" :hx-post "/render/"
                          :hx-trigger "load, reload"
                          :hx-vals (json-convert-to (list :system portal-sym
                                                          :branch :view)))
                    (:script :src "./static/misc.js")
                    (:script :src "./build/vendor.js")
                    (:script :src "./npm-interfaces/codemirror/build/iface.bundle.js")
                    )))))

;; (build-static-page :portal.demo1 "ui-browser")


;; (:script :src "./static/htmx.min.js")
;; (:link :rel "stylesheet"
;;        :href "./node_modules/fomantic-ui/dist/semantic.css")
;; (:link :rel "stylesheet" :href "./build/vendor.css")

;; (:script :src "./static/alpine.js")
;; (:script
;;  :src "./node_modules/canvas-datagrid/dist/canvas-datagrid.js")
;; (:script :src "./node_modules/d3/dist/d3.min.js")

;; (:script :src "./static/codemirror.bundle.js")
;; (:script :src "./static/cmApp.bundle.js")

(defun build-css (relative-path)
  (with-open-file (stream (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                                         (format nil "./~a/build/app.css" relative-path))
			  :direction :output :if-exists :supersede :if-does-not-exist :create)
    (format
     stream
     (lass:compile-and-write
      `(body :background "#f2f2f2")

      `(|#root|	:width "100%")

      `(.container :background "#fff")
      
      `(.sidebar
        :background "#d5d5d5"
        (.heading :font-size "160%" :font-weight "bold"
                  :padding 8px :margin-bottom 6px)
        (.form :font-size "120%" :font-weight "bold"
               :padding 3px 12px))
      
      `(.ui.grid
        :height "100%"
        (.group :height "100%"))

      `(.ui.grid-layout
        :display "grid" :height "100%"
        (.container :position "relative" :height "100%" :display "grid")
        (.container.column-inner
         :padding 0
         ;; :grid-template-rows "[header-start] 10.7% [header-end] 78.6% [footer-start] 10.7% [footer-end]"
         ;; :grid-template-rows "repeat(3, auto)"
         :grid-template-rows "[header-start] auto [header-end] 1fr [footer-start] auto [footer-end]"
         :grid-template-columns "100%"
         
         (.header :grid-row-start "header-start"
                  :grid-row-end "header-end")
         (.sub-container :grid-row-start "header-end"
                         :grid-row-end   "footer-start")
         ;; ((:and .container.column (:nth-child 1))
         ;;  :grid-row-start "header-start")
         ;; ((:and .container.column (:nth-child 2))
         ;;  :grid-row-start "header-end")
         ;; ((:and .container.column (:nth-child 3))
         ;;  :grid-row-start "footer-start")
         ))

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
        :grid-column-start 1
        :grid-column-end 7)
      
      `((:and (.ui.grid-layout.workspace.even > .column)
              (:nth-child 2))
        :grid-column-start 7
        :grid-column-end 13)

      `(.ui.grid-layout.workspace
        (.column :padding 0 10px))
      
      `((:or .ui.header .ui.footer)
        :width "100%"
        :padding 8px
        :margin 0
        :background "#eee"
        :display grid
        :grid-template-columns "20% 80%"
        :grid-template-rows "100%")

      `(.ui.header
        :border-bottom "2px solid #ccc"
        (h2.branch-name :margin 0 :grid-column-start 1)
        (.controls-holder :text-align right :grid-column-end 3))
      
      `(.ui.footer :bottom 0
                   :border-top "2px solid #ccc")

      ;; `(.container
      ;;   (.sub-container :height 100%
      ;;                   :width 100%))
      
      ;; d3 graph view styles
      
      `((:or .d3view-graph-foldout .svg-visualizer)
        :height 100% :width 100%
        (.link :fill none :stroke "#bbb" :stroke-width 1.5)
        (.expand-control
         :cursor "pointer"
         (.button-backing :fill "#fff")
         (.button-circle  :fill "#bbb")
         (rect :fill "#fff"))
        (.circle-glyph
         (.outer-circle :fill "#ccc")
         (.inner-circle :fill "#fff")))
      
      ))))

;; (build-css "ui-browser")

(defun build-script-cmirror ()
  (build-script-element
   :path (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                        "./ui-browser/npm-interfaces/codemirror/cm-app.js")
   :imports '(((basic-setup -editor-view) "codemirror")
              ((-editor-state -compartment -facet) "@codemirror/state")
              ((indent-service) "@codemirror/language")
              ;; (python "@codemirror/lang-python")
              )
   :constructors
   (list (lambda (stream)
           (format
            stream (paren6::ps
                     (defvar |*__PS_MV_REG*|)
                     (setf (@ global create-codemirror)
                           (lambda (target data)
;; const indentPlainTextExtension = indentService.of((context, pos) => {
;;   const previousLine = context.lineAt(pos, -1)
;;   return previousLine.text.match(/^(\s)*/)[0].length
;; })
                             (defvar lisp-indent-extension
                               (chain indent-service
                                      (of (lambda (context pos)
                                            (chain console (log (chain context (line-at pos -1))))))))
                             
                             (let* (;; (language (new -compartment))
                                    (tab-size (new -compartment))
                                    (state
                                      (chain -editor-state
                                             (create (create doc data
                                                             extensions
                                                             (list basic-setup
                                                                   lisp-indent-extension
                                                                   (chain tab-size
                                                                          (of (chain -editor-state
                                                                                     tab-size (of 8)))))
                                                             ))))
                                    ;; (state (chain codemirror (create-editor-state data)))
                                    (view (new (-editor-view (create state state
                                                                     parent target
                                                                     doc data
                                                                     )))))
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
       (setf (@ window seed-data) (create))
       (defun fetch-contact (system branch input handler)
         (chain (fetch "/contact/"
                       (create method "POST"
                               body (chain -j-s-o-n (stringify (create portal system
                                                                       branch branch
                                                                       input input)))
                               headers (create "Content-type" "application/json; charset=UTF-8")))
                (then (lambda (response) (chain response (json))))
                (then handler)))
       ;; (defvar d3-effects
       ;;   (create text-label
       ;;           (lambda (in-node params)
       ;;             (chain in-node (append "text")
       ;;                    (attr "dy" "0.31em")
       ;;                    (attr "x" 58)
       ;;                    (attr "text-anchor" "start")
       ;;                    (text (lambda (d)
       ;;                            (chain console (log :td d))
       ;;                            (@ d data title)))
       ;;                    (clone true) (lower)
       ;;                    (attr "stroke-linejoin" "round")
       ;;                    (attr "stroke-width" 3)
       ;;                    (attr "stroke" "white")
       ;;                    (attr "fill" (lambda (d)))))
       ;;           expand-control
       ;;           (lambda (in-node params)
       ;;             (let ((main-radius 48)
       ;;                   (inner-radius 6)
       ;;                   (outer-radius 8)
       ;;                   (crossbar-length 8)
       ;;                   (crossbar-breadth 2)
       ;;                   (group (chain in-node (append "svg:g")
       ;;  		               ;; TODO: complete class function
       ;;  		               ;;(attr "class" (lambda (d) "object-data-fetch glyph"))
       ;;  		               (attr "class" "expand-control"))))
       ;;               (chain group (append "svg:circle")
       ;;  	            (attr "class" "button-backing")
       ;;  	            (attr "cy" 0)
       ;;  	            (attr "cx" main-radius)
       ;;  	            (attr "r" outer-radius))

       ;;               (chain group (append "svg:circle")
       ;;  	            (attr "class" "button-circle")
       ;;  	            (attr "cy" 0)
       ;;  	            (attr "cx" main-radius)
       ;;  	            (attr "r" inner-radius))

       ;;               (chain group (append "svg:rect")
       ;;  	            (attr "x" (- main-radius (/ crossbar-length 2)))
       ;;  	            (attr "y" (/ crossbar-breadth -2))
       ;;  	            (attr "height" crossbar-breadth)
       ;;  	            (attr "width" crossbar-length))))
       ;;           circle-icon
       ;;           (lambda (in-node params)
       ;;             (let ((main-radius 16)
       ;;                   (icon-group (chain in-node
       ;;  		                    (append "svg:g")
       ;;  		                    ;; TODO: complete class function
       ;;  		                    ;;(attr "class" (lambda (d) "object-data-fetch glyph"))
       ;;  		                    (attr "class" "circle-glyph"))))
       ;;               ;; (chain node-icon (append "svg:path")
       ;;  	     ;;        ;; TODO: complete class function
       ;;  	     ;;        (attr "class" "outer-meta-spokes")
       ;;  	     ;;        (attr "d" (lambda (d) (manifest-outer-spoke-points 3)))
       ;;  	     ;;        (attr "transform" (+ "translate(" main-radius ",0)")))

       ;;               ;; (chain node-icon (append "svg:path")
       ;;  	     ;;        ;; TODO: complete class function
       ;;  	     ;;        (attr "class" "outer-meta-band")
       ;;  	     ;;        (attr "d" (lambda (d) (manifest-outer-band 0.6)))
       ;;  	     ;;        (attr "transform" (+ "translate(" main-radius ",0)")))

       ;;               ;; outer chromatic circle
       ;;               (chain icon-group (append "svg:circle")
       ;;  	            (attr "class" "outer-circle")
       ;;  	            (attr "cy" 0)
       ;;  	            (attr "cx" main-radius)
       ;;  	            (attr "r" main-radius))

       ;;               ;; inner white circle with radius according to a metadata fraction
       ;;               (chain icon-group (append "svg:circle")
       ;;  	            (attr "class" "inner-circle")
       ;;  	            (attr "cy" 0)
       ;;  	            (attr "cx" main-radius)
       ;;  	            ;; (attr "r" (manifest-inner-circle-radius 0.5))
       ;;                      (attr "r" (- main-radius 4))
       ;;                      )

       ;;               ;; .call(d3.drag()
       ;;               ;; 		    .on("start", dragstarted)
       ;;               ;; 		    .on("drag", dragged)
       ;;               ;; 		    .on("end", dragended))
       ;;               ))))
       ;; (defun d3-build (fetcher)
       ;;   (lambda (data)
       ;;     (chain console (log :dat data))
       ;;     (let* ((width 600) (height 600)
       ;;            (svg (chain d3 (create "svg") (attr "class" "d3view-graph-foldout")
       ;;                        (attr "width" width) (attr "height" height)))
       ;;            (bar-height 36)
       ;;            (margin-top 10)
       ;;            (margin-right 10)
       ;;            (margin-left 10)
       ;;            (margin-bottom 10)
       ;;            (dx 10)
       ;;            (dy 10) ;; more of a calculation
       ;;            (root (chain d3 (hierarchy data)))
       ;;            (layout-tree (chain d3 (tree) (node-size (list 20 20))))
       ;;            (diagonal (chain d3 (link-horizontal)
       ;;                             (x (lambda (d) (@ d y)))
       ;;                             (y (lambda (d) (@ d x)))))
       ;;            (diag (chain d3 (link-horizontal)
       ;;                         (x (lambda (d) (@ d y)))
       ;;                         (y (lambda (d) (@ d x)))))
       ;;            (glink (chain svg (append "g")
       ;;                          (attr "fill" "none")
       ;;                          (attr "stroke" "#555")
       ;;                          (attr "stroke-opacity" 0.4)
       ;;                          (attr "stroke-width" 1.5)))
       ;;            (gnode (chain svg (append "g")
       ;;                          (attr "cursor" "pointer")
       ;;                          (attr "pointer-events" "all"))))

       ;;       (defun update (event source)
       ;;         (let* ((duration 500)
       ;;                (nodes (chain root (descendants) (reverse)))
       ;;                (links (chain root (links)))
       ;;                (ix 0) (left) (right)
       ;;                (transition) (node) (node-enter)
       ;;                (node-update) (node-exit) (link) (link-enter))
       ;;           (chain console (log :rt root))
       ;;           (layout-tree root)
       ;;           (setf left root right root
       ;;                 ;; height ;; (+ (- (@ right x) (@ left x))
       ;;                 ;;    margin-top margin-bottom)
       ;;                 ;; 600
       ;;                 )

       ;;           (defun dftraverse (list)
       ;;             (chain list (for-each (lambda (d i)
       ;;                                     (unless (= "null" (typeof (@ d index)))
       ;;                                       (setf (@ d index) ix)
       ;;                                       (incf ix))
       ;;                                     (if (@ d children)
       ;;                                         (dftraverse (@ d children)))))))
       ;;           (dftraverse nodes)

       ;;           (chain console (log :rd (chain root (descendants))))
                 
       ;;           (chain root (descendants)
       ;;                  (for-each (lambda (n i)
       ;;                              (setf (@ n x) (* bar-height (1- (@ n index)))))))
                 
       ;;           (setf transition
       ;;                 (chain svg (transition) (duration duration)
       ;;                        (attr "height" height)
       ;;                        (attr "viewBox" (list (+ margin-left)
       ;;                                              (- (@ left x) margin-top)
       ;;                                              width height))
       ;;                        (tween "resize" (if (@ window -resize-observer)
       ;;                                            null (lambda ()
       ;;                                                   (lambda ()
       ;;                                                     (chain svg (dispatch "toggle")))))))
       ;;                 node (chain gnode (select-all "g.node")
       ;;                             (data nodes (lambda (d) (@ d id))))
       ;;                 node-enter
       ;;                 (chain node (enter) (append "g") (attr "class" "node")
       ;;                        (attr "transform" (lambda (d)
       ;;                                            (+ "translate(" (@ source y0)
       ;;                                               "," (@ source x0) ")")))
       ;;                        (attr "fill-opacity" 0)
       ;;                        (attr "stroke-opacity" 0)
       ;;                        (attr "display" (lambda (d)
       ;;                                          (if (= 0 (@ d id))
       ;;                                              "none" "relative")))
       ;;                        (on "click" (lambda (this-event d)
       ;;                                      (chain console (log :ind (@ d data) (@ d data to)))
       ;;                                      (if (and (or (@ d data to)
       ;;                                                   (= 0 (@ d data to)))
       ;;                                               (not (or (@ d children)
       ;;                                                        (@ d _children))))
       ;;                                          (funcall fetcher
       ;;                                                   (lambda (data)
       ;;                                                     ;; build the item to insert
       ;;                                                     (let* ((ins (chain d3 (hierarchy data)))
       ;;                                                            (all (chain root (descendants)))
       ;;                                                            (ccount (@ all length)))
       ;;                                                       (if (= 0 (@ d height))
       ;;                                                           (chain all (for-each
       ;;                                                                       (lambda (item)
       ;;                                                                         (setf (@ item height)
       ;;                                                                               (+ 2 (@ item
       ;;                                                                                       height)))))))
       ;;                                                       (chain console (log "dt" data))
       ;;                                                       (setf (@ ins parent) d
       ;;                                                             (@ ins depth) (1+ (@ d depth))
       ;;                                                             (@ ins id) ccount
       ;;                                                             (getprop (@ ins children) 0 "depth")
       ;;                                                             (+ 2 (@ d depth))
       ;;                                                             (getprop (@ ins children) 0 "id")
       ;;                                                             (+ 2 ccount)
       ;;                                                             (getprop (@ ins children) 0 "children")
       ;;                                                             null
       ;;                                                             (@ ins _children)
       ;;                                                             (@ ins children)
       ;;                                                             (@ ins children) null
       ;;                                                             (@ d children)
       ;;                                                             (list ins)
       ;;                                                             (@ d _children) null)
                                                             
       ;;                                                       (layout-tree root)
       ;;                                                       (chain console
       ;;                                                              (log :retd (typeof data)
       ;;                                                                   d ;; nodes root
       ;;                                                                   ins
       ;;                                                                   data))
       ;;                                                       (update this-event root)))
       ;;                                                   (create index (@ d data to)))
       ;;                                          (progn (chain console (log :cl d))
       ;;                                                 (setf (@ d children)
       ;;                                                       (if (@ d children)
       ;;                                                           null (@ d _children)))
       ;;                                                 (update this-event d)))
       ;;                                      ))))

       ;;           ;; (chain node-enter (append "circle")
       ;;           ;;        (attr "r" 2.5)
       ;;           ;;        (attr "fill" (lambda (d)
       ;;           ;;                       (if (@ d _children) "#555" "#999")))
       ;;           ;;        (attr "stroke-width" 10))

       ;;           (chain -object (keys (@ window d3-effects))
       ;;                  (for-each (lambda (e i)
       ;;                              (funcall (getprop (@ window d3-effects) e)
       ;;                                       node-enter (create)))))

       ;;           ;; (chain console (log "BB"))
       ;;           (setf node-update
       ;;                 (chain node (merge node-enter) (transition transition)
       ;;                        (attr "transform" (lambda (d)
       ;;                                            (+ "translate(" (@ d y) "," (@ d x) ")")))
       ;;                        (attr "fill-opacity" 1)
       ;;                        (attr "stroke-opacity" 1))

       ;;                 node-exit
       ;;                 (chain node (exit) (transition transition) (remove)
       ;;                        (attr "transform" (lambda (d)
       ;;                                            (chain console (log :aa d (@ d y) (@ d x)))
       ;;                                            (+ "translate(" (@ d y) "," (@ d x) ")")))
       ;;                        (attr "fill-opacity" 0)
       ;;                        (attr "stroke-opacity" 0))
       ;;                 link (chain glink (select-all "path")
       ;;                             (data links (lambda (d) (@ d target id))))
       ;;                 link-enter (let ((o (create x (@ source x0)
       ;;                                             y (@ source y0))))
       ;;                              (chain link (enter) (append "path")
       ;;                                     (attr "d" (diagonal (create source o target o)))
       ;;                                     (attr "class" (+ "c" (@ source id)))
       ;;                                     (attr "display" (lambda (d)
       ;;                                                       (chain console (log :dd d))
       ;;                                                       (if (= 1 (@ d target depth))
       ;;                                                           "none" "relative"))))))
                 
       ;;           (chain link (merge link-enter) (transition transition)
       ;;                  (attr "d" diagonal))

       ;;           (chain link (exit) (transition transition) (remove)
       ;;                  (attr "d" (lambda (d)
       ;;                              (let ((o (create x (@ source x)
       ;;                                               y (@ source y))))
       ;;                                (diagonal (create source o target o))))))
                 
       ;;           (chain root (each-before (lambda (d)
       ;;                                      (setf (@ d x0) (@ d x)
       ;;                                            (@ d y0) (@ d y)))))))
             
       ;;       (setf (@ root x0) (/ dy 2)
       ;;             (@ root y0) 0)

       ;;       (chain root (descendants)
       ;;              (for-each (lambda (d i)
       ;;                          (setf (@ d id) i
       ;;                                (@ d _children) (@ d children))
       ;;                          (if (and (@ d depth)
       ;;                                   (/= 7 (@ d data title length)))
       ;;                              (setf (@ d children) null)))))

       ;;       (update null root)
             
       ;;       (chain document (get-element-by-id "d3-container")
       ;;              (append (chain svg (node)))))))
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
  (cons
   'progn
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
  (:paths "./ui-browser/static/htmx.min.js" "./ui-browser/node_modules/d3/dist/d3.min.js" 
          "./ui-browser/node_modules/canvas-datagrid/dist/canvas-datagrid.js"
          ;; "./ui-browser/static/codemirror.bundle.js"
          ;; "./ui-browser/static/cmApp.bundle.js"
          "./ui-browser/static/alpine.js"
          ;; "./ui-browser/node_modules/fomantic-ui/dist/semantic.js"
          )
  (:output-to . "./ui-browser/build/vendor.js"))
 (:concat-static
  (:paths "./ui-browser/node_modules/fomantic-ui/dist/semantic.css")
  (:output-to . "./ui-browser/build/vendor.css"))
 )


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
