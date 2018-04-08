;;;; form.mode-text.lisp

(in-package #:seed.ui-model.react)

(defpsmacro cl (&rest items)
  `(chain console (log ,@items)))

(specify-components
 text-view-mode
 (text-view
  (:get-initial-state
   (lambda ()
     (chain j-query (extend (create point #(0 0)
				    point-attrs (create value nil delta nil)
				    meta (chain j-query (extend t (create max-depth 0
									  confirmed-value nil
									  invert-axis (list false true))
								(@ this props data meta)))
				    read-only t)
			    (chain this (initialize (@ this props))))))
   :initialize
   (lambda (props)
     (let* ((self this)
	    (state (funcall inherit self props
			    (lambda (d) (chain j-query (extend (@ props data) (@ d data))))
			    (lambda (pd) (@ pd data data)))))
       ;; (if (@ self props context trace-category)
       ;; 	   (chain self props context methods (register-branch-path (@ self props context trace-category)
       ;; 								   (@ self props data id)
       ;; 								   (@ state context path))))
       (if (@ self props context set-interaction)
	   (progn (chain self props context
			 (set-interaction "commit" (lambda () (chain self state context methods
								     (grow-branch (chain self editor-instance
											 code-mirror doc
											 (get-value))
										  (create save true))))))
		  (chain self props context
			 (set-interaction "revert" (lambda () (chain self state context methods
								     (grow-branch (chain self editor-instance
											 code-mirror doc
											 (get-value))
										  (create revert true)))
							   (chain self editor-instance code-mirror doc
								  (set-value (@ self props data data))))))))
       state))
   :element-specs #()
   :editor-instance nil
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
   ;; :set-confirmed-value
   ;; (lambda (value)
   ;;   (chain this (set-state (create confirmed-value value))))
   :component-will-receive-props
   (lambda (next-props)
     (defvar self this)

     (let ((new-state (chain this (initialize next-props))))
       ;;(cl :news new-state)
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
       	(if (@ params vector 0)
	    (chain self editor-instance code-mirror (exec-command (if (= -1 (@ params vector 0))
								      "goCharLeft" "goCharRight"))))
	(if (@ params vector 1)
	    (chain self editor-instance code-mirror (exec-command (if (= -1 (@ params vector 1))
								      "goLineDown" "goLineUp")))))
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
	       (chain self editor-instance (focus))
	       (chain self state context methods (set-mode "write"))
	       (chain self (set-state (create read-only false)))
       	       (chain self editor-instance code-mirror (set-option "readOnly" false)))))
       (insert-char
	(chain self editor-instance code-mirror doc
	       (replace-range (@ params char)
			      (chain self editor-instance code-mirror doc (get-cursor))))
	false)
       (trigger-secondary
       	(chain self editor-instance (focus))
       	(chain self state context methods (set-mode "write"))
	(chain self (set-state (create read-only false)))
	(chain self editor-instance code-mirror (set-option "readOnly" false)))
       (trigger-anti
     	(chain self state context methods (set-mode "move"))
	(chain self (set-state (create read-only t))))
       (commit
     	(if (not (= true (@ next-props data meta locked)))
     	    (chain self state context methods (grow-branch (chain self editor-instance code-mirror doc (get-value))
     							   (create save true)))))))
     )
   :should-component-update
   (lambda (next-props next-state)
     (or (not (@ next-state context current))
	 (not (= (@ next-state context mode)
		 (@ this state context mode)))
	 ;;(@ next-state action-registered)
	 ))
   ;; :component-did-update
   ;; (lambda ()
   ;;   (if (and (= "set" (@ this state context mode))
   ;; 	      (@ this state context is-point))
   ;; 	 (chain (j-query (+ "#sheet-view-" (@ this props data id)
   ;; 			    " .atom.mode-set.point .editor input"))
   ;; 		(focus))))
   )
  (let ((self this))
    ;;(cl "SHR" (@ this state just-updated))
    ;; (chain console (log :cel (@ self state data) (@ self props context) (@ self state context)))
    ;;(chain console (log :ssp (@ self state space)))
    ;;(let ((-data-sheet (new -react-data-sheet)))
    ;;(chain console (log :dd (@ self props context)))
    ;;(cl 990 (@ self state context))
    (panic:jsl (:div :class-name "text-pane-outer"
		     (:-code-mirror :value (@ self state data data)
				    :ref (lambda (ref) (if (not (@ self editor-instance))
							   (setf (@ self editor-instance) ref)))
				    ;; :on-focus-change (lambda (in-focus)
				    ;; 		       (cl :ed (@ self editor-instance))
				    ;; 		       (chain self state context methods
				    ;; 			      (set-mode (if in-focus "write" "move"))))
				    :options (create theme "solarized light" key-map "basic"
						     line-wrapping t line-numbers t
						     read-only (@ self state read-only)))
		     (:div :class-name "status-bar"
			   (if (= "move" (@ self state context mode))
			       "navigate" "edit")))))))
