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
   ;; :permute
   ;; (lambda (input)
   ;;   (if (and (@ window -drag-source)
   ;; 	      (@ window -drop-target))
   ;; 	 (let* ((over-data nil)
   ;; 		(collect-source (lambda (connect monitor)
   ;; 				  (create connect-drag-source (chain connect (drag-source))
   ;; 					  connect-drag-preview (chain connect (drag-preview))
   ;; 					  is-dragging (chain monitor (is-dragging)))))
   ;; 		(collect-target (lambda (connect) (create connect-drop-target (chain connect (drop-target)))))
   ;; 		(item-source (create begin-drag (lambda (props) (cl 908 props))
   ;; 				     end-drag (lambda (props monitor component)
   ;; 						(if (chain monitor (did-drop))
   ;; 						    (let ((item (chain monitor (get-item)))
   ;; 							  (drop-result (chain monitor (get-drop-result))))
   ;; 						      (cl :endd item drop-result))))))
   ;; 		(item-target (create can-drop (lambda (props) t)
   ;; 				     hover (lambda (props monitor) (setq over-data (@ props data data))))))
   ;; 	   (funcall (chain window (-drop-target "node" item-target collect-target))
   ;; 		    (funcall (chain window (-drag-source "node" item-source collect-source))
   ;; 			     input)))))
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
				  ((@ self props meta change node-changed)
				   (let ((new-node nil))
				     (chain extension (map (lambda (node)
							     (if (= (@ node id)
								    (@ self props meta change node-id))
								 (setq new-node node)))))
				     (chain original children
					    (map (lambda (node index)
						   (if (= (@ node data id)
							  (@ self props meta change node-id))
						       (chain j-query
							      (extend t (getprop original "children"
										 index "data")
								      new-node))))))
				     original))
				  ((@ self props meta change link-added)
				   (let ((new-link nil))
				     (chain extension
					    (map (lambda (node)
						   (if (= (@ node id) (@ self props meta change node-id))
						       (setq new-link
							     (build-root (list (getprop node "links"
											(1- (@ node
											       links
											       length))))))))))
				     (chain original
					    (each (lambda (node)
						    (if (and (= (@ node data id)
								(@ self props meta change node-id))
							     (not (@ node data to)))
							(let ((this-link (chain j-query
										(extend (create)
											(@ new-link children 0)))))
							  (setf (@ this-link parent) node
								(@ this-link depth) (1+ (@ node depth)))
							  (chain node children (push this-link)))))))
				     original))
				  ((@ self props meta change link-connected)
				   (let ((new-link nil))
				     (chain extension
					    (map (lambda (node)
						   (if (= (@ node id) (@ self props meta change node-id))
						       (loop for link in (@ node links)
							  when (= (@ link id) (@ self props meta change link-id))
							  do (setq new-link (build-root (list link))))))))
				     (chain original
					    (each (lambda (node)
						    (if (and (= (@ node data id)
								(@ self props meta change node-id))
							     (not (@ node data to)))
							(let ((this-link (chain j-query
										(extend (create)
											(@ new-link children 0)))))
							  (setf (@ this-link parent) node
								(@ this-link depth) (1+ (@ node depth)))
							  (if (@ node children)
							      (loop for lid from 0 to (1- (@ node children length))
								 when (= (getprop node "children" lid "data" "id")
									 (@ self props meta change link-id))
								 do (setf (getprop node "children" lid)
									  this-link))))))))
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
   :id-from-node-class
   (lambda (class-string)
     (let ((segments (chain class-string (split " ")))
	   (id ""))
       (loop for seg in segments when (= "id-" (chain seg (substr 0 3)))
	  do (setq id (chain seg (substr 3))))
       id))
   :find-node-bounds
   (lambda (item)
     (let ((self this)
	   (rects (list)))
       (chain item parent-node parent-node child-nodes
	      (map (lambda (g-item index)
		     (if (and (= "g" (@ g-item node-name)))
			 (chain g-item child-nodes
				(map (lambda (c-item index)
				       ;; (cl :gi g-item)
				       (if (and (= "g" (@ c-item node-name))
						(= "glyph"  (@ c-item props class-name)))
					   (let ((ext (create id (chain self
									(id-from-node-class (@ g-item
											       props
											       class-name))))))
					     (chain rects
						    (push (chain j-query (extend (chain c-item
											(get-bounding-client-rect))
										 ext)))))))))))))
       rects))
   :confirm-drop-target
   (lambda (node callback)
     (let* ((self this)
	    (point (list (@ window d3 event source-event client-x)
			 (@ window d3 event source-event client-y)))
	    (targets (chain self (find-node-bounds node)))
	    (destination-node-id (chain self (id-from-node-class (@ node parent-node props class-name))))
	    (target-link nil))
       (loop for target in targets when (and (not target-link)
				   	     (<= (@ target left) (@ point 0) (@ target right))
				   	     (<= (@ target top) (@ point 1) (@ target bottom)))
	  do (setq target-link (@ target id)))
       (let* ((segments (chain target-link (split "-")))
	      (node-id (@ segments 0))
	      (link-id (@ segments 1)))
	 ;; (cl :drop node-id target-link)
	 (if link-id (callback node-id link-id destination-node-id)))))
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
				       (setf found (chain j-query (extend (create) item))
					     (@ found data) (@ item data))))
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
			
			;; (let ((gg (chain main-display (select-all "g.glyph"))))
			;;   (cl :gg gg
			;;       (chain gg (enter))
			;;       (chain gg (enter) (node))))
			(if callback (funcall callback (create node node node-enter node-enter params params)))

			(let* ((drag-handler (chain window d3 (drag)
						    (on "end"
							(lambda ()
							  (chain self
								 (confirm-drop-target this
										      (@ self
											 props
											 link-connector))))))))
			  ;; (cl :sa g-select (@ g-select _groups 0 0))
			  ;; (if (@ g-select _groups 1)
			  ;;     (chain g-select _groups 1 (map (lambda (item index)
			  ;; 				       ;;(chain self props (connect-drag-source item))
			  ;; 				       (if (@ item component)
			  ;; 					   (cl :rect (chain item ;;component
			  ;; 							    (get-bounding-client-rect))))
			  ;; 				       ))))
			  (drag-handler (chain main-display (select-all ".glyph"))))
			
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
       ;; (chain console (log :gshape (@ this props)))
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
     (let* ((self this)
	    (point-element (j-query (+ "#branch-" (@ self props context index)
				       "-" (@ self props data id)
				       " .vector-interface .item.obj-" (1+ index)))))
       (chain (j-query (+ "#branch-" (@ self props context index)
       			  "-" (@ self props data id)
       			  " .vector-interface .item"))
       	      (remove-class "point"))
       (chain point-element (add-class "point"))
       (let ((node-id nil))
	 (chain point-element 0 class-name base-val (split " ")
		(map (lambda (string)
		       (if (= "id-" (chain string (substr 0 3)))
			   (setq node-id (chain string (substr 3)))))))
	 (chain self state context methods (grow #() (create set-point true node-id node-id)))
	 (chain self (set-state (create point index point-object (if object (@ object data))
					point-parent (if (and object (@ object data to) (@ object parent))
							 (@ object parent data) nil)))))))
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
   :connect-link
   (lambda (node-id link-id destination-node-id)
     ;; (cl :to-target node-id link-id destination-node-id)
     (let ((self this))
       ;; (cl :st (@ self state)
       ;; 	   (@ self props))
       (chain self state context methods
	      (grow #()
		    (create connect-link true
			    node-id node-id
			    link-id link-id
			    destination-node-id destination-node-id)))))
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
				 :link-connector (@ self connect-link)
				 :updated (@ self props context updated)
				 :data (@ self state space)
				 :meta (@ self props data meta)))))))
