;;;; seed.ui-spec.form.mode-document.lisp

(in-package #:seed.ui-model.react)

(specify-components
 document-view-mode
 (document-view
  (:get-initial-state
   (lambda ()
     (let ((initial-value
	    (chain -slate-value
		   (from-j-s-o-n (if (and (@ this props data data)
				     	  (not (= "undefined" (typeof (@ this props data data)))))
				     (chain -slate-value (from-j-s-o-n (chain -j-s-o-n
									      (parse (@ this props data data)))))
				     (create kind "value"
					     document
					     (create nodes
						     (list (create kind "block"
								   type "paragraph"
								   nodes (list (create kind "text"
										       leaves
										       (list
											(create text
												"Line.")))))))))))))
       (chain j-query (extend (create point #(0 0)
				      content initial-value
				      point-attrs (create value nil delta nil)
				      meta (chain j-query (extend t (create max-depth 0
									    confirmed-value nil
									    invert-axis (list false true))
								  (@ this props data meta)))
				      read-only t)
			      (chain this (initialize (@ this props)))))))
   :editor-instance nil
   :initialize
   (lambda (props)
     (let* ((self this)
	    (state (funcall inherit self props
			    (lambda (d) (chain j-query (extend (@ props data) (@ d data))))
			    (lambda (pd) (@ pd data data)))))
       (if (@ self props context set-interaction)
	   (progn (chain self props context
			 (set-interaction "docMarkBold" (lambda () (chain self (toggle-mark "bold")))))
		  (chain self props context
			 (set-interaction "docMarkItalic" (lambda () (chain self (toggle-mark "italic")))))
		  (chain self props context
			 (set-interaction "docNodePgraph" (lambda () (chain self (set-node "paragraph")))))
		  (chain self props context
			 (set-interaction "docNodeQuote" (lambda () (chain self (set-node "quote")))))
		  (chain self props context
			 (set-interaction "docNodePoints" (lambda () (chain self (set-node "points")))))
		  (chain self props context
			 (set-interaction "docNodeCount" (lambda () (chain self (set-node "count")))))))
       state))
   :element-specs #()
   :toggle-mark
   (lambda (type-string)
     (let* ((self this)
	    (value-container (chain self editor-instance state value (change)
				    (toggle-mark type-string))))
       (chain self (set-state (create content (@ value-container value))))))
   :set-node
   (lambda (type-string)
     (let* ((self this)
	    (change (chain self editor-instance state value (change)))
	    (is-member (chain self editor-instance state value blocks (some (lambda (node)
									      (or (= "section" (@ node type))
										  (= "member" (@ node type)))))))
	    (value-container (cond ((or (= type-string "points")
					(= type-string "count"))
				    (chain change (set-block "member") (wrap-block type-string)))
				   ((= type-string "quote")
				    (if is-member
					(chain change (set-block "section")
					       (unwrap-block "points") (unwrap-block "count")
					       (wrap-block type-string))
					(chain change (set-block "section") (wrap-block type-string))))
				   (t (if is-member
					  (chain change (set-block type-string) (unwrap-block "quote")
						 (unwrap-block "points") (unwrap-block "count"))
					  (chain change (set-block type-string)))))))
       (chain self (set-state (create content (@ value-container value))))))
   :modulate-methods
   (lambda (methods)
     (let* ((self this)
	    (to-grow (if (@ self props context working-system)
			 (chain methods (in-context-grow (@ self props context working-system)))
			 (@ methods grow))))
       (chain j-query
   	      (extend (create set-delta (lambda (value) (extend-state point-attrs (create delta value))))
   		      methods (create grow-branch (lambda (space meta callback)
						    (to-grow (@ self state data id)
							     space meta callback)))))))
   :set-confirmed-value
   (lambda (value)
     (chain this (set-state (create confirmed-value value))))
   :move
   (lambda (motion)
     (cl :mo motion))
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
      ((move (chain self (move (@ params vector))))
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
		   (progn (chain self state context methods (set-mode "write"))
			  (cl :eee)
			  (chain self (set-state (create read-only false))))))))
       (trigger-secondary
       	(if (not (= true (@ next-props data meta locked)))
	    (progn (chain self state context methods (set-mode "write"))
		   (chain self editor-instance (focus))
		   (chain self (set-state (create read-only false))))))
       (trigger-anti
	(chain self (set-state (create read-only t)))
     	(chain self state context methods (set-mode "move")))
       (commit
     	(if (not (= true (@ next-props data meta locked)))
     	    (chain self state context methods (grow-branch (chain -j-s-o-n
								  (stringify (chain self editor-instance
										    state value (to-j-s-o-n))))
     							   (create save true)))))
       )))
   :component-did-update
   (lambda ()
     (if (and (= "set" (@ this state context mode))
	      (@ this state context is-point))
	 (chain (j-query (+ "#sheet-view-" (@ this props data id) 
			    " .atom.mode-set.point .editor input")) 
		(focus))))
   :render-node
   (lambda (props)
     (let ((node-type (@ props node type))
	   (children (@ props children)))
       (cond ((= node-type "quote")
	      (panic:jsl (:div :class-name "node-holder blockquote"
			       (:div :class-name "glyph")
			       (:blockquote :class-name "node blockquote" children))))
	     ((= node-type "points")
	      (panic:jsl (:div :class-name "node-holder points"
			       (:div :class-name "glyph")
			       (:ul :class-name "node points" children))))
	     ((= node-type "count")
	      (panic:jsl (:div :class-name "node-holder count"
			       (:div :class-name "glyph")
			       (:ol :class-name "node count" children))))
	     ((= node-type "member")
	      (panic:jsl (:li :class-name "node member" children)))
	     ((= node-type "section")
	      (panic:jsl (:div :class-name "node member" children)))
	     (t (panic:jsl (:div :class-name "node-holder p"
				 (:div :class-name "glyph")
				 (:div :class-name "node p" children)))))))
   :render-mark
   (lambda (props)
     (let ((mark-type (@ props mark type))
	   (children (@ props children)))
       (cond ((= mark-type "bold")
	      (panic:jsl (:strong children)))
	     ((= mark-type "italic")
	      (panic:jsl (:em children))))))
   )
  (defvar self this)
  (panic:jsl (:div :class-name "document-pane-outer"
		   (:-slate-editor :value (@ self state content)
				   :on-change (lambda (value)
						(chain self (set-state (create content (@ value value)))))
				   :ref (lambda (ref) (if (not (@ self editor-instance))
							  (setf (@ self editor-instance) ref)))
				   :render-node (@ self render-node)
				   :render-mark (@ self render-mark)
				   ;; :on-focus (lambda (value)
				   ;; 		 (chain self state context methods (set-mode "write")))
				   ;; :on-blur (lambda (value)
				   ;; 		;;(chain console (log :bb value))
				   ;; 		(chain self state context methods (set-mode "move")))
				   :read-only (@ self state read-only)
				   :class-name "slate-editor-pane")
		   (:div :class-name "status-bar"
			 (if (= "move" (@ self state context mode))
			     "navigate" "edit"))))))
