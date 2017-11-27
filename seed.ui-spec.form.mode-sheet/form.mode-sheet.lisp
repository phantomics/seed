;;;; seed.ui-spec.form.mode-sheet.lisp

(in-package #:seed.ui-model.react)

(specify-components
 sheet-view-mode
 (sheet-view
  (:get-initial-state
   (lambda ()
     (chain j-query (extend (create point #(0 0)
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
   :modulate-methods
   (lambda (methods)
     (let ((self this))
       (chain j-query
	      (extend (create set-delta (lambda (value) (extend-state point-attrs (create delta value))))
		      methods
		      (create grow-point
			      (lambda (data meta alternate-branch)
				(let ((new-space (chain j-query (extend t #() (@ self state space)))))
				  ;(cl :as data new-space)
				  (chain self (assign data new-space)))
				(chain methods
				       (grow (if (= "undefined" (typeof alternate-branch))
						 (@ self state data id)
						 alternate-branch)
					     ;; TODO: it may be desirable to add certain metadata to
					     ;; the meta for each grow request, that's what the
					     ;; derive-metadata function below may later be used for
					     new-space meta)))
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
   :build-sheet-cells
   (lambda (data)
     (let ((self this)
	   (cells #())
	   (this-row #())
	   (row-index 0))
       (loop for row from 0 to (1- (@ data length))
	  do (funcall
	      (lambda (row-index)
		(setq this-row (list (panic:jsl (:th :key (+ "row-label-" row)
						     (1+ row)))))
		(loop for col from 0 to (1- (@ (getprop data row) length))
		   do (let ((cell-click (lambda () (chain self (set-state (create point (list col row))))))
			    (is-point (and (= (@ self state point 1) row)
					   (= (@ self state point 0) col))))
			(chain this-row
			       (push (panic:jsl (:td :key (+ "cell-" col "-" row)
						     :on-click cell-click
						     :ref 
						     (lambda (ref)
						       (let ((element (j-query ref)))
							 (if (= "undefined"
								(typeof (getprop self "elementSpecs" row)))
							     (setf (getprop self "elementSpecs" row) #()))
							 (if (not (= "undefined" (typeof (@ element 0))))
							     (setf (getprop self "elementSpecs" row col)
								   (create left (@ element 0 offset-left)
									   top (@ element 0 offset-top)
									   width (@ element 0 client-width)
									   height (@ element 0 client-height))))))
						     :class-name (+ "atom"
								    (+ " mode-" (@ self state context mode))
								    (if is-point " point" ""))
						     (if is-point (panic:jsl (:div :class-name "point-marker")))
						     (subcomponent (@ interface-units cell-spreadsheet)
								   (create content (getprop data row col)
									   meta (create is-point is-point
											is-parent-point
											(@ self state context 
												is-point)))))))))))
	      row)
	    (chain cells (push (panic:jsl (:tr :key (+ "row-" row)
					       this-row)))))
       cells))
   :move
   (lambda (motion)
     (let* ((self this)
	    (mo (chain motion (map (lambda (axis index)
				     (* axis (if (getprop (@ self state meta invert-axis) index)
						 -1 1))))))
	    (new-point (list (if (< -1 (+ (@ mo 0) (@ this state point 0))
				    (@ this state space 0 length))
				 (+ (@ mo 0) (@ this state point 0))
				 (@ this state point 0))
			     (if (< -1 (+ (@ mo 1) (@ this state point 1))
				    (@ this state space length))
				 (+ (@ mo 1) (@ this state point 1))
				 (@ this state point 0)))))
       ;; adjust scroll position of pane if cursor is moved out of view
       (if (and (not (= "undefined" (typeof (@ self state pane-element))))
		(< 0 (@ self element-specs length)))
	   (progn (if (< (+ (@ self state pane-element 0 client-height)
			    (@ self state pane-element 0 scroll-top))
			 (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top"))
		      (setf (@ self state pane-element 0 scroll-top)
			    (+ (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top")
			       (/ (@ self state pane-element 0 client-height) 2)))
		      (if (> (@ self state pane-element 0 scroll-top)
			     (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top"))
			  (setf (@ self state pane-element 0 scroll-top)
				(- (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "top")
				   (/ (@ self state pane-element 0 client-height) 2)))))
		  (if (< (+ (@ self state pane-element 0 client-width)
			    (@ self state pane-element 0 scroll-left))
			 (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left"))
		      (setf (@ self state pane-element 0 scroll-left)
			    (+ (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left")
			       (/ (@ self state pane-element 0 client-height) 2)))
		      (if (> (@ self state pane-element 0 scroll-left)
			     (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left"))
			  (setf (@ self state pane-element 0 scroll-left)
				(- (getprop (@ self element-specs) (@ new-point 1) (@ new-point 0) "left")
				   (/ (@ self state pane-element 0 client-width) 2)))))))
       (chain this (set-state (create point new-point)))))
   :assign
   (lambda (value matrix)
     (let* ((x (@ this state point 0))
	    (y (@ this state point 1))
	    (original-value (getprop matrix y x)))
       (setf (getprop matrix y x)
	     (if (= "[object Array]" (chain -object prototype to-string (call original-value)))
		 (if (not (null value))
		     ;; assign the unknown type for now;
		     ;; an accurate type will be assigned server-side
		     (create type "__unknown"
			     data-inp value))
		 (if (null value)
		     (list)
		     (chain j-query (extend (create) original-value
					    (create data-inp-ovr value))))))
       matrix))
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
      :actions-point-and-focus
      ((move
	(chain self (move (@ params vector))))
       (delete-point
	(if (not (= true (@ next-props data meta locked)))
	    (chain self state context methods (grow-point nil (create)))))
       (record
	(if (@ self props context clipboard-id)
	    (chain self state context methods (grow-point (create)
							  (create vector (@ params vector)
								  point (@ self state point)
								  branch (@ self state data id))
							  (@ self props context clipboard-id)))))
       (recall
	(if (and (@ self props context history-id)
		 (not (= true (@ next-props data meta locked))))
	    (chain self state context methods (grow-point (create)
							  (create vector (@ params vector)
								  "recall-branch" (@ self state data id))
							  (@ self props context history-id)))))
       (trigger-primary
	(cond ((= "move" (@ self state context mode))
	       (if (not (= true (@ next-props data meta locked)))
		   (chain self state context methods (set-mode "set"))))
	      ((= "set" (@ self props context mode))
	       (progn (chain self (set-state (create action-registered nil)))
		      (chain self state context methods (grow-point (@ self state point-attrs delta)
								    (create)))
		      (chain self state context methods (set-mode "move"))))))
       (trigger-secondary
	(if (not (= true (@ next-props data meta locked)))
	    (chain self state context methods (set-mode "set"))))
       (trigger-anti
	(chain self state context methods (set-mode "move")))
       (commit
	(if (not (= true (@ next-props data meta locked)))
	    (chain self state context methods (grow-branch (@ self state space)
							   (create save true))))))))
   :should-component-update
   (lambda (next-props next-state)
     (or (not (@ next-state context current))
	 (not (= (@ next-state context mode)
		 (@ this state context mode)))
	 (@ next-state action-registered)))
   :component-did-update
   (lambda ()
     (if (and (= "set" (@ this state context mode))
	      (@ this state context is-point))
	 (chain (j-query (+ "#sheet-view-" 
			    (@ this props data id) 
			    " .atom.mode-set.point .editor input")) 
		(focus))))
   ;; :render-space
   ;; (lambda ()
   ;;   (let* ((self this)
   ;; 	    (space (chain j-query (extend (list) (@ self state space)))))
   ;;     (chain space (unshift (loop for index from 0 to (1- (@ space 0 length))
   ;; 				collect (create data-inp (chain -string (from-char-code (+ 65 index)))))))
   ;;     (setq space (chain space (map (lambda (row rix)
   ;; 				       (chain row (map (lambda (cell cix)
   ;; 							 (create value cell
   ;; 								 component; (@ self cell-component)
   ;; 								 (panic:jsl
   ;; 								  (:div :class-name "cc"
   ;; 									(subcomponent (@ interface-units
   ;; 											 cell-spreadsheet)
   ;; 										      (create content cell
   ;; 											      meta 
   ;; 											      (create 
   ;; 											       is-point
   ;; 											       false
   ;; 											       is-parent-point
   ;; 											       (@ self 
   ;; 												  state 
   ;; 												  context 
   ;; 												  is-point))))))
   ;; 								 force-component t
   ;; 								 width 180))))))))
   ;;     space))
   )
  (defvar self this)
  ;(cl "SHR" (@ this state just-updated))
  ;(cl :cel (@ self state data) (@ self props context) (@ self state context))
  ;(chain console (log :ssp (@ self state space)))
  (let ((-data-sheet (new -react-data-sheet)))
    (panic:jsl (:div :class-name "matrix-view spreadsheet-view"
		     :id (+ "sheet-view-" (@ this state data id))
		     (:table :class-name "form"
			     :ref (+ "formSheet" (@ this state data id))
			     (:thead (:tr (chain self (build-sheet-heading (@ self state space)))))
			     (:tbody (chain self (build-sheet-cells (@ self state space))))))))))

;; (:-react-data-sheet :data (funcall (@ self render-space))
;; 		    :overflow "clip")
