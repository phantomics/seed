;;;; form.mode-shape-graph.lisp

(in-package #:seed.ui-model.react)

(specify-components
 graph-shape-view-mode
 (graph-vector-renderer
  (:get-initial-state
   (lambda () (create point 0))
   :container-element nil
   :display-format
   (lambda (graph index)
     (let ((index (if index index 0)))
       ;; (cl :gr graph)
       (chain graph (map (lambda (node)
			   (setf (@ node children) (@ node links)
				 (@ node index) index
				 index (1+ index))
			   node)))))
   :component-did-mount
   (lambda ()
     (let* ((self this)
	    (faux-container (chain self props (connect-faux-d-o-m "div" "chart")))
	    (main-display (chain window d3 (select faux-container)
				 (append "svg")
				 (attr "class" "vector-interface"))))
       (chain self (make-display main-display (lambda (params) (chain subcomponents (effects params)))))))
   :extend-model
   (let ((last-update 0))
     (lambda (original extension)
       ;;(cl :orr original extension (@ this props meta))
       (let* ((self this)
	      (build-root (lambda (nodes)
			    (chain window d3 (hierarchy (create name "root" id "root"
								children (chain self (display-format nodes))))))))
	 (if (not original)
	     (build-root extension)
	     (if (@ self props meta change)
		 (if (< last-update (@ self props updated))
		     (progn (setf last-update (@ self props updated))
			    (cond ((@ self props meta change node-added)
				   (let ((object (build-root (list (getprop extension
									    (1- (@ extension length)))))))
				     ;; get the last node in the new extended node array
				     (chain original children (push (@ object children 0)))
				     original))
				  ((@ self props meta change link-added)
				   (let ((new-link nil))
				     (chain extension
					    (map (lambda (node)
						   (if (= (@ node id) (@ self props meta change node-id))
						       (setq new-link
							     (build-root (list (getprop node "links"
											(1- (@ node links
												    length))))))))))
				     (chain original
					    (each (lambda (node)
						    (if (and (= (@ node data id) (@ self props meta change node-id))
							     (not (@ node data to)))
							(let ((this-link (chain j-query
										(extend (create)
											(@ new-link children 0)))))
							  (setf (@ this-link parent) node
								(@ this-link depth) (1+ (@ node depth)))
							  (chain node children (push this-link)))))))
				     original))
				  ((@ self props meta change object-removed)
				   (if (< 0 (@ self props meta change link-id length))
				       (chain original
					      (each (lambda (node)
						      (if (= (@ node data id)
							     (@ self props meta change node-id))
							  (setf (@ node children)
								(chain node children
								       (filter (lambda (link)
										 (not (= (@ link data id)
											 (@ self props
												 meta change
												 link-id)))))))))))
				       (progn (setf (@ original children)
						    (chain original children
							   (filter (lambda (node)
								     (not (= (@ node data id)
									     (@ self props meta
										     change node-id)))))))
					      (chain original (each (lambda (node)
								      (if (and (@ node data to)
									       (= (@ self props meta
											  change node-id)
										  (@ node data to)))
									  (if (@ node children)
									      (setf (@ node _children) (list)
										    (@ node children) null))))))))
				   original)
				  (t original)))
		     original)
		 original)))))
   :make-display
   (let ((display-model nil))
   (lambda (main-display callback)
     ;; (cl 9000 (@ this props width))
     ;; (cl :md (@ this props data))
     (let* ((self this)
	    (root (let* ((model (chain self (extend-model display-model (@ self props data)))))
		    (if (not display-model)
			(chain model (each (lambda (d)
					     (if (= 1 (@ d depth))
						 (if (@ d children)
						     (setf (@ d _children) (@ d children)
							   (@ d children) null)))))))
		    (setq display-model model)
		    model))
	    (from-link (lambda (parent id)
			 (let ((found nil))
			   (loop for item in (@ root children)
			      do (if (= id (@ item data id))
				     (setq found (chain j-query (extend (create) item)))))
			   (if (and (@ found _children) (not (= "untitled" (typeof (@ found _children)))))
			       (setf (@ found children) (@ found _children)
				     (@ found _children) nil))
			   (let ((downstream (chain found (copy))))
			     (setf (@ downstream parent) parent
				   (@ downstream depth) (1+ (@ parent depth))
				   (@ downstream _children) (chain downstream children
								   (map (lambda (item)
									  (setf (@ item depth)
										(+ 2 (@ parent depth))
										(@ item children) null)
									  item)))
				   (@ downstream children) null)
			     downstream))))
	    (params (create width (@ self container-element client-width)
			    section 32
			    link-indent 3
			    link-class "test-link"
			    duration 600
			    visualizer-logic (create node-has-children
						     (lambda (d)
						       (or (@ d data to)
							   (and (@ d children) (< 0 (@ d children length)))
							   (and (@ d _children) (< 0 (@ d _children length)))))
						     node-expanded (lambda (d) (@ d children)))
			    interface-actions (create expand-toggle-object
						      (lambda (d)
							(if (not (@ d children))
							    (if (and (@ d data to) (not (@ d _children)))
								(setf (@ d children)
								      (list (from-link d (@ d data to))))
								(setf (@ d children) (@ d _children)
								      (@ d _children) null))
							    (setf (@ d _children) (@ d children)
								  (@ d children) null))
							(funcall update d))
						      set-point-object
						      (lambda (d)
							(chain self props (point-setter (1- (@ d index))
											d))))))
	    (update (lambda (source)
		      (setq nodes (chain root (descendants))
			    depth-map (list))
		      (let ((index 0))
			(chain root (each-before (lambda (n)
						   (setf (@ n x) (- (* index (@ params section))
								    (/ (@ params section) 2))
							 (@ n y) (+ 3 (* horizontal-interval
									 (1- (@ n depth))))
							 (@ n index) index
							 (getprop depth-map index) (@ n depth)
							 index (1+ index))))))
		      ;; (cl :dm2 depth-map (@ self props point) root
		      ;; 	  (@ main-display _groups 0 0 component))
		      (setq node (chain main-display (select-all ".item")
					(data nodes (lambda (d) (@ d id))))
			    node-enter (chain node (enter)
					      (append "svg:g")
					      (attr "class" (lambda (d)
							      (+ "obj-" (@ d index)
								 (if (@ d data to)
								     (+ " id-" (@ d parent data id)
									"-" (@ d data id))
								     (+ " id-" (@ d data id) " "))
								 " item "
								 (if (@ d data type)
								     (+ " type-" (@ d data type) " ")
								     "")
								 (if (= (@ d index) (1+ (@ self props point)))
								     "point" ""))))
					      (attr "transform" (lambda (d)
								  (+ "translate(" (@ d y) "," (@ d x) ")")))
					      (attr "display" (lambda (d) (if (= 0 (@ d depth))
									      "none" "relative")))
					      (style "opacity" 1)))

		      (chain node-enter (transition)
			     (duration (@ params duration))
			     (attr "transform" (lambda (d) (if (<= 1 (@ d depth))
							       (+ "translate(" (@ d y) "," (@ d x) ")"))))
			     (style "opacity" 1))

		      (chain node (transition)
			     (duration (@ params duration))
			     (attr "transform" (lambda (d) (if (<= 1 (@ d depth))
							       (+ "translate(" (@ d y) "," (@ d x) ")"))))
			     (style "opacity" 1))

		      (chain node (exit) (style "opacity" (lambda (d) (if (= 1 (@ d depth)) 0 1)))
			     (remove))

		      ;; (chain node (exit) (transition)
		      ;; 	     (duration (@ params duration))
		      ;; 	     (attr "transform" (lambda (d)
		      ;; 				 (if (< 1 (@ d depth))
		      ;; 				     (+ "translate(" (@ source y) "," (@ source x) ")"))))
		      ;; 	     (style "opacity" 0)
		      ;; 	     (remove))

		      (setq link (chain main-display (select-all "path.link")
					(data (chain root (links))
					      (lambda (d) (@ d target id)))))

		      (chain link (enter)
			     (insert "path" "g")
			     (attr "class" "link")
			     (transition)
			     (duration (@ params duration))
			     (attr "d" (lambda (d) (if (= 0 (@ d source depth))
						       "" (funcall diagonal d)))))

		      ;; (chain link (transition)
		      ;; 	     (duration (@ params duration))
		      ;; 	     (attr "d" diagonal))

		      ;; (chain link (exit) (transition)
		      ;; 	     (duration (@ params duration))
		      ;; 	     (attr "d" (lambda (d) (let ((o (create x (@ d source x) y (@ d source y))))
		      ;; 				     (diagonal (create source o target o)))))
		      ;; 	     (remove))

		      (chain link (exit) (remove))

		      (chain root (each (lambda (d) (setf (@ d x0) (@ d x)
							  (@ d y0) (@ d y)))))

		      (if callback (funcall callback (create node node node-enter node-enter params params)))

		      (chain self props (animate-faux-d-o-m (@ params duration)))))
	    (diagonal (chain window d3 (link-horizontal)
			     (x (lambda (d) (@ d y)))
			     (y (lambda (d) (@ d x)))))
	    (max-depth 5)
	    (horizontal-interval (/ (* 0.6 (@ params width)) max-depth)))
       (setf (@ this updated)
	     (@ this props updated))
       (funcall update root)
       ))))
  (let ((self this))
    (panic:jsl (:div :class-name "display-holder-inner"
		     :ref (lambda (ref) (if (not (@ self container-element))
					    (setf (@ self container-element)
						  ref)))
		     (@ self props chart)))))
 (graph-shape-view
  (:get-initial-state
   (lambda ()
     (let ((self this))
       (chain console (log :gshape (@ this props)))
       (chain j-query (extend (create point 0
				      content (create)
				      point-object (@ this props data data 0)
				      point-parent nil
				      meta (chain j-query (extend t (create max-depth 0
									    confirmed-value nil
									    invert-axis (list false true))
								  (@ this props data meta))))
			      (chain this (initialize (@ this props)))))))
   :vector-renderer nil
   :subordinate-space (list)
   :updated 0
   :set-point
   (lambda (index object)
     (let ((self this))
       (chain (j-query (+ "#branch-" (@ self props context index)
       			  "-" (@ self props data id)
       			  " .vector-interface .item"))
       	      (remove-class "point"))
       (chain (j-query (+ "#branch-" (@ self props context index)
       			  "-" (@ self props data id)
       			  " .vector-interface .item.obj-" (1+ index)))
       	      (add-class "point"))
       (chain self (set-state (create point index point-object (if object (@ object data))
				      point-parent (if (and object (@ object data to) (@ object parent))
						       (@ object parent data) nil))))))
   :initialize
   (lambda (props)
     (let* ((self this)
	    (state (funcall inherit self props
			    (lambda (d) (chain j-query (extend (@ props data) (@ d data))))
			    (lambda (pd) (@ pd data data)))))

       (if (@ self props context set-interaction)
	   (progn (chain self props context
			 (set-interaction "addGraphNode"
					  (lambda () (chain self state context methods
							    (grow #() (create add-node true
									      object-type "__option"
									      object-meta (create title "Untitled"
												  about "")))))))
		  (chain self props context
			 (set-interaction "addGraphLink"
					  (lambda () (chain self state context methods
							    (grow #() (create add-link true
									      node-id
									      (@ self state point-object id)
									      object-meta (create title "Untitled"
												  about "")))))))
		  (chain self props context
			 (set-interaction "removeGraphObject"
					  (lambda () (chain self state context methods
							    (grow #() (create link-id
									      (@ self state point-object id)
									      node-id
									      (if (@ self state point-parent)
										  (@ self state point-parent id))
									      remove-object true))))))))
       state))
   :container-element nil
   :element-specs #()
   :modulate-methods
   (lambda (methods)
     (let* ((self this)
	    (to-grow (if (@ self props context parent-system)
			 (chain methods (in-context-grow (@ self props context parent-system)))
			 (@ methods grow))))
       (chain j-query
   	      (extend (create ;;set-delta (lambda (value) (extend-state point-attrs (create delta value)))
			      set-point (lambda (datum) (chain self (set-point (@ datum index))))
			      delete-point (lambda (point) (chain self (delete-point point))))
   		      methods
   		      (create grow
   			      (lambda (data meta alternate-branch)
				(let ((space (let ((new-space (chain j-query (extend #() (@ self state space)))))
					       new-space)))
				  (to-grow (if (= "undefined" (typeof alternate-branch))
				  	       (@ self state data id)
				  	       alternate-branch)
				  	   ;; TODO: it may be desirable to add certain metadata to
				  	   ;; the meta for each grow request, that's what the
				  	   ;; derive-metadata function below may later be used for
				  	   space meta)))
   			      grow-branch
   			      (lambda (space meta callback)
   				(chain methods (grow (@ self state data id)
   						     space meta callback))))))))
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
   ;; :interactions
   ;; (create add-graph-node
   ;; 	   (create click (lambda (self datum)
   ;; 			   (cl :add-node))
   ;; 		   trigger-primary (lambda (self datum) (cl :add-node2))
   ;; 		   trigger-secondary (lambda (self datum) (cl :add-node3))))
   :move
   (lambda (vector)
     (let* ((self this)
	    (new-point (max 0 (+ (- (@ vector 1))
				 (@ vector 0) (@ self state point)))))
       ;;(cl vector (@ self state point) new-point)
       (chain self (set-point new-point))))
   :should-component-update
   (lambda (next-props next-state)
     ;;(cl :nxp next-props (@ this state) (@ this updated))
     ;; (or (not (@ this state data))
     ;; 	 (not (@ next-props current)))
     (or (not (= (@ this updated) (@ next-props updated)))
	 (not (@ next-state context current))))
   :component-will-receive-props
   (lambda (next-props)
     (defvar self this)
     (setf (@ self updated)
	   (@ next-props updated))
     (let ((new-state (chain this (initialize next-props))))
       (if (@ self state context is-point)
	   (setf (@ new-state action-registered)
		 (@ next-props action)))
       (chain this (set-state new-state)))

     ;; (cl 919 next-props)
     ;; (cl 919)
     (if (= 0 (@ self subordinate-space length))
	 (setf (@ self subordinate-space)
	       (@ new-state space)))
     
     (handle-actions
      (@ next-props action) (@ self state) next-props
      :actions-any-branch
      ((set-branch-by-id
	(if (= (@ params id) (@ self props data id))
	    (chain self props context methods (set-trace (@ self props context path))))))
      :actions-point-and-focus
      ((move (chain self (move (@ params vector))))
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
       (trigger-primary (cl :aaa))
       (trigger-secondary (cl :bbb))
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
   ;; (lambda (main-display callback))
   ;; :component-did-mount
   ;; (lambda ()
   ;;   (let* ((self this)
   ;; 	    (faux-container (chain self props (connect-faux-d-o-m "div" "chart")))
   ;; 	    (main-display (chain window d3 (select faux-container)
   ;; 				 (append "svg")
   ;; 				 (attr "class" "vector-interface"))))
   ;;     (chain window -react-faux-dom (with-faux-d-o-m (@ view-modes graph-shape-view)))
   ;;     ;; (chain self (make-display main-display (lambda (params)
   ;;     ;; 						(chain subcomponents (effects params)))))
   ;;     ))
   )
  ;(cl "SHR" (@ this state just-updated))
  ;;(chain console (log :abc (@ self state data) -slate-editor -slate-value))
  ;(chain console (log :ssp (@ self state space)))
  ;;(let ((-data-sheet (new -react-data-sheet)))
  ;; (chain console (log :cc (@ self props action) (@ self state context mode)
  ;; 		      (@ self state context)))
  (let ((self this)
	(-renderer (chain window -react-faux-dom (with-faux-d-o-m (@ pairs graph-vector-renderer)))))
    ;; (cl 555 (@ self state space) (@ self props context updated))
    ;; (cl :self self (@ self vector-renderer)
    ;; 	(not (= "undefined" (typeof (@ self vector-renderer))))
    ;; 	(+ "#branch-" (@ self props context index)
    ;; 	   "-" (@ self props data id))
    ;; 	(j-query (+ "#branch-" (@ self props context index)
    ;; 		    "-" (@ self props data id))))
    (panic:jsl (:div :class-name "display-holder-outer"
		     (:-renderer :point (@ self state point)
				 :point-setter (@ self set-point)
				 :updated (@ self props context updated)
				 :data (@ self state space)
				 :meta (@ self props data meta)))))))
