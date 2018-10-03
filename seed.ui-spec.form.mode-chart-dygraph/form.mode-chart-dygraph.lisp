;;;; seed.ui-spec.form.mode-chart-dygraph.lisp

(in-package #:seed.ui-model.react)

(specify-components
 dygraph-chart-view-mode
 (dygraph-chart-view
  (:get-initial-state
   (lambda () (create point 0))
   :container-element nil
   :graph nil
   :component-did-mount
   (lambda ()
     (let* ((self this))
       (setf (@ self graph)
       	     (new (chain window (-dygraph (@ self container-element)
       					  "Date,Temperature
2008-05-07,75
2008-05-08,70
2008-05-09,80
"
					  ;;"sdkjflsk"
					  (create labels (list "Date" "Temperature")
						  title "Stuff")
       					  ))))
       ;; (setf cx (chain self refs canvas (get-context "2d")))
       ;; (chain cx (fill-text "Test Text" 210 75))
       )))
  (let ((self this))
    (panic:jsl (:div :class-name "dygraph-chart-holder"
		     ;; (:canvas :ref "canvas" :width 640 :height 425)
		     (:div :class-name "dygraph-chart"
		     	   :ref (lambda (ref) (if (not (@ self container-element))
		     				  (setf (@ self container-element)
		     					ref)))
		     	   :id (+ "dygraph-chart-" (@ this props data id)))
		     ))))
 #|
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
				 :meta (@ self props data meta))))))
 |#
 )
