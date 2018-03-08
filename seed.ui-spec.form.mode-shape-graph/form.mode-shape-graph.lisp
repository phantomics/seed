;;;; form.mode-shape-graph.lisp

(in-package #:seed.ui-model.react)

(specify-components
 graph-shape-view-mode
 (graph-shape-view
  (:get-initial-state
   (lambda ()
     (chain console (log :gshape (@ this props)))
     (chain j-query (extend (create point #(0 0)
				    content (create)
				    point-attrs (create value nil delta nil)
				    meta (chain j-query (extend t (create max-depth 0
									  confirmed-value nil
									  invert-axis (list false true))
								(@ this props data meta))))
			    (chain this (initialize (@ this props))))))
   :initialize
   (lambda (props)
     (let* ((self this)
	    (state (funcall inherit self props
			    (lambda (d) (chain j-query (extend (@ props data) (@ d data))))
			    (lambda (pd) (@ pd data data)))))
       state))
   :element-specs #()
   ;; :modulate-methods
   ;; (lambda (methods)
   ;;   (let ((self this))
   ;;     (chain j-query
   ;; 	      (extend (create set-delta (lambda (value) (extend-state point-attrs (create delta value))))
   ;; 		      methods
   ;; 		      (create grow-point
   ;; 			      (lambda (data meta alternate-branch)
   ;; 				(let ((new-space (chain j-query (extend t #() (@ self state space)))))
   ;; 				  ;(cl :as data new-space)
   ;; 				  (chain self (assign data new-space)))
   ;; 				(chain methods
   ;; 				       (grow (if (= "undefined" (typeof alternate-branch))
   ;; 						 (@ self state data id)
   ;; 						 alternate-branch)
   ;; 					     ;; TODO: it may be desirable to add certain metadata to
   ;; 					     ;; the meta for each grow request, that's what the
   ;; 					     ;; derive-metadata function below may later be used for
   ;; 					     new-space meta)))
   ;; 			      grow-branch
   ;; 			      (lambda (space meta callback)
   ;; 				(chain methods (grow (@ self state data id) 
   ;; 						     space meta callback))))))))
   :set-confirmed-value
   (lambda (value)
     (chain this (set-state (create confirmed-value value))))
   :build-sheet-heading
   (lambda (data)
     (let ((heading (list (panic:jsl (:th :key "a0")))))
       (loop for index from 0 to (1- (@ data 0 length))
	  do (chain heading (push (panic:jsl (:th :key (+ "sheet-header-" index)
						  (chain -string (from-char-code (+ 65 index))))))))
       heading))
   ;; :move
   ;; (lambda (motion)
   ;;   (let* ((self this)
   ;; 	    (mo (chain motion (map (lambda (axis index)
   ;; 				     (* axis (if (getprop (@ self state meta invert-axis) index)
   ;; 						 -1 1))))))
   ;; 	    (new-point (list (if (< -1 (+ (@ mo 0) (@ this state point 0))
   ;; 				    (@ this state space 0 length))
   ;; 				 (+ (@ mo 0) (@ this state point 0))
   ;; 				 (@ this state point 0))
   ;; 			     (if (< -1 (+ (@ mo 1) (@ this state point 1))
   ;; 				    (@ this state space length))
   ;; 				 (+ (@ mo 1) (@ this state point 1))
   ;; 				 (@ this state point 0)))))
   ;;     ;; adjust scroll position of pane if cursor is moved out of view
   ;;     (if (and (not (= "undefined" (typeof (@ self state pane-element))))
   ;; 		(< 0 (@ self element-specs length)))
   ;; 	   (progn (if (< (+ (@ self state pane-element 0 client-height)
   ;; 			    (@ self state pane-element 0 scroll-top))
   ;; 			 (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top"))
   ;; 		      (setf (@ self state pane-element 0 scroll-top)
   ;; 			    (+ (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top")
   ;; 			       (/ (@ self state pane-element 0 client-height) 2)))
   ;; 		      (if (> (@ self state pane-element 0 scroll-top)
   ;; 			     (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top"))
   ;; 			  (setf (@ self state pane-element 0 scroll-top)
   ;; 				(- (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top")
   ;; 				   (/ (@ self state pane-element 0 client-height) 2)))))
   ;; 		  (if (< (+ (@ self state pane-element 0 client-width)
   ;; 			    (@ self state pane-element 0 scroll-left))
   ;; 			 (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left"))
   ;; 		      (setf (@ self state pane-element 0 scroll-left)
   ;; 			    (+ (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left")
   ;; 			       (/ (@ self state pane-element 0 client-height) 2)))
   ;; 		      (if (> (@ self state pane-element 0 scroll-left)
   ;; 			     (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left"))
   ;; 			  (setf (@ self state pane-element 0 scroll-left)
   ;; 				(- (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left")
   ;; 				   (/ (@ self state pane-element 0 client-width) 2)))))))
   ;;     (chain this (set-state (create point new-point)))))
   ;; :assign
   ;; (lambda (value matrix)
   ;;   (let* ((x (@ this state point 0))
   ;; 	    (y (@ this state point 1))
   ;; 	    (original-value (getprop matrix y x)))
   ;;     (setf (getprop matrix y x)
   ;; 	     (if (= "[object Array]" (chain -object prototype to-string (call original-value)))
   ;; 		 (if (not (null value))
   ;; 		     ;; assign the unknown type for now;
   ;; 		     ;; an accurate type will be assigned server-side
   ;; 		     (create type "__unknown"
   ;; 			     data-inp value))
   ;; 		 (if (null value)
   ;; 		     (list)
   ;; 		     (chain j-query (extend (create) original-value
   ;; 					    (create data-inp-ovr value))))))
   ;;     matrix))
   :component-will-receive-props
   (lambda (next-props)
     (defvar self this)

     (let ((new-state (chain this (initialize next-props))))
       (if (@ self state context is-point)
	   (setf (@ new-state action-registered)
		 (@ next-props action)))
       (chain this (set-state new-state)))

     (if (and (not (@ self state pane-element))
	      (not (= "undefined" (typeof (@ self props context fetch-pane-element)))))
	 (setf (@ new-state pane-element)
	       (chain (j-query (+ "#branch-" (@ self props context index)
				  "-" (@ self props data id))))))
     
     (handle-actions
      (@ next-props action) (@ self state) next-props
      :actions-any-branch
      ((set-branch-by-id
     	(if (= (@ params id) (@ self props data id))
     	    (chain self props context methods (set-trace (@ self props context path))))))
      :actions-point-and-focus
      ((move
     	(chain self (move (@ params vector))))
       ;; (delete-point
       ;; 	(if (not (= true (@ next-props data meta locked)))
       ;; 	    (chain self state context methods (grow-point nil (create)))))
       ;; (record
       ;; 	(if (@ self props context clipboard-id)
       ;; 	    (chain self state context methods (grow-point (create)
       ;; 							  (create vector (@ params vector)
       ;; 								  point (@ self state point)
       ;; 								  branch (@ self state data id))
       ;; 							  (@ self props context clipboard-id)))))
       ;; (recall
       ;; 	(if (and (@ self props context history-id)
       ;; 		 (not (= true (@ next-props data meta locked))))
       ;; 	    (chain self state context methods (grow-point (create)
       ;; 							  (create vector (@ params vector)
       ;; 								  "recall-branch" (@ self state data id))
       ;; 							  (@ self props context history-id)))))
       (trigger-primary
       	(cond ((= "move" (@ self state context mode))
       	       (if (not (= true (@ next-props data meta locked)))
       		   (chain self state context methods (set-mode "set"))))
       	      ((= "write" (@ self props context mode))
       	       (progn (chain self (set-state (create action-registered nil)))
       		      ;; (chain self state context methods (grow-point (@ self state point-attrs delta)
       		      ;; 						    (create)))
		      (chain console (log 222 (@ self state content value)
					  (chain -j-s-o-n (stringify (@ self state content value)))))
		      ))))
       ;; (trigger-secondary
       ;; 	(if (not (= true (@ next-props data meta locked)))
       ;; 	    (chain self state context methods (set-mode "set"))))
       (trigger-anti
     	(chain self state context methods (set-mode "move")))
       (commit
     	(if (not (= true (@ next-props data meta locked)))
     	    (chain self state context methods (grow-branch (@ self state space)
     							   (create save true)))))))
     )
   ;; :should-component-update
   ;; (lambda (next-props next-state)
   ;;   (or (not (@ next-state context current))
   ;; 	 (not (= (@ next-state context mode)
   ;; 		 (@ this state context mode)))
   ;; 	 (@ next-state action-registered)))
   ;; :make-display
   ;; (lambda (main-display)
   ;;   (let* ((width 330)
   ;; 	    (bar-height 12)
   ;; 	    (link-class "test-link")
   ;; 	    (duration 6)
   ;; 	    (layout (chain window d3 layout (tree) (size (list 0 width))))
   ;; 	    (diagonal (chain window d3 svg (diagonal)
   ;; 			     (projection (lambda (d) (list (@ d x) (@ d y))))))
   ;; 	    (nodes (chain layout (nodes (create name "bla" id "bla1"
   ;; 						children (list (create name "ab" id "ab1")
   ;; 							       (create name "cd" id "cd1")
   ;; 							       (create name "ef" id "ef1"))))))
   ;; 	    (max-depth 5)
   ;; 	    (horizontal-interval (/ (* width 0.6) max-depth)))
   ;;     (chain nodes (for-each (lambda (n i)
   ;; 				(setf (@ n x) (* i bar-height))
   ;; 				(if (< 0 (@ n depth))
   ;; 				    (setf (@ n y)
   ;; 					  (* horizontal-interval (- (@ n depth) 1)))))))
   ;;     (chain console (log :nn nodes))
   ;;     (let* ((each-node (chain main-display (select-all ".item")
   ;; 				(data nodes (lambda (d) (@ d id)))))
   ;; 	      (each-link (chain main-display (select-all "path.link")
   ;; 				(data (chain layout (links nodes))
   ;; 				      (lambda (d) (@ d target id)))))
   ;; 	      (node-enter (chain each-node (enter)
   ;; 				 (append "svg:g")
   ;; 				 (attr "class" (lambda (d)
   ;; 						 (cl :node-d d)
   ;; 						 (let ((type-parts nil)
   ;; 						       (obj-class "item ")
   ;; 						       (link-id-parts nil))
   ;; 						   (if (@ d type)
   ;; 						       (let ((type-parts (chain d type (split "_"))))
   ;; 							 (setq obj-class (+ obj-class (@ type-parts 0)
   ;; 									    " " (@ type-parts 1) " "))
   ;; 							 (if (= "link" (@ type-parts 0))
   ;; 							     (let ((link-id-parts (chain d id (split "_"))))
   ;; 							       (setq obj-class (+ obj-class "parentId-"
   ;; 										  (@ link-id-parts 0) " "))
   ;; 							       (if (@ d last-item)
   ;; 								   (setq obj-class (+ obj-class "last-item ")))
   ;; 							       (if (= "" (@ d to))
   ;; 								   (setq obj-class (+ obj-class
   ;; 										      "broken-link "))))))))))
   ;; 				 (attr "id" (lambda (d) (+ "obj-" (@ d id) " " (@ d name))))
   ;; 				 (attr "display" (lambda (d)
   ;; 						   (if (and (= 0 (@ d depth))
   ;; 							    (= "root" (@ d title)))
   ;; 						       "none" "relative")))
   ;; 				 (style "opacity" 1e-6)))
   ;; 	      (node-transition (chain each-node (transition)
   ;; 				      (duration duration)
   ;; 				      (attr "transform" (lambda (d) (+ "translate(" (@ d y) ","
   ;; 								       (@ d x) ")")))
   ;; 				      (style "opacity" 1)))
   ;; 	      (link-enter (chain each-link (enter)
   ;; 				 (insert "svg:path" "g")
   ;; 				 (attr "class" link-class)
   ;; 				 (attr "d" (lambda (d) (let ((o (create x (@ d source x0)
   ;; 									y (@ d source y0))))
   ;; 							 (funcall diagonal (create source o target o)))))
   ;; 				 (attr "display" (lambda (d) (if (= "0" (@ d source id))
   ;; 								 "none" "relative"))))))
   ;; 	 (chain node-enter (attr "transform" (lambda (d) (if (< 1 (@ d depth))
   ;; 							     (+ "translate(" (@ source y)
   ;; 								"," (@ source x) ")")
   ;; 							     (+ "translate(" (@ d y)
   ;; 								"," (@ d x) ")")))))
   ;; 	 (chain node-enter (transition)
   ;; 		(duration duration)
   ;; 		(attr "transform" (lambda (d) (if (<= 1 (@ d depth))
   ;; 						  (+ "translate(" (@ d y) "," (@ d x) ")"))))
   ;; 		(style "opacity" 1))

   ;; 	 ;; (chain node-transition (select ".icon-title-frame .text-frame")
   ;; 	 ;; 	(attr "width" (lambda (d) (if (< 0 width)
   ;; 	 ;; 				      (- width (+ (@ d y) (* 1.75 bar-height)))))))

   ;; 	 ;; (chain node-transition (select ".icon-title-frame .interactor")
   ;; 	 ;; 	(attr "width" (lambda (d) (if (< 0 width)
   ;; 	 ;; 				      (- width (+ (@ d y) (* 1.75 bar-height)))))))

	 
   ;; 	 ;; (chain node-transition (select ".shift-control")
   ;; 	 ;; 	(attr "transform" (lambda (d) 
   ;; 	 ;; 			    (+ "translate(" (- width (* 2 (+ (@ d y) (+ 19.25 (* bar-height 0.28 2)))))
   ;; 	 ;; 			       ", 0)"))))

   ;; 	 (chain each-node (exit) (transition)
   ;; 		(duration duration)
   ;; 		(attr "transform" (lambda (d) (+ "translate(" (@ source y) "," (@ source x) ")")))
   ;; 		(style "opacity" 1e-6)
   ;; 		(remove))

   ;; 	 ;; (chain link-enter (transition)
   ;; 	 ;; 	(duration duration)
   ;; 	 ;; 	(attr "d" (funcall diagonal)))

   ;; 	 ;; (chain each-link (transition)
   ;; 	 ;; 	(duration duration)
   ;; 	 ;; 	(attr "d" (funcall diagonal)))

   ;; 	 (chain each-link (exit) (transition)
   ;; 		(duration duration)
   ;; 		(attr "d" (lambda (d) (let ((o (create x (@ d source x) y (@ d source y))))
   ;; 					(diagonal (create source o target o)))))
   ;; 		(remove))

   ;; 	 (chain nodes (for-each (lambda (d) (setf (@ d x0) (@ d x)
   ;; 						  (@ d y0) (@ d y)))))

   ;; 		      ;;return 'translate(' + (params.width - ((d.y) + ((19.25 + ((params.barHeight * 0.28) * 2)) * 2))) + ', 0)';
   ;; 	 )))
   ;; ;; :component-will-mount
   ;; ;; (lambda ()
   ;; ;;   (let ((faux-container (chain this props (connect-faux-d-o-m "div" "chart"))))
   ;; ;;     (chain window d3 (select faux-container)
   ;; ;; 	      (append "svg"))))
   :make-display
   (lambda (main-display callback)
     (let* ((width 330)
	    (bar-height 20)
	    (link-class "test-link")
	    (duration 400)
	    (diagonal (chain window d3 (link-horizontal)
			     (x (lambda (d) (@ d y)))
			     (y (lambda (d) (@ d x)))))
	    (root (chain window d3 (hierarchy (create name "bla" id "bla"
						      children (list (create name "ab" id "ab1")
								     (create name "cd" id "cd2")
								     (create name "ef" id "ef3"))))))
	    (max-depth 5)
	    (horizontal-interval (/ (* width 0.6) max-depth)))
       (update root)
       (defun update (source)
	 (setq nodes (chain source (descendants)))
	 (chain window d3 (select "svg") (transition) (duration duration) (style "height" "600px"))
	 ;;(chain window d3 (select
	 (let ((index 0))
	   (chain root (each-before (lambda (n) (setf (@ n x) (* index bar-height)
						      (@ n y) (* n.depth horizontal-interval)
						      index (1+ index))))))
	 (setq node (chain main-display (select-all ".item")
			   (data nodes (lambda (d) (@ d id))))
	       node-enter (chain node (enter)
				 (append "svg:g")
				 (attr "class" (lambda (d)
						 (let ((type-parts nil)
						       (obj-class "item ")
						       (link-id-parts nil))
						   (if (@ d type)
						       (let ((type-parts (chain d type (split "_"))))
							 (setq obj-class (+ obj-class (@ type-parts 0)
									    " " (@ type-parts 1) " "))
							 (if (= "link" (@ type-parts 0))
							     (let ((link-id-parts
								    (chain d id (split "_"))))
							       (setq obj-class (+ obj-class "parentId-"
										  (@ link-id-parts 0) " "))
							       (if (@ d last-item)
								   (setq obj-class
									 (+ obj-class "last-item ")))
							       (if (= "" (@ d to))
								   (setq obj-class
									 (+ obj-class
									    "broken-link "))))))))))
				 (attr "id" (lambda (d) (+ "obj-" (@ d id))))
				 (attr "transform" (lambda (d) (if (< 1 (@ d depth))
								   (+ "translate(" (@ source y)
								      "," (@ source x) ")")
								   (+ "translate(" (@ d y)
								      "," (@ d x) ")"))))
				 (attr "display" (lambda (d)
						   (if (and (= 0 (@ d depth))
							    (= "root" (@ d title)))
						       "none" "relative")))
				 (style "opacity" 1)))
	 ;; (each-link (chain main-display (select-all "path.link")
	 ;; 		   (data ;;(chain layout (links nodes))
	 ;; 		    (chain root (links))
	 ;; 		    (lambda (d) (@ d target id)))))
	 ;; (node-transition (chain node (transition)
	 ;; 			(duration duration)
	 ;; 			(attr "transform" (lambda (d) (+ "translate(" (@ d y) ","
	 ;; 							 (@ d x) ")")))
	 ;; 			(style "opacity" 1)))
	 ;; (link-enter (chain each-link (enter)
	 ;; 		   (insert "svg:path" "g")
	 ;; 		   (attr "class" link-class)
	 ;; 		   (attr "d" (lambda (d) (let ((o (create x (@ d source x0)
	 ;; 							  y (@ d source y0))))
	 ;; 					   (diagonal (create source o
	 ;; 							     target o)))))
	 ;; 		   (attr "display" (lambda (d) (if (= "0" (@ d source id))
	 ;; 						   "none" "relative"))))))
	   ;; (chain node-enter (attr "transform" (lambda (d) (if (< 1 (@ d depth))
	   ;; 						       (+ "translate(" (@ source y)
	   ;; 							  "," (@ source x) ")")
	   ;; 						       (+ "translate(" (@ d y)
	   ;; 							  "," (@ d x) ")")))))
	   (chain node-enter (transition)
		  (duration duration)
		  (attr "transform" (lambda (d) (if (<= 1 (@ d depth))
						    (+ "translate(" (@ d y) "," (@ d x) ")"))))
		  (style "opacity" 1))

	   (chain node (transition)
		  (duration duration)
		  (attr "transform" (lambda (d) (if (<= 1 (@ d depth))
						    (+ "translate(" (@ d y) "," (@ d x) ")"))))
		  (style "opacity" 1)
		  (select "rect")
		  (style "fill" "#c80000"))

	   ;; (chain node-transition (select ".icon-title-frame .text-frame")
	   ;; 	  (attr "width" (lambda (d) (if (< 0 width)
	   ;; 					(- width (+ (@ d y) (* 1.75 bar-height)))))))

	   ;; (chain node-transition (select ".icon-title-frame .interactor")
	   ;; 	  (attr "width" (lambda (d) (if (< 0 width)
	   ;; 					(- width (+ (@ d y) (* 1.75 bar-height)))))))

	   
	   ;; (chain node-transition (select ".shift-control")
	   ;; 	  (attr "transform" (lambda (d) 
	   ;; 			      (+ "translate(" (- width (* 2 (+ (@ d y) (+ 19.25 (* bar-height 0.28 2)))))
	   ;; 				 ", 0)"))))

	   (chain node (exit) (transition)
		  (duration duration)
		  (attr "transform" (lambda (d) (+ "translate(" (@ source y) "," (@ source x) ")")))
		  (style "opacity" 0)
		  (remove))

	   (setq link (chain main-display (select-all "path.link")
			     (data (chain root (links))
				   (lambda (d) (@ d target id)))))

	   (chain link (enter)
		  (insert "path" "g")
		  (attr "class" "link")
		  (attr "d" (lambda (d)
			      (let ((o (create x (@ source x0) y (@ source y0))))
				(funcall diagonal (create source o target o)))))
		  (transition)
		  (duration duration)
		  (attr "d" diagonal))

	   (chain link (transition)
		  (duration duration)
		  (attr "d" diagonal))

	   (chain link (exit) (transition)
		  (duration duration)
		  (attr "d" (lambda (d) (let ((o (create x (@ d source x) y (@ d source y))))
					  (diagonal (create source o target o)))))
		  (remove))

	   (chain root (each (lambda (d) (setf (@ d x0) (@ d x)
					       (@ d y0) (@ d y)))))
	   
	   (if callback (funcall callback (create node node node-enter node-enter))))))
   ;; :component-will-mount
   ;; (lambda ()
   ;;   (let ((faux-container (chain this props (connect-faux-d-o-m "div" "chart"))))
   ;;     (chain window d3 (select faux-container)
   ;; 	      (append "svg"))))
   :text-effect
   (lambda (params)
     
     (chain params node-enter (append "text")
	    (attr "class" "text")
	    (text (lambda (d) (@ d data name)))))
   ;; :icon-effect
   ;; (lambda (params
   ;;      nodeIcon = eachNode.append('svg:g')
   ;;          .attr('class', function(d) {
   ;;              var x, toReturn;
   ;;              if (typeof d.types !== 'array') return d.type + ' object-data-fetch glyph';
   ;;              else {
   ;;                  toReturn = '';
   ;;                  for (x = 0; x < d.types.length; x += 1) toReturn += d.types[x] + ' ';
   ;;                  //console.log(toReturn + ' object-data-fetch');
   ;;                  return toReturn + ' object-data-fetch glyph';
   ;;              }
   ;;          })
   ;; 	(let ((node-icon (chain params node-enter (append "svg:g")
   ;; 				(attr "class" (lambda (d)
   ;; 						(if (/= "array" (typeof (@ d type)))
   ;; 						    (+ (@ d type) " object-data-fetch glyph")))))))
   ;; 	  (chain node-icon (append "svg:path")
   ;; 		 (attr "class" (lambda (d)
   ;; 				 (let ((to-return "outer-meta-spokes"))
   ;; 				   ;; complete...
   ;; 				   to-return)))
   ;; 		 (attr "d" (lambda (d) ""
   ;; 				   ;; manifest outer spoke points
   ;; 				   ))
   ;; 		 (attr "transform" "translate("")")))))
		    

   ;;   )
   :component-did-mount
   (lambda ()
   (let* ((self this)
	  (faux-container (chain this props (connect-faux-d-o-m "div" "chart")))
	  (main-display (chain window d3 (select faux-container)
			       (append "svg")
			       (attr "id" "mySvg"))))
     (chain self (make-display main-display (lambda (params)
					      (cl :par params)
					      (chain subcomponents (effects params)))))))
   :component-did-update
   (lambda ()
     (let ((faux-container (chain this props (connect-faux-d-o-m "div" "chart"))))
       (chain window d3 (select faux-container)
	      (append "text")
	      (attr "x" 20)
	      (attr "y" 20)
	      (text "Hello, testing."))))
   )
  (defvar self this)
  ;(cl "SHR" (@ this state just-updated))
  ;;(chain console (log :abc (@ self state data) -slate-editor -slate-value))
  ;(chain console (log :ssp (@ self state space)))
  ;;(let ((-data-sheet (new -react-data-sheet)))
  ;; (chain console (log :cc (@ self props action) (@ self state context mode)
  ;; 		      (@ self state context)))
  (panic:jsl (:div ;;:value (@ self state content)
  		   :id "testcomponent"
  		   :on-change (lambda (value)
  				(chain self (set-state (create content (@ value value)))))
  		   ;; :on-focus (lambda (value)
  		   ;; 		 (chain self state context methods (set-mode "write")))
  		   ;; :on-blur (lambda (value)
  		   ;; 		;;(chain console (log :bb value))
  		   ;; 		(chain self state context methods (set-mode "move")))
  		   :style (create height "100%" padding "4px 6px" color "#002b36")
		   (@ self props chart)))
  ;;(@ self props chart)
  ))
