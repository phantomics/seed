;;;; maple.lisp

(in-package #:pla.browser.maple)

(defmacro implement-start-controls (to-grow to-start to-restart to-stop)
  (let ((pkg-name (gensym)) (key (gensym)) (params (gensym)) (session-api (gensym))
        (input (gensym)) (port (gensym)) (value (gensym)) (stopper (gensym))
        (restarter (gensym)) (system-name (gensym)) (branch-name (gensym)) (p (gensym)))
    `(let ((,pkg-name (intern (package-name (symbol-package ',to-start)) "KEYWORD")))
       (proclaim '(special ,to-start ,to-restart ,to-stop))
       (flet ((get-name (,key ,params)
                (let ((,value (rest (assoc ,key ,params :test #'string=))))
                  (and ,value (intern (string-upcase ,value) "KEYWORD")))))
         (setf (symbol-function ',to-start)
               (lambda (&optional (,port 9090))
                 (multiple-value-bind (,stopper ,restarter)
                     (http-contact-service-start
                      :package-name ,pkg-name :port ,port
                      :interactor-fetch (lambda (,params ,session-api)
                                          (let ((,system-name (get-name "system" ,params))
                                                (,branch-name (get-name "branch" ,params))
                                                (,input (rest (assoc "input" ,params :test #'string=))))
                                            ;; (print (list :aa ,params
                                            ;;              (loop :for ,p :in ,input
                                            ;;                    :collect (cons (camel-case->keyword (first ,p))
                                            ;;                                   (rest ,p)))))
                                            ;; (print (list :aa system-form branch-form))
                                            (json-convert-to
                                             (,to-grow ,system-name ,branch-name ,session-api
                                                       ;; (loop :for ,p :in ,input
                                                       ;;       :collect (cons (camel-case->keyword (first ,p))
                                                             ;;               (rest ,p)))
                                                       ,input))))
                      :renderer-fetch (lambda (,params ,session-api)
                                        ;; (print (list :par params session-api))
                                        (let ((,system-name (get-name "system" ,params))
                                              (,branch-name (get-name "branch" ,params)))
                                          (,to-grow ,system-name ,branch-name ,session-api
                                                    (loop :for ,p :in ,params
                                                          :collect (cons (camel-case->keyword (first ,p))
                                                                         (rest ,p)))))))
                   (setf (symbol-function ',to-stop)    ,stopper
                         (symbol-function ',to-restart) ,restarter))))))))

(defmacro write-to-file (stream package path &body clauses)
  `(with-open-file (,stream (asdf:system-relative-pathname (intern (package-name ,package) "KEYWORD")
                                                           ,path)
			    :direction :output :if-exists :supersede :if-does-not-exist :create)
     ,@clauses))

(defun build-static-page (stream portal-sym)
  (let ((spinneret:*html* stream))
    (spinneret:with-html
      (:html (:head (:script (paren6::ps (defvar |*__PS_MV_REG*|)
                               (setf (@ window seed-data) (create))))
                    (:link :rel "stylesheet" :href "./build/ext.css")
                    (:link :rel "stylesheet" :href "./build/int.css"))
             (:body (:div :id "main" :class "ui" :hx-post "/render/"
                          :hx-trigger "load, submit, refresh, navigate"
                          :hx-vals (format nil "js:{...ejoin(~a,event)}"
                                           (seed.generate::psl (create system (lisp (string portal-sym))
                                                                       branch :view
                                                                       of-local (lambda (a b c)))))
                          ;; :hx-vals (format nil "js:~a" (ps* `(create :system ,portal-sym :branch :view
                          ;;                                            :data (@ event details))))
                          :x-data (ps (create context (create system (lisp (string portal-sym))
                                                              branch "VIEW"))))
                    (:script :src "./build/ext.js")
                    (:script :src "./build/int.js"))))))

(defun build-styles (stream)
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
    
    ;; `(.container :background "#fff")
    
    `(.sidebar
      :background "#d5d5d5"
      (.heading :font-size "160%" :font-weight "bold"
                :padding 8px :margin-bottom 6px)
      (.form :font-size "120%" :font-weight "bold" :padding 3px 12px))

    `(.portal-summary
      (.symbol :font-weight "bold")
      (.navigation
       :margin "1rem 0"
       (.symbol :font-weight "normal")
       (.divider :margin "0.5rem 0")))
    
    `(.ui.grid :height "100%" (.group :height "100%"))

    `(.ui.grid-layout
      :display "grid" :height "100%"
      (.column
       :display grid :overflow auto :grid-template-rows 1fr
       (.container :position "relative" :height "100%") ;;  :display grid)
       (.column-inner
        :padding 0 :overflow auto
        (.access.body :height "100%" :background "#fff")
        ;; :grid-template-columns "100%"
        ;; :grid-template-rows "[header-start] auto [header-end] 1fr [footer-start] auto [footer-end]"
        
        ;; (.header :grid-row-start "header-start" :grid-row-end "header-end")
        ;; (.container-wrap
        ;; :grid-row-start "header-end"
        ;; :grid-row-end   "footer-start"
        ;; (.sub-container :grid-row-start "header-end" :grid-row-end   "footer-start"
        ;;                 :overflow-y auto)
        ;; (.footer :grid-row-start "footer-start" :grid-row-end "footer-end")
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
      :width "100%" :height "100%" :padding 8px :margin 0 :background "#eee"
      :display grid :grid-template-columns "20% 80%" :grid-template-rows 100%)

    `(.ui.header
      :border-bottom "2px solid #ccc"
      (h2.branch-name :margin 0 :grid-column-start 1))
    
    `(.ui.footer :bottom 0 :border-top "2px solid #ccc")

    `((:or .ui.header .ui.footer)
      (.controls :text-align right :grid-column-end 3
                 (.item :display inline)))

    `(.form.text (.cm-editor :height 100%))

    `(form (.input.fluid :margin-bottom 0.32em)
           (.ui.selection.dropdown :min-height 3em :margin-bottom 0.32em))
    
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
    
    )))

(defun concat-files2 (out-path &rest in-paths)
  (with-open-file (output out-path :direction :output :if-exists :supersede :if-does-not-exist :create)
    (loop :for path :in in-paths
          :do (with-open-file (input path :direction :input)
                (loop :for char := (read-char input nil :eof) :until (eq char :eof)
                      :do (write-char char output))
                (princ #\Newline output)))
    :complete))

(defun concat-files (out-stream package &rest in-paths)
  (loop :for path :in in-paths
        :do (with-open-file (input (asdf:system-relative-pathname
                                    (intern (string (package-name package)) "KEYWORD")
                                    path)
                                   :direction :input)
              (loop :for char := (read-char input nil :eof) :until (eq :eof char)
                    :do (write-char char out-stream))
              (princ #\Newline out-stream)))
    :complete)

(defmacro provide-browser-script (package-sym &rest tasks)
  (cons 'progn (loop :for task :in tasks
                     :collect (destructuring-bind (task-id &rest params) task
                                (case task-id
                                  (:run-process
                                   `(uiop:run-program (format nil ,@params)))
                                  (:concat-static
                                   `(concat-files2 ,(asdf:system-relative-pathname
                                                    (intern (string package-sym) "KEYWORD")
                                                    (rest (assoc :output-to params)))
                                                  ,@(mapcar (lambda (p)
                                                              (asdf:system-relative-pathname
                                                               (intern (string package-sym) "KEYWORD") p))
                                                            (rest (assoc :paths params))))))))))

(defun build-script-element (&key stream imports constructors)
  (loop :for import :in imports
        :do (if (listp import)
                (progn (format stream "import ~a" (if (listp (first import)) "{ " ""))
                       (if (listp (first import))
                           (let ((icount (1- (length (first import)))))
                             (loop :for item :in (first import) :for i :from 0
                                   :do (format stream "~a~a " (lisp->camel-case item)
                                               (if (> icount i) "," ""))))
                           (format stream "~a" (lisp->camel-case (first import))))
                       (format stream "~a from '~a'~%" (if (listp (first import)) "}" "")
                               (second import)))
                (format stream "import '~a'~%" import)))
  (format stream "~%")
  (loop :for c :in constructors :do (funcall c stream)))

(defun build-script-cmirror (stream)
  (build-script-element
   :stream stream
   :imports `(((minimal-setup -editor-view) "codemirror")
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
                               view)))))))))

(defpsmacro pcl (&rest items)
  `(chain console (log ,@items)))

(defpsmacro undefp (item)
  `(= "undefined" (typeof ,item)))

(defun build-script-misc (stream)
  (format
   stream
   (paren6::ps
     (setf (@ window seed-data) (create)
           (@ window seed-elements) (create))
     (defun fetch-contact (system branch input handler)
       (chain (fetch "/contact/"
                     (create method "POST"
                             body (chain -j-s-o-n (stringify (create system system
                                                                     branch branch
                                                                     input  input)))
                             headers (create "Content-type" "application/json; charset=UTF-8")))
              (then (lambda (response) (chain response (json))))
              (then (lambda (data)
                      ;; (chain console (log :dt data (@ data oob-reload)))
                      (if (@ data oob-reload)
                          (chain data oob-reload (for-each (lambda (item)
                                                             (chain console (log :it item))
                                                             (chain htmx (trigger (getprop seed-elements
                                                                                           item)
                                                                                  "reload"))))))
                      data))
              (then handler)))
     
     (defun fetch-contact2 (context element input)
       ;; (chain console (log :cc context))
       (chain (fetch "/contact/"
                     (create method "POST"
                             headers (create "Content-type" "application/json; charset=UTF-8")
                             body (chain -j-s-o-n (stringify (create system (@ context system)
                                                                     branch (@ context branch)
                                                                     input  input)))))
              (then (lambda (response) (chain response (json))))
              (then (lambda (data) (chain htmx (trigger element "refresh"))))))
     
     (defun realize (system branch element)
       (lambda (input)
         (chain (fetch "/contact/"
                       (create method "POST"
                               headers (create "Content-type" "application/json; charset=UTF-8")
                               body (chain -j-s-o-n (stringify (create system system
                                                                       branch branch
                                                                       input input)))))
                (then (lambda (response) (chain response (json))))
                (then (lambda (data) (chain htmx (trigger element "refresh")))))))

     (defun manifest-locality ()
       (let ((types (create)))
         (lambda (action option body)
           (case action
             ("register" (when (= "undefined" (typeof (getprop types option)))
                           (setf (getprop types option) (list)))
              (setf (getprop types option)
                    (chain (getprop types option) (concat body))))
             ("list" (when (!= "undefined" (typeof (getprop types option)))
                       (getprop types option)))
             ("trigger" (loop :for item :in (getprop types option)
                              :do (chain htmx (trigger item body))))))))

     (defun push-form (item form-list)
       (chain form-list (push item)))
     
     (defun submit-forms (form-list)
       (chain form-list (for-each (lambda (form) (chain htmx (trigger form "submit"))))))

     (defun ejoin (base event)
       (unless (or (undefp event) (undefp (@ event detail)))
         (chain console (log :ee (@ event detail)))
         (loop :for k :in (chain -object (keys (@ event detail)))
               :do (unless (or (= k "elt" ) (undefp (getprop (@ event detail) k)))
                     (setf (getprop base k)
                           (getprop (@ event detail) k)))))
       base)

     (let* ((derive-points (lambda (ent chart)
			     (list (if (or (not (@ ent layer-points))
					   (not (@ ent layer-points 0))
					   (= "undefined" (typeof (@ ent layer-points 0))))
				       (chain chart (to-dom-coords (@ ent points 0 0) (@ ent points 0 1)))
				       (@ ent layer-points 0))
				   (if (or (not (@ ent layer-points))
					   (not (@ ent layer-points 1))
					   (= "undefined" (typeof (@ ent layer-points 1))))
				       (chain chart (to-dom-coords (@ ent points 1 0) (@ ent points 1 1)))
				       (@ ent layer-points 1)))))
	    (draw-line (lambda (ctx ent chart points)
		         (if (@ ent in-flux)
			     (setf (@ ctx line-width) 2))
		         (chain ctx (begin-path))
		         (let ((points (if points points (derive-points ent chart)))
			       (circle-radius 5))
			   (chain ctx (move-to (@ points 0 0) (@ points 0 1)))
			   (chain ctx (line-to (@ points 1 0) (@ points 1 1)))
			   (chain ctx (close-path))
			   (chain ctx (stroke))
			   (if (@ ent in-flux)
			       (let* ((diffs (list (list (- (@ points 0 0) (@ points 1 0))
						         (- (@ points 0 1) (@ points 1 1)))
						   (list (- (@ points 1 0) (@ points 0 0))
						         (- (@ points 1 1) (@ points 0 1)))))
				      ;; numbers corresponding to radian intersections
                                      ;; of line with arcs encircling
				      ;; start (0) and end (1) points
				      (ri (list (* (chain -math (sign (@ diffs 0 1)))
						   (acos (/ (@ diffs 0 0) (sqrt (+ (expt (@ diffs 0 0) 2)
										   (expt (@ diffs 0 1) 2))))))
					        (* (chain -math (sign (@ diffs 1 1)))
						   (acos (/ (@ diffs 1 0) (sqrt (+ (expt (@ diffs 1 0) 2)
										   (expt (@ diffs 1 1)
                                                                                         2)))))))))
			         (setf (@ ctx stroke-style) "black"
				       (@ ctx fill-style) "black"
				       (@ ctx line-width) 0.5)
			         (chain ctx (begin-path))
			         (chain ctx (arc (@ points 0 0) (@ points 0 1) 1 0 (* pi 2) true))
			         (chain ctx (fill))
			         (chain ctx (begin-path))
			         (chain ctx (arc (@ points 1 0) (@ points 1 1) 1 0 (* pi 2) true))
			         (chain ctx (fill))
			         (chain ctx (begin-path))

			         ;; (chain ctx (arc (@ points 0 0) (@ points 0 1) 5 0 (* pi 2) true))
			         ;; (chain ctx (stroke))
			         ;; (chain ctx (begin-path))
			         ;; (chain ctx (arc (@ points 1 0) (@ points 1 1) 5 0 (* pi 2) true))

			         (chain ctx (arc (@ points 0 0) (@ points 0 1) circle-radius
					         (+ (- pi) (- (@ ri 0) (* pi 0.20)))
					         (+ (- pi) (+ (@ ri 0) (* pi 0.20)))
					         true))
			         (chain ctx (stroke))
			         (chain ctx (begin-path))
			         (chain ctx (arc (@ points 1 0) (@ points 1 1) circle-radius
					         (+ (- pi) (- (@ ri 1) (* pi 0.20)))
					         (+ (- pi) (+ (@ ri 1) (* pi 0.20)))
					         true))
			         (chain ctx (stroke)))))

		         (setf (@ ctx stroke-style) "black"
			       (@ ctx line-width) 1)))
	    (intersect-line (lambda (ent chart point callback)
			      (let ((line-points (list (chain chart (to-dom-coords (@ ent points 0 0)
										   (@ ent points 0 1)))
						       (chain chart (to-dom-coords (@ ent points 1 0)
										   (@ ent points 1 1)))))
				    (margin 8))
			        (if (not (or (and (> (@ point 0) (+ (@ line-points 0 0) margin))
						  (> (@ point 0) (+ (@ line-points 1 0) margin)))
					     (and (< (@ point 0) (- (@ line-points 0 0) margin))
						  (< (@ point 0) (- (@ line-points 1 0) margin)))
					     (and (> (@ point 1) (+ (@ line-points 0 1) margin))
						  (> (@ point 1) (+ (@ line-points 1 1) margin)))
					     (and (< (@ point 1) (- (@ line-points 0 1) margin))
						  (< (@ point 1) (- (@ line-points 1 1) margin)))))
				    (let* ((ratio (/ (- (@ line-points 0 1) (@ line-points 1 1))
						     (- (@ line-points 1 0) (@ line-points 0 0))))
					   (x-pos (- (@ point 0) (@ line-points 0 0)))
					   (cross-y (abs (- (* x-pos ratio) (@ line-points 0 1)))))
				      (if (> 8 (abs (- cross-y (@ point 1))))
					  (funcall callback ent))))))))
          (defvar draw-methods
            (create line (create draw draw-line
			         intersect intersect-line)
	            retrace-x (create draw (lambda (ctx ent chart)
				             (let ((points (derive-points ent chart)))
					       (funcall draw-line ctx ent chart points)
					       (setf (@ ctx stroke-style) "blue"
					             (@ ctx line-width) 1)
					       (let ((x-origin (if (< (@ points 0 0) (@ points 1 0))
							           (@ points 0 0) (@ points 1 0)))
					             (x-interval (- (@ points 0 0) (@ points 1 0))))
					         (loop for ratio in (@ ent ratios 0)
					               do (let ((x-level (if (< (@ points 0 0) (@ points 1 0))
								             (- x-origin (* ratio x-interval))
								             (+ x-origin (* ratio x-interval)))))
						            (chain ctx (begin-path))
						            (chain ctx (move-to x-level 0))
						            (chain ctx (line-to x-level (@ ctx canvas height)))
						            (chain ctx (close-path))
						            (chain ctx (stroke)))))
					       (setf (@ ctx stroke-style) "black"
					             (@ ctx line-width) 1.5)))
			              intersect intersect-line)
	            retrace-y (create draw (lambda (ctx ent chart)
				             (let ((points (derive-points ent chart)))
					       (funcall draw-line ctx ent chart points)
					       (setf (@ ctx stroke-style) "red"
					             (@ ctx line-width) 1)
					       (let ((x-origin (if (< (@ points 0 0) (@ points 1 0))
							           (@ points 0 0) (@ points 1 0)))
					             (y-origin (if (< (@ points 0 1) (@ points 1 1))
							           (@ points 0 1) (@ points 1 1)))
					             (y-interval (- (@ points 0 1) (@ points 1 1))))
					         (loop for ratio in (@ ent ratios 1)
					               do (let ((y-level (if (< (@ points 0 1) (@ points 1 1))
								             (- y-origin (* ratio y-interval))
								             (+ y-origin (* ratio y-interval)))))
						            (chain ctx (begin-path))
						            (chain ctx (move-to x-origin y-level))
						            (chain ctx (line-to (@ ctx canvas width) y-level))
						            (chain ctx (close-path))
						            (chain ctx (stroke)))))
					       (setf (@ ctx stroke-style) "black"
					             (@ ctx line-width) 1.5)))
			              intersect intersect-line))))
     
     (defun interactor-mousewheel (mode)
       (lambda (event chart context)
         (if (@ event shift-key)
	     (let* ((price-range (chain chart (y-axis-range)))
		    (price-interval (- (@ price-range 0) (@ price-range 1)))
		    (zoom-interval (* 0.05 price-interval))
		    (wheel-delta (if (< 0 (@ event delta-y)) 1 -1)))
	       (chain chart (update-options (create date-window (chain chart (x-axis-range))
						    value-range (list (if (= 1 wheel-delta)
								          (- (@ price-range 0) zoom-interval)
								          (+ (@ price-range 0) zoom-interval))
								      (@ price-range 1))))))
	     (let* ((time-range (chain chart (x-axis-range)))
		    (time-interval (- (@ time-range 1) (@ time-range 0)))
		    (zoom-interval (* 0.05 time-interval))
		    (wheel-delta (if (< 0 (@ event delta-y)) 1 -1)))
	       (chain chart (update-options (create date-window (list (if (= 1 wheel-delta)
								          (- (@ time-range 0) zoom-interval)
								          (+ (@ time-range 0) zoom-interval))
								      (@ time-range 1))
						    value-range (chain chart (y-axis-range)))))))))

     (defun interactor-mousedown (mode)
       (lambda (event g context)
         (chain console (log "aaa"))
         (setf (@ mode mousedown) t)
         (let ((canvas-coords (list (@ event layer-x) (@ event layer-y)))
	       (dom-coords (chain g (event-to-dom-coords event)))
	       (entities-count (@ mode entities length)))
	   (if (= "select" (@ mode interaction))
	       (let ((entity-clicked false))
	         (loop for entix from 0 to (1- entities-count)
		       do (chain self draw-methods line
			         (intersect
			          (getprop (@ mode entities) entix) (@ self chart) dom-coords
			          (lambda (ent)
			            (setf entity-clicked true
				          (@ ent layer-points)
				          (list (chain g (to-dom-coords (@ ent points 0 0)
                                                                        (@ ent points 0 1)))
					        (chain g (to-dom-coords (@ ent points 1 0)
                                                                        (@ ent points 1 1)))))
			            (if (@ ent in-flux)
				        (if (and (> 8 (abs (- (@ ent layer-points 0 0) (@ dom-coords 0))))
					         (> 8 (abs (- (@ ent layer-points 0 1) (@ dom-coords 1)))))
				            (chain (@ ent points-in-flux) (push 0))
				            (if (and (> 8 (abs (- (@ ent layer-points 1 0)
                                                                  (@ dom-coords 0))))
						     (> 8 (abs (- (@ ent layer-points 1 1)
                                                                  (@ dom-coords 1)))))
					        (chain (@ ent points-in-flux) (push 1)))))
			            (if (not (@ ent in-flux))
				        ;; only push the entity if it isn't already in flux, else
				        ;; entities can be pushed into the in-flux list multiple times
				        (progn (setf (@ ent in-flux) true)
					       (chain mode entities-in-flux (push ent))))))))
	         (if (not entity-clicked)
		     (progn (setf (@ mode entities-in-flux) (list))
			    (loop for ent in (@ mode entities)
			          do (setf (@ ent in-flux) false))))
	         ;; (cl :flux (@ mode entities-in-flux))
	         (setf (@ mode moving-from) canvas-coords)
	         ;; (cl :mm (@ mode moving-from))
	         (if (= 0 (@ mode entities-in-flux length))
		     (progn (chain context (initialize-mouse-down event g context))
			    (chain window -dygraph (start-pan event g context)))
		     (chain g (draw-graph_))))
	       (if (= "draw" (@ mode interaction))
		   (let* ((time-interval (- (@ g raw-data_ 1 0) (@ g raw-data_ 0 0)))
			  (data-pos (chain g (to-data-coords (@ dom-coords 0) (@ dom-coords 1))))
			  (remainder (mod (@ data-pos 0) time-interval)))
		     (if (/= 0 remainder)
		         (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
		     (let* ((base (create type (@ mode draw-entity)
					  in-flux true
					  points (list (list (@ data-pos 0) (@ data-pos 1))
						       (list (@ data-pos 0) (@ data-pos 1)))
					  points-in-flux (list)))
			    (new-entity (chain j-query (extend t base (getprop self "entityTemplates"
									       (@ mode draw-entity))))))
		       (chain mode entities (push new-entity))
		       (chain mode entities-in-flux (push new-entity))
		       (setf (@ mode active-entity)
			     new-entity))))))))
     
     (defun interactor-mouseup (mode)
       (lambda (event chart context)
         (chain console (log "bbb"))
         (let ((self this))
           (setf (@ mode mousedown) false)
           (if (= "select" (@ mode interaction))
               (if (@ context is-panning)
                   (progn (chain window -dygraph (end-pan event chart context))
        	          (chain chart (draw-graph_)))
                   (progn (loop for ent in (@ mode entities)
        		        do (if (@ ent in-flux)
        			       (setf (@ ent points 0)
                                             (chain chart (to-data-coords (@ ent layer-points 0 0)
        								  (@ ent layer-points 0 1)))
        			             (@ ent points 1)
                                             (chain chart (to-data-coords (@ ent layer-points 1 0)
        								  (@ ent layer-points 1 1)))
        			             (@ ent layer-points) nil
        			             (@ ent points-in-flux) (list))))
        	          (chain self (commit-entities))
        	          (chain chart (draw-graph_))))
               (if (= "draw" (@ mode interaction))
                   (progn (setf (@ mode active-entity) nil
        		        (@ mode interaction) "select")
        	          (chain self (commit-entities))
        	          (chain chart (draw-graph_))))))))
         
     (defun interactor-mousemove (mode)
       (lambda (event chart context)
         (let ((self this)
               (temp-canvas (@ chart canvas_ctx_)))
           (if (@ mode mousedown)
               (if (= "select" (@ mode interaction))
                   (if (= 0 (@ mode entities-in-flux length))
        	       (if (@ context is-panning)
        	           (chain window -dygraph (move-pan event chart context))
        	           (chain chart (draw-graph_)))
        	       (let ((moving-from (@ mode moving-from)))
        	         (chain temp-canvas (clear-rect 0 0 (@ chart canvas_ width)
                                                        (@ chart canvas_ height)))
        	         ;; (cl :ent (@ mode entities-in-flux))
        	         (loop for ent in (@ mode entities-in-flux)
        		       do (if (= 0 (@ ent points-in-flux length))
        		              (setf (@ ent layer-points)
        			            (list (list (- (@ ent layer-points 0 0)
        					           (- (@ moving-from 0) (@ event layer-x)))
        					        (- (@ ent layer-points 0 1)
        					           (- (@ moving-from 1) (@ event layer-y))))
        				          (list (- (@ ent layer-points 1 0)
        					           (- (@ moving-from 0) (@ event layer-x)))
        					        (- (@ ent layer-points 1 1)
        					           (- (@ moving-from 1) (@ event layer-y))))))
        		              (let* ((time-interval (- (@ chart raw-data_ 1 0)
                                                               (@ chart raw-data_ 0 0)))
        			             (dom-coords (chain chart (event-to-dom-coords event)))
        			             (data-pos (chain chart (to-data-coords (@ dom-coords 0)
                                                                                    (@ dom-coords 1))))
        			             (remainder (mod (@ data-pos 0) time-interval)))
        			        (if (/= 0 remainder)
        			            (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
        			        (let ((column-value (getprop (@ self state content-index)
                                                                     (@ data-pos 0))))
        			          (loop for point in (@ ent points-in-flux)
        			                do (setf (getprop ent "layerPoints" point)
        				                 (list (@ event layer-x) (@ event layer-y))
        				                 time-coord
                                                         (chain chart (to-dom-y-coord (@ column-value 1))))
        			                   (if (> 8 (abs (- time-coord (getprop ent "layerPoints"
                                                                                        point 1))))
        				               (progn (chain console (log "Snapped!"))
        					              (setf (getprop ent "layerPoints" point 1)
                                                                    time-coord)))))))
        		          (setf (@ mode moving-from) (list (@ event layer-x)
                                                                            (@ event layer-y)))
        		          (funcall (getprop self "entityMethods" (@ ent type) "draw")
        			           temp-canvas ent chart))))
                   ;; TODO: add move-ephemera logic
                   (if (= "draw" (@ mode interaction))
        	       (let* ((time-interval (- (@ chart raw-data_ 1 0) (@ chart raw-data_ 0 0)))
        		      (dom-coords (chain chart (event-to-dom-coords event)))
        		      (data-pos (chain chart (to-data-coords (@ dom-coords 0) (@ dom-coords 1))))
        		      (remainder (mod (@ data-pos 0) time-interval))
        		      (ent (@ mode active-entity)))
        	         ;; snap to nearest rounded-down time interval
        	         (if (/= 0 remainder)
        		     (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
        	         ;; (cl :ss remainder (@ data-pos 0))
        	         (setf (@ ent points 1) (list (@ data-pos 0) (@ data-pos 1)))
        	         (chain temp-canvas (clear-rect 0 0 (@ chart canvas_ width)
                                                        (@ chart canvas_ height)))
        	         (funcall (getprop self "entityMethods" (@ ent type) "draw")
        		          temp-canvas ent chart))))))))
     
     (defun candle-plotter (e)
       (if (/= 0 (@ e series-index))
	   (let ((self this)
	         (set-count (@ e series-count)))
	     (if (/= 8 set-count)
	         (chain console
                        (log "Error: Exactly 4 prices each point must be provided for the candle chart."))
	         (let* ((prices #())
		        (sets (@ e all-series-points))
		        (area (@ e plot-area))
		        (ctx (@ e drawing-context))
		        (candle-max-spacing 3)
		        (bar-count (let ((range (chain e dygraph (x-axis-range)))
				         (counting false) (length 0))
				     (loop :for point :in (@ sets 0)
				           do (if (and (not counting)
						       (> (@ point xval) (@ range 0)))
					          (setf counting true))
					      (if (and counting (> (@ point xval) (floor (@ range 1))))
					          (setf counting false))
					      (if counting (setq length (1+ length))))
				     length))
		        (view-width (@ (chain e dygraph (get-area)) w))
		        (bar-width (max 1 (* 0.7 (/ view-width bar-count))))
		        (up-fill-style "rgba(38,139,210,1.0)")
		        (up-stroke-style (if (< 2 bar-width) "rgba(38,139,210,1.0)"
                                             "rgba(38,139,210,0.6)"))
		        (down-fill-style "rgba(220,50,47,1.0)")
		        (down-stroke-style (if (< 2 bar-width) "rgba(220,50,47,1.0)"
                                               "rgba(220,50,47,0.6)")))
		   (setf (@ ctx line-width) 0.6)
		   (loop :for p :from 0 :to (1- (@ sets 0 length))
		         :do (let* ((price (create open (getprop sets 0 p "yval")
					           close (getprop sets 1 p "yval")
					           high (getprop sets 2 p "yval")
					           low (getprop sets 3 p "yval")
					           open-y (getprop sets 0 p "y")
					           close-y (getprop sets 1 p "y")
					           high-y (getprop sets 2 p "y")
					           low-y (getprop sets 3 p "y")))
			            (top-y (+ (@ area y) (* (@ area h) (@ price high-y))))
			            (bottom-y (+ (@ area y) (* (@ area h) (@ price low-y))))
			            (center-x (+ (@ area x) (* (@ area w) (getprop sets 0 p "x"))))
			            (body-y nil)
			            (body-height nil))
			       (chain prices (push price))
			       (chain ctx (begin-path))
			       (chain ctx (move-to center-x top-y))
			       (chain ctx (line-to center-x bottom-y))
			       (chain ctx (close-path))
			       (if (> (@ price open) (@ price close))
			           (setf (@ ctx fill-style) down-fill-style
				         (@ ctx stroke-style) down-stroke-style
				         body-y (+ (@ area y) (* (@ area h) (@ price open-y))))
			           (setf (@ ctx fill-style) up-fill-style
				         (@ ctx stroke-style) up-stroke-style
				         body-y (+ (@ area y) (* (@ area h) (@ price close-y)))))
			       (chain ctx (stroke))
			       (setq body-height (* (@ area h) (abs (- (@ price open-y) (@ price close-y)))))
			       (chain ctx (fill-rect (- center-x (/ bar-width 2))
					             body-y bar-width body-height))))
		   (setf (@ ctx stroke-style) "black"
		         (@ ctx line-width) 1.5)
		   ;; (chain console (log :ents (@ self ephemera entities)))
		   ;; (loop :for ent :in (@ self ephemera entities)
		   ;;       :do (if (not (and (@ self ephemera mousedown) (@ ent in-flux)))
		   ;;               (funcall (getprop self "entityMethods" (@ ent type) "draw")
		   ;;    	            ctx ent (@ e dygraph))))
		   )))))

     )))
