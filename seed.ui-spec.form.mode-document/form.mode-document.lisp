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
       ;;(cl :val1 (@ this props data data) initial-value)
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
       state))
   :element-specs #()
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
		   (progn (chain self state context methods (set-mode "write"))
			  (cl :eee)
			  (chain self (set-state (create read-only false))))))))
       (trigger-secondary
       	(if (not (= true (@ next-props data meta locked)))
	    (progn (chain self state context methods (set-mode "write"))
		   (chain self editor-instance (focus))
		   (chain self (set-state (create read-only false)))))
	)
       (trigger-anti
	;; (chain self (set-state (create read-only t)))
     	;; (chain self state context methods (set-mode "move"))
	(chain self state content (change)
	       (toggle-mark "myMark"))
	(cl 909))
       (commit
     	(if (not (= true (@ next-props data meta locked)))
     	    (chain self state context methods (grow-branch (chain -j-s-o-n
								  (stringify (chain self editor-instance
										    state value (to-j-s-o-n))))
     							   (create save true)))))
       ))
     )
   ;; :should-component-update
   ;; (lambda (next-props next-state)
   ;;   (or (not (@ next-state context current))
   ;; 	 (not (= (@ next-state context mode)
   ;; 		 (@ this state context mode)))
   ;; 	 (@ next-state action-registered)))
   :component-did-update
   (lambda ()
     (if (and (= "set" (@ this state context mode))
	      (@ this state context is-point))
	 (chain (j-query (+ "#sheet-view-" (@ this props data id) 
			    " .atom.mode-set.point .editor input")) 
		(focus))))
   :render-node
   (lambda (props)
     (cl :nprop props))
   :render-mark
   (lambda (props)
     (cl :prop props))
   )
  (defvar self this)
  ;; (cl :ac (@ self props action) (@ self state read-only) (@ self editor-instance)
  ;;     (@ self props) (@ self state space) (@ self state content))
  (panic:jsl (:div :class-name "document-pane-outer"
		   (:-slate-editor :value (@ self state content)
				   :on-change (lambda (value)
						(chain self (set-state (create content (@ value value)))))
				   :ref (lambda (ref) (if (not (@ self editor-instance))
							  (setf (@ self editor-instance) ref)))
				   ;; :render-node (@ self render-node)
				   ;; :render-mark (@ self render-mark)
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
