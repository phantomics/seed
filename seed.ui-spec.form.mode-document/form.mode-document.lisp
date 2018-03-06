;;;; seed.ui-spec.form.mode-document.lisp

(in-package #:seed.ui-model.react)

(specify-components
 document-view-mode
 (document-view
  (:get-initial-state
   (lambda ()
     (let ((initial-value
	    (chain -slate-value
		   (from-j-s-o-n (create document
					 (create nodes
						 (list (create object "block"
							       kind "block"
							       type "paragraph"
							       nodes (list (create object "text"
										   kind "text"
										   leaves
										   (list
										    (create text
											    "Line."))))))))))))
     (chain j-query (extend (create point #(0 0)
				    content initial-value
				    point-attrs (create value nil delta nil)
				    meta (chain j-query (extend t (create max-depth 0
									  confirmed-value nil
									  invert-axis (list false true))
								(@ this props data meta))))
			    (chain this (initialize (@ this props)))))))
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
   :component-did-update
   (lambda ()
     (if (and (= "set" (@ this state context mode))
	      (@ this state context is-point))
	 (chain (j-query (+ "#sheet-view-" (@ this props data id) 
			    " .atom.mode-set.point .editor input")) 
		(focus))))
   )
  (defvar self this)
  ;(cl "SHR" (@ this state just-updated))
  ;;(chain console (log :abc (@ self state data) -slate-editor -slate-value))
  ;(chain console (log :ssp (@ self state space)))
  ;;(let ((-data-sheet (new -react-data-sheet)))
  ;; (chain console (log :cc (@ self props action) (@ self state context mode)
  ;; 		      (@ self state context)))
  (panic:jsl (:-slate-editor :value (@ self state content)
			     :on-change (lambda (value)
					  (chain self (set-state (create content (@ value value)))))
			     ;; :on-focus (lambda (value)
			     ;; 		 (chain self state context methods (set-mode "write")))
			     ;; :on-blur (lambda (value)
			     ;; 		;;(chain console (log :bb value))
			     ;; 		(chain self state context methods (set-mode "move")))
			     :style (create height "100%" padding "4px 6px" color "#002b36")))))
