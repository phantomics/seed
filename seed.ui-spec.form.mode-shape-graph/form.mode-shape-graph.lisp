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
       (chain self (make-display main-display
				 (lambda (params) (chain subcomponents (effects params)))))))
   :make-display
   (lambda (main-display callback)
     (let* ((self this)
	    (root (let* ((data (create name "root" id "root"
				       children (chain self (display-format (@ self props data)))))
			 (model (chain window d3 (hierarchy data))))
		    ;; (cl 676 data model)
		    (chain model (each (lambda (d)
					 (if (= 1 (@ d depth))
					     (if (@ d children)
						 (setf (@ d _children) (@ d children)
						       (@ d children) null))))))
		    model))
	    (from-link (lambda (parent id)
			 (let ((found nil))
			   (loop for item in (@ root children) do
				(if (= id (@ item data id))
				    (setq found (chain j-query (extend (create) item)))))
			   (if (and (@ found _children) (not (= "untitled" (typeof (@ found _children)))))
			       (setf (@ found children) (@ found _children)
				     (@ found _children) nil))
			   (let ((downstream (chain found (copy))))
			     ;;(cl :d (chain -j-s-o-n (stringify downstream)))
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
	    (params (create width 400 ;(@ self container-element 0 client-width)
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
			    interface-actions (create expand-toggle-node
						      (lambda (d)
							(if (not (@ d children))
							    (if (and (@ d data to) (not (@ d _children)))
								(setf (@ d children)
								      (list (from-link d (@ d data to))))
								(setf (@ d children) (@ d _children)
								      (@ d _children) null))
							    (setf (@ d _children) (@ d children)
								  (@ d children) null))
							(funcall update d)))))
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
		      (cl :dm2 depth-map (@ self props point) root)
		      (setq node (chain main-display (select-all ".item")
					(data nodes (lambda (d) (@ d id))))
			    node-enter (chain node (enter)
					      (append "svg:g")
					      (attr "class" (lambda (d)
							      (let ((type-parts nil)
								    (obj-class (+ "obj-" (@ d index)
										  " item "
										  (if (= (@ d index)
											 (1+ (@ self props point)))
										      "point " "")))
								    (link-id-parts nil))
								(if (@ d type)
								    (let ((type-parts (chain d type (split "_"))))
								      (setq obj-class (+ obj-class (@ type-parts 0)
											 " " (@ type-parts 1) " "))
								      (if (= "link" (@ type-parts 0))
									  (let ((link-id-parts
										 (chain d id (split "_"))))
									    (setq obj-class
										  (+ obj-class "parentId-"
										     (@ link-id-parts 0) " "))
									    (if (@ d last-item)
										(setq obj-class (+ obj-class
												   "last-item ")))
									    (if (= "" (@ d to))
										(setq obj-class (+ obj-class
												   "broken-link ")))
									    obj-class)))
								    obj-class))))
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
			     (attr "d" (lambda (d) (if (= 0 (@ d depth))
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
			     (x (lambda (d) (+ 0 (@ d y))))
			     (y (lambda (d) (@ d x)))))
	    (max-depth 5)
	    (horizontal-interval (/ (* 0.6 (@ params width)) max-depth)))
       (funcall update root)
       )))
  (let ((self this))
    (panic:jsl (:div :class-name "internal-test"
		     :ref (lambda (ref)
			    (if (not (@ self container-element))
				(setf (@ self container-element) (j-query ref))))
		     (@ self props chart)))))
 (graph-shape-view
  (:get-initial-state
   (lambda ()
     (let ((self this))
       (chain console (log :gshape (@ this props)))
       (chain j-query (extend (create point 0
				      content (create)
				      point-attrs (create node-id nil)
				      meta (chain j-query (extend t (create max-depth 0
									    confirmed-value nil
									    invert-axis (list false true))
								  (@ this props data meta))))
			      (chain this (initialize (@ this props)))))))
   :vector-renderer nil
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
									      (@ self state point-attrs node-id)
									      object-meta (create title "Untitled"
												  about "")))))))
		  (chain self props context
			 (set-interaction "removeGraphObject"
					  (lambda () (chain self state context methods
							    (grow #() (create remove-object true))))))))
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
   	      (extend (create set-delta (lambda (value) (extend-state point-attrs (create delta value)))
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
   :interactions
   (create add-graph-node
	   (create click (lambda (self datum)
			   (cl :add-node))
		   trigger-primary (lambda (self datum) (cl :add-node2))
		   trigger-secondary (lambda (self datum) (cl :add-node3))))
   :move
   (let ((point 0))
     (lambda (vector)
       ;;(cl :vector vector)
       (let ((self this)
	     (new-point (max 0 (+ (- (@ vector 1))
				  (@ vector 0) point))))
	 (setq point new-point)
	 (cl vector (@ self state point) new-point)
	 (chain self (set-state (create point new-point)))
	 (cl :aab (+ "#branch-" (@ self props context index)
		     "-" (@ self props data id)
		     " .vector-interface .item"))
	 (chain (j-query (+ "#branch-" (@ self props context index)
			    "-" (@ self props data id)
			    " .vector-interface .item"))
		(remove-class "point"))
	 (chain (j-query (+ "#branch-" (@ self props context index)
			    "-" (@ self props data id)
			    " .vector-interface .item.obj-" (1+ new-point)))
		(add-class "point")))))
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

     ;; (cl :909 (@ self state pane-element))
     (cl 919 next-props)
     ;;(cl 919)
     
     (handle-actions
      (@ next-props action) (@ self state) next-props
      :actions-any-branch
      ((set-branch-by-id
	(if (= (@ params id) (@ self props data id))
	    (chain self props context methods (set-trace (@ self props context path))))))
      :actions-point-and-focus
      ((move ;;(cl :aac)
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
   ;; (create name "bla" id "bla"
   ;; 	      children (list (create name "ab" id "ab1"
   ;; 				     children (list (create name "aa" id "aa")
   ;; 						    (create name "bb" id "bb")))
   ;; 			     (create name "cd" id "cd2")
   ;; 			     (create name "ef" id "ef3"
   ;; 				     children (list (create name "ee" id "ee")
   ;; 						    (create name "ff" id "ff")))))
   :display-format
   (lambda (graph index)
     (let ((index (if index index 0)))
       (chain graph (map (lambda (node)
			   (setf (@ node children) (@ node links)
				 (@ node index) index
				 index (1+ index))
			   node)))))
   :make-display
   (lambda (main-display callback))
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
	(-ex (chain window -react-faux-dom (with-faux-d-o-m (@ pairs graph-vector-renderer)))))
    (cl :self self (@ self vector-renderer)
	(not (= "undefined" (typeof (@ self vector-renderer)))))
    (panic:jsl (:div :on-change (lambda (value) (chain self (set-state (create content (@ value value)))))
		     ;;(@ self props chart)
		     ;;(chain window -react-faux-dom (with-faux-d-o-m (@ self vector-renderer)))
		     ;; (if (not (= "undefined" (typeof (@ self vector-renderer))))
		     ;; 	 (panic:jsl ((@ self vector-renderer)))
		     ;; 	 (panic:jsl (:div)))
		     (:-ex :point (@ self state point)
			   :data (@ self props data data)))))))
