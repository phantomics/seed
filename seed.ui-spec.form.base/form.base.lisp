;;;; seed.ui-spec.form.base.lisp

(in-package #:seed.ui-model.react)

(specify-components
 form-view-mode
 (form-view
  (:get-initial-state
   (lambda ()
     (cl :props (@ this props))
     (chain j-query (extend (create point (if (= "full" (@ this props context view-scope))
					      #(0 0) #(0))
				    point-attrs (create index 0 value nil delta nil start 0 fresh t
							depth 0 breadth 1 path #() props #())
				    point-data nil
				    index -1
				    focus (create meta 0 macro 0)
				    ;; TODO: glyphs are only assigned here
				    meta (chain j-query (extend t (create)
								(@ this props data meta)
								(create max-depth 0
									confirmed-value nil))))
			    (chain this (initialize (@ this props))))))
   :element-specs #()
   :root-params (create)
   :initialize
   (lambda (props)
     (let* ((self this)
	    (state (funcall inherit self props
			    (lambda (d) (chain j-query (extend t (create) (@ d data) (@ props data))))
			    (lambda (pd) (@ pd data data)))))
       ;; (if (and (@ props data meta)
       ;; 	       (@ self state)
       ;; 	       (@ self state point-attrs)
       ;; 	       (not (= "undefined" (typeof (@ props data meta point-to))))
       ;; 	       (not (= "full" (@ props context view-scope))))
       ;; 	  (setf (@ state point-attrs)
       ;; 		(chain j-query (extend (@ self state point-attrs)
       ;; 				       (create index (@ props data meta point-to))))))
       ;; TODO: copy of point-to was eliminated here to prevent paradoxes; see if it's not needed
       ;; (cl 15 (@ props data data))
       (if (@ self props context set-interaction)
	   (progn (chain self props context
			 (set-interaction "commit" (lambda () (chain self state context methods
								     (grow #() (create save true))))))
		  (chain self props context
			 (set-interaction "revert" (lambda () (chain self state context methods
								     (grow #() (create revert true))))))))
       (if (@ self props context trace-category)
	   (chain self props context methods (register-branch-path (@ self props context trace-category)
								   (@ self props data id)
								   (@ state context path))))
       state))
   :modulate-methods
   (lambda (methods)
     (let* ((self this)
	    (to-grow (if (@ self props context parent-system)
			 (chain methods (in-context-grow (@ self props context parent-system)))
			 (@ methods grow))))
       (chain j-query
	      (extend (create set-delta (lambda (value) (extend-state point-attrs (create delta value)))
			      set-point (lambda (datum) (chain self (set-point (list (@ datum ly) (@ datum ct)))))
			      sort (lambda (point new-index)
				     ;; NOTE: This function changes the state data in place as opposed to creating
				     ;; a copy and feeding it to the grow function. The creation of the new copy
				     ;; results in a cyclic reference in the JSON structure. Is this a problem?
				     (chain self (seek point (@ point 0) (@ self state space)
						       (lambda (target target-list target-parent target-index path)
							 (let ((from nil)
							       (to nil))
							   (loop for index from 1 to (1- (@ target-parent length))
							      do (if (= (getprop target-parent index 0 "ct")
									(@ point 1))
								     (setq from index)
								     (if (= (getprop target-parent index 0 "ix")
									    (@ new-index ix))
									 (setq to index))))
							   (chain target-parent 0
								  (md (lambda (data)
									(chain data
									       (splice to 0
										       (@ (chain data
												 (splice from 1)
												 0))))
									data)))
							   (chain self state context methods (grow)))))))
			      delete-point (lambda (point) (chain self (delete-point point))))
		      methods
		      (create grow
			      (lambda (data meta alternate-branch)
				(let ((space (let ((new-space (chain j-query (extend #() (@ self state space)))))
					       (chain self (assign (@ self state point-attrs index)
								   new-space data)))))
				  (to-grow (if (= "undefined" (typeof alternate-branch))
				  	       (@ self state data id)
				  	       alternate-branch)
				  	   ;; TODO: it may be desirable to add certain metadata to
				  	   ;; the meta for each grow request, that's what the
				  	   ;; derive-metadata function below may later be used for
				  	   space meta)))
			      grow-branch
			      (lambda (space meta callback)
				(to-grow (@ self state data id) 
					 space meta callback)))))))
   ;; :derive-metadata
   ;; (lambda ()
   ;;   (let ((self this))
   ;;     (create point-to (if (@ self state point-attrs)
   ;; 			   (@ self state point-attrs path)))))
   ;; :grow-this-branch
   ;; (lambda (space)
   ;;   (chain this props context methods (grow (@ this state data id)
   ;; 					    space (create meta (chain this (derive-metadata))))))
   :interactions
   (create select-system (create click (lambda (self datum)
					 (chain self (set-state (create index (@ datum ix))))
					 (chain self (set-point datum))
					 (funcall (@ self props context methods load-branch)
						  (@ datum vl)))
				 trigger-primary (lambda (self datum) 
						   (chain self (set-state (create index (@ datum ix))))
						   (funcall (@ self props context methods load-branch)
							    (@ datum vl)))
				 trigger-secondary (lambda (self datum) 
						     (chain self (set-state (create index (@ datum ix))))
						     (funcall (@ self props context methods load-branch)
							      (@ datum vl))))
	   ;;add-graph-node (create click (lambda (self datum) (cl :9080)))
	   select-branch (create click (lambda (self datum)
					 (chain self props context methods
						(set-branch-by-id (@ datum vl))))
				 trigger-primary (lambda (self datum)
						   (cl :tr)
						   (chain self props context methods
							  (set-branch-by-id (@ datum vl))))
				 trigger-secondary (lambda (self datum)
						     (chain self props context methods
							    (set-branch-by-id (@ datum vl)))))
	   ;; commit (create click (lambda (self datum)
	   ;; 			  (funcall (chain self props context (get-interaction "commit"))))
	   ;; 		  trigger-primary (lambda (self datum)
	   ;; 				    (funcall (chain self props context (get-interaction "commit"))))
	   ;; 		  trigger-secondary (lambda (self datum)
	   ;; 				      (funcall (chain self props context (get-interaction "commit")))))
	   revert (create click (lambda (self datum)
				  (funcall (chain self props context (get-interaction "revert"))))
			  trigger-primary (lambda (self datum)
					    (funcall (chain self props context (get-interaction "revert"))))
			  trigger-secondary (lambda (self datum)
					      (funcall (chain self props context (get-interaction "revert")))))
	   insert
	   (create
	    click (lambda (self datum)
		    (let* ((branch (@ self props context branch))
			   (new-space (chain j-query (extend #() (@ branch state space)))))
		      (chain branch (seek (@ branch state point) (@ branch state point 0) new-space
					  (lambda (target target-list target-parent target-index path)
					    ;(cl :form (@ datum mt format) target-parent)
					    ;(chain target-parent (splice target-index 0 (@ datum mt format)))
					    (setf (getprop target-parent target-index)
						  (@ datum mt format)))))
		      (chain branch state context methods (grow new-space))))
	    trigger-primary (lambda (self datum)
			      (let* ((branch (@ self props context branch))
				     (new-space (chain j-query (extend #() (@ branch state space)))))
				(chain branch (seek (@ branch state point) (@ branch state point 0) new-space
						    (lambda (target target-list target-parent target-index path)
				                      ;(cl :form (@ datum mt format) target-parent)
						      (setf (getprop target-parent target-index)
							    (@ datum mt format)))))
				(chain branch state context methods (grow new-space))))))
   :interact
   (lambda (datum alternative)
     (let ((self this))
       (if (and datum (@ datum pr) (@ datum pr meta)
		(@ datum pr meta mode) (@ datum pr meta mode interaction)
		(not (= "undefined" (typeof (getprop (@ self interactions)
						     (chain datum pr meta mode interaction (substr 2))))))
		(not (= "undefined" (typeof (getprop (@ self interactions)
						     (chain datum pr meta mode interaction (substr 2))
						     "triggerPrimary")))))
	   (funcall (getprop (@ self interactions) (chain datum pr meta mode interaction (substr 2))
			     "triggerPrimary")
		    self datum)
	   (funcall alternative))))
   :set-focus
   (lambda (key value)
     (let* ((self this)
	    (new-object (chain j-query (extend (create) (@ self state focus)))))
       (setf (getprop new-object key)
	     (min 1 (max 0 value)))
       (extend-state focus new-object)))
   :shift-focus
   (lambda (key vector)
     (let* ((self this)
	    (new-object (chain j-query (extend (create) (@ self state focus)))))
       (setf (getprop new-object key)
	     (min 1 (max 0 (+ (getprop (@ self state focus) key)
			      (@ vector 0)))))
       (extend-state focus new-object)))
   :set-point
   (lambda (target path)
     (let ((self this)
	   (path (if path path (list (@ target ly) (@ target ct)))))
       (if target ;; just in case a null target is passed, which shouldn't happen
	   (progn (chain self (set-state (create point (if (= 2 (@ self state point length))
					                   ;; assign the point depending on this form's
					                   ;; spatial dimensions
							   (list (@ target ly) (@ target ct))
							   (list (@ target ct)))
						 point-data target
						 action-registered t
					         ;; need to set this so that component updates
						 point-attrs
						 (chain j-query (extend (create)
									(@ self state point-attrs)
									(create index (@ target ix)
										fresh false
										props (chain j-query
											     (extend t (create)
												     (@ target pr)))
										value (if (@ target vl)
											  (@ target vl)
											  nil)
										path path
										start (@ target ct)
										atom-macros (if (@ target am)
												(@ target am)
												#())
										form-macros (if (@ target fm)
												(@ target fm)
												#())
										depth (@ target dp)
										is-atom (if (@ target br)
											    false t)
										breadth (if (@ target br)
											    (@ target br)
											    1)))))))
		  (if (and (not (= "undefined" (typeof (@ self state pane-element))))
			   (< 0 (@ self element-specs length)))
		      (progn (if (< (+ (@ self state pane-element 0 client-height)
				       (@ self state pane-element 0 scroll-top))
				    (getprop (@ self element-specs) (@ target ix) "top"))
				 (setf (@ self state pane-element 0 scroll-top)
				       (+ (getprop (@ self element-specs) (@ target ix) "top")
					  (/ (@ self state pane-element 0 client-height) 2)))
				 (if (> (@ self state pane-element 0 scroll-top)
					(getprop (@ self element-specs) (@ target ix) "top"))
				     (setf (@ self state pane-element 0 scroll-top)
					   (- (getprop (@ self element-specs) (@ target ix) "top")
					      (/ (@ self state pane-element 0 client-height) 2)))))))))))
   :move
   (lambda (motion)
     (let* ((self this)
	    (to-seek (@ this state point)))
       ;(cl :ss (@ self state point) (@ self state point-attrs))
       (if (= "full" (@ this props context view-scope))
	   (progn (setf (@ to-seek 0) (max 0 (if (= 0 (@ motion 0))
						 (@ self state point-attrs depth)
						 (if (< 0 (@ motion 0))
						     (+ (@ to-seek 0) (@ motion 0))
						     (+ (@ self state point 0) (@ motion 0))))))
		  (loop for mix from 0 to (1- (abs (@ motion 1)))
		     ;; axis is inverted, hence < instead of >
		     do (setf (@ to-seek 1) (max 0 (if (> 0 (@ motion 1))
						       (+ (@ self state point-attrs start)
							  (@ self state point-attrs breadth))
						       (1- (@ self state point-attrs start))))))
		  ;(cl :m0 (@ to-seek 0) (@ self state point-attrs depth) (@ self state point 0))
		  ;(cl :tos to-seek)
		  (chain self (seek to-seek (@ to-seek 0) nil
				    (lambda (target list parent index path)
				      (let ((new-target
					     (chain j-query
						    (extend (create)
							    target
							    (create dp (if (= 0 (@ motion 0))
									   (@ self state point-attrs depth)
									   (if (> 0 (@ motion 0))
									       (@ target ly)
									       (max (+ (@ motion 0)
										       (@ self state point-attrs
											       depth))
										    (@ target ly)))))))))
					;; extend the target data so that the layer is set as the sought
					;; x-coordinate as long as the point is moving vertically or inward. x
					;; thus, the layer will remain the same when moving vertically,
					;; preventing it from being knocked down to a low level when
					;; traversing shallow lists, and the point will always decrement
					;; to the layer previous to the visible point. x
					(chain self (set-point new-target path)))))))
	   (let ((target-index (+ (getprop (@ self state point) (1- (@ self state point length)))
				  (- (@ motion 1)))))
				  ;; don't seek if the target index is less than 0
				  ;; this is impossible and causes an infinite loop
	     (if (<= 0 target-index)
		 (chain self (seek (list target-index)
				   -1 nil (lambda (target list parent index path)
					    (chain self (set-point target path))))))))))
   :seek
   (lambda (coords layer form callback path)
     (let ((self this) 
	   (path (if path path #()))
	   (form (if form form (chain this state space (slice 1))))
	   (index (getprop coords (1- (@ coords length))))
	   (found-form nil) (member-start 0) (form-index 0) (at-end false) (this-end false))
       ;; don't seek if there's nothing in the form
       (if (not (= "undefined" (typeof (@ form 0))))
	   (progn
	     (loop for fix from 0 to (1- (@ form length))
		do (if (= "[object Array]" (chain -object prototype to-string (call (getprop form fix))))
		       (setq member-start (getprop form fix 0 "ct")
			     this-end false)
		       (setq member-start (getprop form fix "ct")
			     this-end true))
		  ;(cl 312 index member-start (getprop form fix) (not (> member-start index)))
		  ;; (if (@ self props context ii) (cl :fl (getprop form fix) (getprop form fix "ct") 
		  ;; 				   member-start index))
		  (if (not (> member-start index))
		      (setq found-form (getprop form fix)
			    at-end this-end
			    form-index fix)))
	     ;(cl :ff coords found-form index form-index (not at-end) (= -1 layer) (< 0 layer))
	     (chain path (push (- form-index (if (and (not (= "undefined" (typeof (@ form 0 ty))))
						      (= "plain" (@ form 0 ty 0)))
						 1 0))))
	     (if (and (not at-end)
		      (not (= 0 layer)))
		 ;; if the layer > 0, this is a 2D form and there may be more layers below this one
		 ;; if the layer < 0, this is a 1D form with a starting layer of -1
		 (chain this (seek coords (1- layer) found-form callback path))
		 (if found-form
		     (funcall callback
			      (if (= "[object Array]" (chain -object prototype to-string (call found-form)))
				  (@ found-form 0)
				  found-form)
			      (if (= "[object Array]" (chain -object prototype to-string (call found-form)))
				  found-form)
			      form form-index path)))))))
   :delete-point
   (lambda (point)
     (let* ((self this)
	    (new-space (chain j-query (extend #() (@ self state space)))))
       (chain self (seek point (@ point 0)
			 new-space 
			 (lambda (target target-list target-parent target-index path)
			   (chain target-parent (splice target-index 1))
			   (if (not (> (@ point 1) (@ self state point 1)))
			       (chain self (move #(0 1)))))))
       (chain self state context methods (grow-branch new-space (create)))))
   :set-confirmed-value
   (lambda (value) (extend-state data (create confirmed-value value)))
   :assign
   (lambda (index form changed)
     ;; TODO: the property and sub-property system is convoluted, try to simplify it...
     (loop for fix from 0 to (1- (@ form length))
	do ;; (cl :fff form fix)
	  (if (= "[object Array]" (chain -object prototype to-string (call (getprop form fix))))
	       (chain this (assign index (getprop form fix) changed))
	       (if (= index (@ (getprop form fix) ix))
		   (setf (getprop form fix)
			 (chain j-query (extend (getprop form fix) changed))))))
     form)
   :build
   (lambda (state)
     (let* ((self this)
	    (new-space (chain j-query (extend #() (@ state space)))))
       ;; the element-specs are set to nil whenever the table is rebuilt
       ;; so that new coordinates may be sent to the glyph-drawing component
       (setf (@ self element-specs) #())
       ;; (cl :newspace new-space)
       (chain self
	      (build-form new-space
			  (lambda (meta state)
			    (chain self (set-state (chain j-query
							  (extend state
								  (create space new-space
									  rendered-content (@ meta output)
									  point-attrs (@ state point-attrs)
									  meta (chain
										j-query
										(extend t (create)
											(@ self state data meta)
											meta))))))))))))
   :build-form
   (lambda (data callback meta state)
     (let ((self this)
	   (each-meta (create))
	   (is-start (= "undefined" (typeof meta)))
	   ;; is this the beginning of the form?
	   (meta (if meta meta (create succession #() max-depth 0 output #())))
	   (state (if state state (create row 0 column 0)))
	   (last-index nil)
	   (context-begins false)
	   (meta-mode-active false)
	   (is-plain-list (= "plain" (@ data 0 ty 0)))
	   (increment-breadth (lambda (number) (setf (@ data 0 br) (+ (if (or number (= 0 number))
									  number 1)
								      (@ data 0 br))))))
       (if (@ data 0)
	   (progn (setf (@ data 0 br) 0)
		  ;; breadth is initially 0, as is the list of sub-lists
		  (if (and (@ data 0 fm) (< 0 (@ data 0 fm length)))
		      (setf (@ state reader-context) (chain data 0 fm)
			    (@ meta context-start) (@ data 0 ix)
			    context-begins true))
		  ;; handle reader macros for forms
		  (if (and (@ data 0 am) (< 0 (@ data 0 am length)))
		      (setf (@ state reader-context) (@ data 0 am)
			    (@ meta context-start) (@ data 0 ix)
			    context-begins true))
		  ;; handle reader macros for atoms
		  (if (@ data 0 mt)
		      (progn (setf (@ data 0 pr) (create meta (@ data 0 mt)))
			     (if (@ data 0 mt mode)
				 (setf (@ data 0 md) (lambda (fn) (setf data (funcall fn data)))
				       (@ data 0 pr count) (1- (@ data length))))
			     (if (@ data 0 mt each)
				 (setf each-meta (@ data 0 mt each)
				       (@ data 0 pr meta) (chain j-query (extend t (create)
										 (@ data 0 mt each)
										 (@ data 0 pr meta)))))))
		  ;; (cl :data (@ data 0) each-meta)
		  ;; assign atom properties from metadata
		  (setf (@ data 0 ct) (@ state row)
			(@ data 0 ly) (max 0 (1- (@ state column)))
			(@ data 0 cx) (if context-begins
					  (chain state reader-context (concat (list "start")))
					  (@ state reader-context)))
		  ;; assign column, row and reader macro content
		  ;; (if (@ data 0 mt)
		  ;;     (cl :iio data))
		  (chain data
			 (map (lambda (datum index)
				;; (if (@ each-meta visible-members)
				;;     (cl :atom (@ datum mt) each-meta))
				;; if the atom is set to be invisible, do not process it for display
				(if (or (not (@ each-meta visible-members))
					(not (@ datum mt name))
					(let ((visible t))
					  (loop for member in (@ each-meta visible-members)
					     do (if (= (@ datum mt name) (@ member name))
						    (setq visible (and visible (= "__on" (@ member state))))))
					  visible))
				    (progn
				      (if (and (= 1 index)
					       (not is-plain-list))
					  (setf (@ state column) (1+ (@ state column))))
				      ;; increment the column, but not for plain lists
				      (if (> (1+ (@ state column))
					     (@ meta max-depth))
					  (setf (@ meta max-depth) (1+ (@ state column))))
				      ;; increment the maximum depth
				      (if (= "[object Array]" (chain -object prototype to-string (call datum)))
					  ;; if this item is a list
					  (progn (if (and (or (and is-plain-list (< 0 index))
							      ;; start incrementing right away in plain lists,
							      ;; like the main form list
							      (< 1 index))
							  (not (and is-plain-list (= 1 index))))
						     (setf (@ state row) (1+ (@ state row))))
						 ;; increment the row, but not if this is the form at the beginning of
						 ;; a plain list and this is not the plain list that encloses the
						 ;; whole form; i.e. isStart is not true
						 (if (or last-index (= 0 last-index))
						     (setf (getprop meta "succession" last-index)
							   (@ datum 0 ix)))
						 (setf last-index (@ datum 0 ix))
						 ;; set succession data for drawing glyphs
						 (chain self (build-form
							      datum (lambda (output sub-state)
								      (increment-breadth (1+ (- (@ sub-state row)
												(@ state row))))
								      ;; increment the breadth based on the difference
								      ;; between the current row and the row reached
								      ;; within the sub-list
								      (setf (@ state row) (+ (@ sub-state row))))
							      meta (chain j-query (extend (create)
											  state (if is-plain-list
												    (create)
												    (create)))))))
					  ;; if this item is an atom
					  (let ((pr (chain j-query (extend t (create)
									   (create meta (chain j-query 
											       (extend t (create)
												       each-meta
												       (@ datum mt))))
									   (@ datum pr)))))
					    (if (< 0 index)
						(progn (if (or last-index (= 0 last-index))
							   (setf (getprop meta "succession" last-index)
								 (@ datum ix)))
						       (setf last-index (@ datum ix))))
					    (if (< 0 index) (increment-breadth))
					    (if (or (and is-plain-list (< 0 index))
						    (< 1 index))
						(setf (@ state row) (1+ (@ state row))))
					    (setf (@ datum ct) (@ state row)
						  (@ datum ly) (@ state column)
						  (@ datum pr) pr
						  ;; concatenate macro styles if the atom
						  ;; is within an existing macro
						  (@ datum cx) (if (@ datum am)
								   (if (@ state reader-context)
								       (chain state reader-context
									      (concat (list (@ datum am) "start")))
								       (list (@ datum am) "start"))
								   (@ state reader-context)))
					    ;; increment the column if the list head is a plain list marker
					    ;; and this is not the plain list that encloses the form;
					    ;; this ensures that the elements within the plain list will have
					    ;; their layers correctly marked. x
					    (if (and (not is-start)
						     (= "plain" (@ datum ty 0)))
						(setf (@ state column) (1+ (@ state column))))
					    ;; push datum to output array; the index is incremented because
					    ;; the indices start with 0 but the array indices start with 1
					    (if (= "undefined" (typeof (getprop meta "output" (@ state row))))
						(setf (getprop meta "output" (@ state row))
						      #()))
					    (chain (getprop meta "output" (@ state row))
						   (push datum)))))
				    (progn (setf (@ datum hide) t))))))
			      
		  (funcall callback meta state)))))
   :build-list
   (lambda (data atom-builder form-builder callback output)
     (let ((self this)
	   (datum (@ data 0))
	   (output (if output output #())))
       (if (= 0 (@ data length))
	   (funcall callback output)
	   (chain self
		  (build-list (chain data (slice 1))
			      atom-builder form-builder callback
			      (chain output (concat (funcall (if (= "[object Array]"
								    (chain -object prototype to-string
									   (call datum)))
								 form-builder atom-builder)
							     datum 
							     (- (@ output length)
								(if (and (@ output 0)
									 (= "plain" (@ output 0 0 ty 0)))
								    1 0))
							     (@ output 0)))))))))
   :render-atom
   (lambda (datum)
     (defvar self this)
     (panic:jsl (:div :key (+ "form-view-td-" (@ datum ix))
		      :on-click (lambda ()
				  ;; if this cell does not have a custom interface, set it as point
				  ;; when clicked, cells with custom interfaces have unique behaviors
				  ;; implemented using the set-point method as passed through
				  ;; the modulate-methods function in this component
				  (let ((interaction (if (and (@ datum pr)
							      (@ datum pr meta)
							      (@ datum pr meta mode)
							      (@ datum pr meta mode interaction))
							 (if (getprop (@ self interactions)
								      (chain datum pr meta mode interaction 
									     (substr 2)))
							     (getprop (@ self interactions)
								      (chain datum pr meta mode interaction 
									     (substr 2))
								      "click")
							     (chain self props context
								    (get-interaction
								     (chain datum pr meta mode interaction 
									    (substr 2))))))))
				    (if (and interaction (not (= null (typeof interaction))))
					(funcall interaction self datum)
					(let ((datum (chain j-query
							    (extend (create)
								    datum (create dp (@ datum ly))))))
					  (if (/= "set" (@ self state context mode))
					      (chain self (set-point datum)))))))
		      :id (+ (@ self state data id)
			     "-atom-" (@ datum ix))
		      :class-name (+ "atom-inner"
				     (if (and (@ datum mt) (@ datum mt mode) (@ datum mt mode view))
					 " custom-interface" "")
				     ;; (+ " mode-" (@ self state context mode))
				     ;; (+ " row-" (@ datum ct))
				     ;; TODO: IS THERE A BETTER WAY TO HANDLE POINTS IN LISTS VS. FORMS?
				     ;; SUCH AS HAVING THE POINT DESIGNATION WORK IN A MORE SIMILIAR WAY FOR
				     ;; BOTH TYPES
				     (+ " ot-" (@ self state point-attrs index))
				     (if (= (@ self state point-attrs index)
					    (@ datum ix))
					 " point" "")
				     (if (= (@ self state index) (@ datum ix))
					 " index" "")
				     (if (and (@ datum mt) (@ datum mt mode))
					 (cond ((or (= "__portalName" (@ datum mt mode view))
						    (and (@ datum mt atom)
							 (= "__portalName" (@ datum mt atom mode view))))
						" portal-name")
					       (t ""))
					 ""))
		      (let ((cell-data (create content
					;(progn
					       ;; (if (= (@ self state point index)
					       ;; 	    (@ datum ix))
					       ;;     (chain console (log 200
					       ;; 			(@ self state just-updated)
					       ;; 			(@ self state action))))
					       ;; (if (= (@ self state point-attrs index)
					       ;; 		(@ datum ix))
					       ;; 	(cl :abcd (@ self state point-attrs delta)))
					       (if (and (@ self state point-attrs delta)
							;; (or (not (@ self state action))
							;;     (not (= "recall"
							;; 	     (@ self state action id))))
							(= "set" (@ self state context mode))
					                ;; only use the delta value if the state is
					                ;; "set"
					                ;; TODO: this causes flickering
					                ;; HOW TO PREVENT FLICKERING
					                ;; make sure the action is "recall"
							(= (@ self state point-attrs index)
							   (@ datum ix)))
						   (@ self state point-attrs delta)
						   datum);)
					       meta (create branch-id (@ self state data id)
							    is-point (= (@ self state point-attrs index)
									(@ datum ix))
							    is-parent-point (@ self state context is-point)
							    breadth (@ datum br)))))
			;; (if (and (@ datum mt) (@ datum mt mode)
			;; 		(= "__bar" (@ datum mt mode type)))
			;; 	   (cl :celd cell-data datum (@ self state point-attrs)))
			(if (and (@ datum mt) (@ datum mt mode))
			    (cond ((= "__colorPicker" (@ datum mt mode view))
				   (subcomponent (@ interface-units color-picker)
						 cell-data))
				  ((= "__item" (@ datum mt mode view))
				   (subcomponent (@ interface-units item)
						 ;;cell-data
						 (create content nil ;;(chain self (render-table-body content))
							 data datum)))
				  ((= "__select" (@ datum mt mode view))
				   (subcomponent (@ interface-units select)
						 cell-data))
				  ((= "__textfield" (@ datum mt mode view))
				   (subcomponent (@ interface-units textfield)
						 cell-data))
				  ((= "__textarea" (@ datum mt mode view))
				   (subcomponent (@ interface-units textarea)
						 cell-data))
				  ((= "__bar" (@ datum mt mode view))
				   (subcomponent (@ interface-units bar)
						 cell-data))
				  (t (subcomponent (@ interface-units cell-standard)
						   cell-data)))
			    (subcomponent (@ interface-units cell-standard)
					  cell-data
					  :context
					  (branch self focus (@ self state focus)
						  is-point (= (@ self state point-attrs index)
							      (@ datum ix))
						  menu-content (@ self props context menu-content))
					  ;; ((setf (@ sub-con branch) self
					  ;; 	 (@ sub-con focus) (@ self state focus)
					  ;; 	 (@ sub-con is-point)
					  ;; 	 (= (@ self state point-attrs index)
					  ;; 	    (@ datum ix))
					  ;; 	 ;; (@ sub-con rendered-menu)
					  ;; 	 ;; (@ self props context rendered-menu)
					  ;; 	 (@ sub-con menu-content)
					  ;; 	 (@ self props context menu-content)))
					  ))))))
   :render-list
   (lambda (rows-input callback)
     (let ((self this)
	   (count 0))
       ;;(chain console (log :ri rows-input))
       (labels ((process-list (input layer index output)
		  (let ((layer (if layer layer 0))
			(index (if index index 0))
			(output (if output output #())))
		    (if (= 0 (@ input length))
			output
			(process-list (chain input (slice 1))
				      layer (1+ index)
				      (if (and (= "[object Object]" (chain -object prototype to-string
									   (call (@ input 0))))
					       (= "plain" (@ input 0 ty 0)))
					  output
					  (if (and (= "[object Array]" (chain -object prototype to-string
									      (call (@ input 0)))))
					      (chain output 
						     (concat (list (panic:jsl
								    (:li :key (+ "list" (@ rows-input 0 ix)
										 "-" layer "-" index)
									 (:ul :class-name "form-view in"
									      (process-list (@ input 0)
											    (1+ layer))))))))
					      (progn (setf (@ input 0 ct) count
							   count (1+ count))
						     (chain output
							    (concat (list (panic:jsl
									   (:li 
									    :key (+ "li" (@ rows-input 0 ix)
										    "-" layer "-" (@ input 0 ix))
									    (chain self (render-atom
											 (@ input 0))))))))))))))))
	 (funcall callback (panic:jsl (:ul :class-name (+ "form-view " (@ self props context view-scope))
					   (process-list rows-input)))))))
   :render-sub-list
   (lambda (datum content)
     (let ((self this))
       (panic:jsl (:td :key (+ "form-view-td-" (@ datum ix))
		       :ref (lambda (ref)
			      (if (and ref (not (and (@ datum mt) (@ datum mt mode)
						     (= "__item" (@ datum mt mode view)))))
				  ;; don't assign element spec locations to items
				  ;; within specially-rendered sub-lists
				  (labels ((pos (element offset)
					     (let* ((offset (if offset offset (create left 0 top 0)))
						    (this-offset (create left (+ (@ offset left)
										 (@ element 0 offset-left))
									 top (+ (@ offset top)
										(@ element 0 offset-top))
									 height (@ element 0 client-height)
									 width (@ element 0 client-width))))
					       ;; return the offset if the measurement reaches the container
					       (if (= "pane" (chain (j-query element) (offset-parent) 
								    (attr "class")))
						   (setf (getprop (@ self element-specs) (@ datum ix))
							 this-offset)
						   (pos (chain (j-query element) (offset-parent))
							this-offset)))))
				    (pos (j-query ref)))))
		       :class-name (+ (if (and (@ datum mt) (@ datum mt mode)
					       (= "list" (@ datum mt mode view)))
					  "special-table" "sub-table")
				      (+ " mode-" (@ self state context mode))
				      (if (= (@ datum ix) (@ self state point-attrs index))
					  " point" ""))
		       :id (+ (@ self state data id) "-atom-"
			      (@ datum ix))
		       :col-span (- (@ self state meta max-depth) (@ datum ly))
		       :row-span (@ datum br)
		       ;; get the number of rows in the sub-list for the container rowspan
		       (:div :class-name "spacer")
		       (cond ((and (@ datum mt) (@ datum mt mode)
				   (= "__list" (@ datum mt mode view)))
			      ;;(cl :ls-cont content)
			      (subcomponent (@ interface-units list)
					    ;; remove the first element from the content,
					    ;; since this element usually comes from after
					    ;; the plain list marker
					    (create content (chain self (render-table-body content))
						    params datum)))
			     ((and (@ datum mt) (@ datum mt mode)
				   (= "__item" (@ datum mt mode view)))
			      (subcomponent (@ interface-units item)
					    (create content (chain self (render-table-body content))
						    ;; TEMP enabled
						    data datum)))
			     (t (chain self (render-table-body content))))))))
   :render-table-body
   (let ((table-index -1))
     (lambda (rows is-root)
       (let ((self this))
	 (setq table-index (1+ table-index))
	 ;; (cl :rrr rows)
	 (panic:jsl (:table :class-name (+ "form" (if is-root " root" ""))
			    ;; the table-index is used for tables generated...
			    :key (+ (if (= 0 (@ rows 0 length))
					(+ "index-" table-index)
					(@ rows 0 0 key))
				    "-body")
			    :ref (lambda (ref)
				   (if ref (let ((elem (j-query ref)))
					     (if is-root (setf (@ self root-params)
							       (create parent-height
								       (@ elem 0 offset-parent client-height)
								       left (@ elem 0 offset-left)
								       top (@ elem 0 offset-top)
								       width (@ elem 0 client-width)
								       height (@ elem 0 client-height)))))))
			    (:tbody (chain rows (map (lambda (row-data index)
						       (panic:jsl (:tr :key (+ "tr-" index)
								       row-data)))))))))))
   :render-table
   (lambda (rows-input callback)
     (defvar self this)
     (labels ((generate-cell (datum)
		(panic:jsl (:td :key (+ "table-" (@ datum ix))
				:col-span (if (not (@ datum br))
					      (- (@ self state meta max-depth) (@ datum ly))
					      1)
				:row-span (if (@ datum br) (@ datum br) 1)
				:ref (lambda (ref)
				       (if ref
					   (let ((in-special-form false))
					     (labels ((pos (element offset)
							(let* ((offset (if offset offset (create left 0 top 0)))
							       (this-offset 
								(create left (+ (@ offset left)
										(@ element 0 offset-left))
									top (+ (@ offset top)
									       (@ element 0 offset-top))
									height (if (@ offset height)
										   (@ offset height)
										   (@ element 0 client-height))
									width (@ element 0 client-width))))
					                  ;; return the offset if the measurement
					                  ;; reaches the container
							  ;; TODO: STRANGE SOLUTION - IS THERE 
							  ;; A SIMPLER WAY THAN
							  ;; CHECKING THE TYPE OF CONTAINER? x
							  (if (= "pane" (chain (j-query element)
									       (offset-parent)
									       (attr "class")))
							      (setf (getprop (@ self element-specs) 
									     (@ datum ix))
								    this-offset)
							      (pos (chain (j-query element) 
									  (offset-parent))
								   this-offset)))))
					       (pos (j-query ref))))))
				:class-name (+ "atom"
					       (if (and (@ datum mt) (@ datum mt mode) (@ datum mt mode view))
						   " custom-interface" "")
					       (+ " mode-" (@ self state context mode))
					       (+ " row-" (@ datum ct))
					       (if (= (@ self state point-attrs index)
						      (@ datum ix))
						   " point" "")
					       (if (and (not (= "undefined" (typeof (@ datum br))))
						(= 0 (@ datum br)))
						   " singleton" "")
					       (if (@ datum cx)
						   (chain datum cx (map (lambda (item index)
									  (+ " reader-context-" item)))
							  (join ""))
						   "")
					       (if (and (@ datum mt) (@ datum mt mode)
							(= "list" (@ datum mt mode view)))
						   " special-table" ""))
				(chain self (render-atom datum)))))
	      (process-rows (rows output)
	      	(let ((cells (@ rows 0))
	      	      (empty-rows #())
	      	      (is-outer-form (if (not output)
	      				 t false))
	      	      (output (if output output (list #()))))
	      	  (if (= 0 (@ rows length))
	      	      (chain output (slice 0 (1- (@ output length))))
	      	      ;; remove final empty list that gets appended to output before returning it
	      	      (if (= 0 (@ cells length))
	      		  (process-rows (chain rows (slice 1))
	      				(chain output (concat (list #()))))
	      		  (if (= "plain" (@ cells 0 ty 0))
	      		      ;; create a sub-table for plain lists

			      (process-rows
	      		       (chain rows (slice (+ (@ cells 0 br)
						     (if (and (@ cells 0 pr meta mode)
							      (@ cells 0 pr meta mode open))
							 1 0))
						  (- (@ rows length) 0)))
	      		       (let* ((enclose-table
				       (if is-outer-form
					   (lambda (input) (chain self (render-table-body input t)))
					   (lambda (input)
					     (chain self (render-sub-list (@ cells 0)
									  (chain input
										 (slice 0 (@ input length))))))))
	      		      	      (rows-to-process
				       (chain (list (chain cells (slice 1)))
					      (concat (chain rows
							     (slice 1 (+ (if (and (@ cells 0 pr meta mode)
										  (@ cells 0 pr meta mode open))
									     1 0)
									 (@ cells 0 br)))))))
	      		      	      ;; add the blank output array so that the
	      		      	      ;; process-rows function knows that it is not
	      		      	      ;; the outer form
	      		      	      (enclosed (enclose-table (process-rows rows-to-process (list #())))))
	      		      	 (loop for ix from 0 to (1- (@ cells 0 br))
	      		      	    do (chain empty-rows (push #())))
	      		      	 (chain output (slice 0 (1- (@ output length)))
	      		      		(concat (list (chain (getprop output (1- (@ output length)))
	      		      				     (concat enclosed))))
	      		      		(concat empty-rows))))
			      
	      		      ;; (process-rows
	      		      ;;  (chain rows (slice (1+ (@ cells 0 br))))
	      		      ;;  (let* ((enclose-table (if is-outer-form
	      		      ;; 				 (lambda (input) (chain self (render-table-body input t)))
	      		      ;; 				 (lambda (input) (chain self (render-sub-list (@ cells 0) input)))))
	      		      ;; 	      (rows-to-process (chain (list (chain cells (slice 1)))
	      		      ;; 				      (concat (chain rows (slice 1 (1+ (@ cells 0 br)))))))
	      		      ;; 	      ;;(rows-to-process (chain rows (slice 1 (@ cells 0 br))))
	      		      ;; 	      ;; add the blank output array so that the
	      		      ;; 	      ;; process-rows function knows that it is not
	      		      ;; 	      ;; the outer form
	      		      ;; 	      (enclosed (enclose-table (process-rows rows-to-process (list #())))))
	      		      ;; 	 (loop for ix from 0 to (1- (@ cells 0 br))
	      		      ;; 	    do (chain empty-rows (push #())))
	      		      ;; 	 (chain output (slice 0 (1- (@ output length)))
	      		      ;; 		(concat (list (chain (getprop output (1- (@ output length)))
	      		      ;; 				     (concat enclosed))))
	      		      ;; 		(concat empty-rows))))
			      ;; (process-rows
	      		      ;;  (chain rows (slice (@ cells 0 br)))
	      		      ;;  (let* ((enclose-table (if is-outer-form
	      		      ;; 				 (lambda (input) (chain self (render-table-body input t)))
	      		      ;; 				 (lambda (input)
	      		      ;; 				   (cl :slc cells input (chain rows (slice 1 (@ cells 0 br))))
	      		      ;; 				   (chain self (render-sub-list (@ cells 0) input)))))
	      		      ;; 	      (rows-to-process (chain (list (chain cells (slice 1)))
	      		      ;; 				      (concat (chain rows (slice 1 (+ 0 (@ cells 0 br)))))))
	      		      ;; 	      ;; add the blank output array so that the
	      		      ;; 	      ;; process-rows function knows that it is not
	      		      ;; 	      ;; the outer form
	      		      ;; 	      (enclosed (enclose-table (process-rows rows-to-process (list #())))))
	      		      ;; 	 (loop for ix from 0 to (1- (@ cells 0 br))
	      		      ;; 	    do (chain empty-rows (push #())))
	      		      ;; 	 (cl :out output enclosed)
	      		      ;; 	 (chain output (slice 0 (1- (@ output length)))
	      		      ;; 		(concat (list (chain (getprop output (1- (@ output length)))
	      		      ;; 				     (concat enclosed))))
	      		      ;; 		(concat empty-rows))))
	      		      ;; TODO: why are empty rows needed? If not appended, table is uneven
	      		      (process-rows (chain (list (chain cells (slice 1)))
	      					   (concat (chain rows (slice 1))))
	      				    (chain output (slice 0 (1- (@ output length)))
	      					   (concat (list (chain (getprop output (1- (@ output length)))
	      								(concat (generate-cell (@ cells 0))))))))))))))
       (funcall callback (process-rows rows-input))))

   :component-will-receive-props
   (lambda (next-props)
     (defvar self this)
     ;; (cl 7989 (jstr (getprop (chain this (initialize next-props)) "space" 1 0))
     ;; 	(not (@ next-props context current)))

     (let ((new-state (chain this (initialize next-props))))
       ;(cl :nws new-state next-props) ; TODO: glyphs don't get assigned here
       (if (@ self state context is-point)
	   (setf (@ new-state action-registered)
		 (@ next-props action)))
       (if (not (= (@ next-props data branch-id)
		   (@ this props data branch-id)))
	   (setf (@ new-state meta) nil
		 (@ new-state space) nil
		 (@ new-state data) nil))
       (if (and (not (@ self state pane-element))
		(not (= "undefined" (typeof (@ self props context fetch-pane-element)))))
	   (setf (@ new-state pane-element)
		 (j-query (+ "#branch-" (@ self props context index)
			     "-" (@ self props data id)))))
       ;; (if (not (= "undefined" (typeof (@ self props context fetch-pane-element))))
       ;; 	  (progn (cl :ffe (@ self props context))
       ;; 		 (cl :ffe (chain self props context (fetch-pane-element)))))
       (if (not (@ next-props context current))
	   ;; only build the form display object if the form is in "full" display mode
	   ;(if (= "full" (@ this props context view-scope))
	   (chain self (build new-state))
					;)
	   (chain this (set-state new-state))))
     ;(cl 777 (@ self state context) (@ self props context))
     ;; (if (@ self props context get-interaction)
     ;; 	(cl :int (chain self props context (get-interaction :commit))))
     ;; (chain self props context methods (chart self))

     ;; (chain this (set-state (chain this (initialize next-props))))

     ;; (cl :pr (@ self state data id) (@ self state point-attrs))

     (handle-actions
      (@ next-props action) (@ self state) next-props
      :actions-any-branch
      ((set-branch-by-id
	(if (= (@ params id) (@ self props data id))
	    (chain self props context methods (set-trace (@ self props context path))))))
      :actions-branch-id
      ((record-move
	"clipboard"
	(chain self (move (@ params vector)))
	(chain self state context methods (grow (create) (create vector (@ params vector))))))
      :actions-point-and-focus
      ((move
	(chain self (move (chain self state context (movement-transform (@ params vector))))))
       (control-shift-meta
	(if (and (= "undefined" (typeof (@ self state point-attrs props meta comment)))
		 (< 0 (@ params vector 0)))
	    (chain self state context methods (grow (create mt (create comment "")
							    am (list "meta")))))
	(chain self (shift-focus "meta" (@ params vector))))
       (record
	(if (@ self props context clipboard-id)
	    (chain self state context methods
		   (grow (create)
			 (create vector (@ params vector)
				 point-to (@ self state point-attrs path)
				 branch (@ self state data id))
			 (@ self props context clipboard-id)))))
       (recall
	(if (and (@ self props context history-id)
		 (or (= "undefined" (typeof (@ next-props data meta)))
		     (not (= true (@ next-props data meta locked)))))
	    (chain self state context methods (grow (create)
						    (create vector (@ params vector)
							    "recall-branch" (@ self state data id))
						    (@ self props context history-id)))))
       (commit
	(if (or (= "undefined" (typeof (@ next-props data meta)))
		(not (= true (@ next-props data meta locked))))
	    (chain self state context methods (grow #() (create save true)))))
       (revert
	(chain self state context methods (grow #() (create revert true))))
       (set-point-type
	(if (or (= "undefined" (typeof (@ next-props data meta)))
		(not (= true (@ next-props data meta locked))))
	    (progn (chain self state context methods (set-mode "set"))
		   (chain self (set-state (create action-registered nil)))
		   (chain self state context methods
			  (grow (create ty (@ params type) vl (@ params default)))))))
       (add-reader-macro
	(if (or (= "undefined" (typeof (@ next-props data meta)))
		(not (= true (@ next-props data meta locked))))
	    (progn (chain self (set-state (create action-registered nil)))
		   (chain self state context methods
			  (grow (if (@ self state point-attrs is-atom)
				    (create am (chain (list (@ params name))
						      (concat (@ self state point-attrs atom-macros))))
				    (create fm (chain (list (@ params name))
						      (concat (@ self state point-attrs
								      form-macros))))))))))
       (remove-reader-macro
	(if (or (= "undefined" (typeof (@ next-props data meta)))
		(not (= true (@ next-props data meta locked))))
	    (progn (chain self (set-state (create action-registered nil)))
		   (chain self state context methods 
			  (grow (if (@ self state point-attrs is-atom)
				    (create am (chain self state point-attrs form-macros (slice 1)))
				    (if (< 0 (@ self state point-attrs atom-macros length))
					(create am (chain self state point-attrs atom-macros (slice 1)))
					(create fm (chain self state point-attrs form-macros
							  (slice 1))))))))))
       (delete-point
	(if (or (= "undefined" (typeof (@ next-props data meta)))
		(not (= true (@ next-props data meta locked))))
	    (chain this (delete-point (@ this state point)))))
       (insert
	(let ((new-space (chain j-query (extend #() (@ self state space))))
	      (new-item (create vl "" ty (list "symbol")) ))
	  (chain this (seek (@ this state point) (@ this state point-attrs depth) new-space
			    (lambda (target target-list target-parent target-index path)
			      (if (= 0 (@ params vector 0)) ;; if this is top level...
				  (chain target-parent (splice (+ (@ params vector 1) target-index)
							       0 new-item))
				  (if (and target-list (< 0 (@ params vector 0)))
				      (chain target-list (push new-item))
				      (chain target-parent (splice target-index 1
								   (list (if (and target-list
										  (> 0 (@ params vector 0)))
									     target-list target)))))))))
	  ;(chain self (set-state (create action-registered nil)))
	  ;; TODO: this action is not registered, therefore no rendering happens before the grow
	  ;; AND figure out why movement can't be delayed until after refresh
	  (chain self state context methods
		 (grow-branch new-space (create)
			      ;; (lambda () 
			      ;;   (cl :sta (@ self state))
			      ;;   (chain self (move (list 0 (- (@ params to 1))))))
			      ))))
       (trigger-secondary
	(if (or (= "undefined" (typeof (@ next-props data meta)))
		(not (= true (@ next-props data meta locked))))
	    (chain self (interact (@ self state point-data)
				  (lambda () (chain self (set-state (create action-registered nil)))
					  (chain self state context methods (set-mode "set")))))))
       (trigger-primary
	(cond ((= "move" (@ self state context mode))
	       (if (or (= "undefined" (typeof (@ next-props data meta)))
		       (not (= true (@ next-props data meta locked))))
		   (chain self (interact (@ self state point-data)
					 (lambda () (chain self state context methods (set-mode "set")))))))
	      ((= "set" (@ self state context mode))
	       (chain self (set-state (create action-registered nil)))
	       (chain self state context methods (grow (@ self state point-attrs delta)))
	       (chain self (set-focus "meta" 0))
	       (chain self state context methods (set-delta nil))
	       (chain self state context methods (set-mode "move")))))
       (trigger-anti
	(chain self (set-state (create action-registered nil)))
	(chain self (set-focus "meta" 0))
	(chain self state context methods (set-delta nil))
	(chain self state context methods (set-mode "move")))
       )))
   :component-did-mount
   (lambda () (chain this (build (@ this state))))
   :should-component-update
   (lambda (next-props next-state)
     ;; (if (= "main" (@ this props data id))
     ;; 	(cl :mc (or (not (@ this state rendered-content))
     ;; 		    (@ this props context force-render)
     ;; 		     (= 0 (@ this element-specs length))
     ;; 		     (or (not (@ next-state context current))
     ;; 			 (not (= (@ next-state context mode)
     ;; 				 (@ this state context mode)))
     ;; 			 (@ next-state action-registered)))
     ;; 	    (@ next-state context current)))
     (or (not (@ this state rendered-content))
	 (@ this props context force-render)
	 (= 0 (@ this element-specs length))
	 (or (not (@ next-state context current))
	     (not (= (@ next-state context mode)
		     (@ this state context mode)))
	     (@ next-state action-registered))))
   :component-did-update
   (lambda ()
     (let ((self this))
       ;; (cl 5432 (@ self state action-registered))
       ;; (if (= "short" (@ self props context view-scope))
       ;; 	  (cl :upd (@ self state point-attrs value) (jstr (@ self state point-attrs props))
       ;; 	      (@ self state point-attrs)))
       ;; if the point-attrs are marked as fresh, i.e. the form view has just been created,
       ;; perform a point movement to correctly set the point-attrs
       (if (and (@ self state point-attrs fresh)
		(< 0 (@ self state space length)))
		;; only do the movement if there's something in the form's space
		;; i.e. it isn't an empty form
	   (chain self (move (if (@ self props context initial-motion)
				 (@ self props context initial-motion)
				 #(0 0)))))
       (if (@ self state action-registered)
	   (chain self (set-state (create action-registered nil))))
       ;; (if (not (@ self state context current))
       ;; 	  (extend-state context (create current true)))
					;(cl 110 (not (@ self state meta element-specs)))
       (if (not (@ self state meta element-specs))
	   (extend-state meta (create element-specs (@ self element-specs))
			 context (create current false)))
       (if (and (= "set" (@ self state context mode))
		(@ self state context is-point)
		;;(= null (@ self state point-attrs delta))
		)
	   (let* ((input-ref (chain (j-query (+ "#form-view-" (@ this state data id)
						" .atom.mode-set.point input"))))
		  (temp-val (chain input-ref (val))))
	     ;; need to momentarily blank the value so the cursor goes to the end on all browsers
	     (chain input-ref (focus))
	     (chain input-ref (val ""))
	     (chain input-ref (val temp-val))))
       (if (and (= "set" (@ self state context mode))
		(= 1 (@ self state focus meta))
		(@ self state context is-point))
	   (let* ((input-ref (chain (j-query (+ "#form-view-" (@ this state data id)
						" .atom.point .meta-comment input"))))
		  (temp-val (chain input-ref (val))))
	     (chain input-ref (focus))
	     (chain input-ref (val ""))
	     (chain input-ref (val temp-val)))))))

  (defvar self this)
  ;; (if (= "main" (@ this props data id))
  ;;     (chain console (log :ioi (@ this state context))))
  (if (or (not (= "undefined" (typeof (@ this state rendered-content))))
	  (and (= "[object Array]" (chain -object prototype to-string (call (@ this state rendered-content))))
	       (= 0 (@ this state rendered-content length))))
      (cond ((= "full" (@ this props context view-scope))
	     (let* ((root-index (labels ((find-index (item)
					   (if (= "[object Object]" (chain -object prototype to-string (call item)))
					       (@ item ix)
					       (find-index (@ item 0)))))
				  (find-index (getprop (@ this state space)
						       (1- (@ this state space length))))))
		    (glyph-content (chain j-query (extend (create branch-id (@ self state data id)
								  base-atom root-index
								  branch-index (@ self props context branch-index)
								  root-params (@ self root-params)
								  point-index (@ self state point-attrs index))
							  (@ self state meta)
					                  ;; TODO: this is a hack. assigning the glyphs straight
					                  ;; from props shouldn't be necessary - or the state
					                  ;; meta property shouldn't be necessary. Without this,
					                  ;; the glyphs do not refresh when changing systems
							  (create glyphs (@ self props data meta glyphs))))))
	       (chain self (render-table (@ this state rendered-content)
					 (lambda (rendered)
					   ;; send the base-atom to the glyph-display so that the stem
					   ;; at the bottom of the glyph pattern can be drawn
					   (panic:jsl (:div :class-name "matrix-view form-view"
							    :id (+ "form-view-" (@ self state data id))
							    :key (+ "form-view-" (@ self state data id))
							    ;; (subcomponent (@ view-modes glyph-display)
							    ;; 		  glyph-content)
							    rendered)))))))
	    (t (chain self (render-list (@ this state space)
					(lambda (rendered depth base-atom)
					  (panic:jsl (:div :class-name "form-view"
							   :id (+ "form-view-" (@ self state data id))
							   :key (+ "form-view-" (@ self state data id))
							   rendered)))))))
      (panic:jsl (:div))))

 (glyph-display
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (let ((self this))
       (funcall inherit self props
		(lambda (d) (@ d data))
		(lambda (pd) (@ pd data glyphs)))))
   :component-will-receive-props
   (lambda (next-props)
     ;(chain this (set-state (chain this (initialize next-props))))
     ;(cl :nxp next-props)
     (let ((new-state (chain this (initialize next-props))))
       (if (@ next-props data root-params width)
	   (let ((params (@ next-props data root-params)))
	     ;; add 3 or subtract 3 for the margin beneath the table TODO a more elegant way to do this? x
	     (chain this (set-state (chain j-query (extend
						    new-state
						    (create dims (list (@ params width)
								       (max (- (@ params parent-height) 3)
									    (+ 3 (@ params height)))))))))
	     (chain (j-query (getprop (@ this refs) (+ "formTable-" (@ next-props data branch-id))))
		    (find "g.point")
		    (remove-class "point"))
	     (chain (j-query (getprop (@ this refs) (+ "g" (@ next-props data point-index))))
		    (add-class "point")))
	   (chain this (set-state new-state)))))
   :should-component-update
   (lambda (next-props next-state)
     (and (not (@ next-state context current))
	  (not (or (= nil (@ next-props data element-specs))
		   (= "undefined" (typeof (@ next-props data element-specs)))))))
   :component-did-update
   (lambda ()
     (chain (j-query (getprop (@ this refs) (+ "formTable-" (@ this props data branch-id))))
	    (find "g.point")
	    (remove-class "point"))
     (chain (j-query (getprop (@ this refs) (+ "g" (@ this props data point-index))))
	    (add-class "point"))))
  (defvar self this)
  ;; (chain console (log "RE" (@ self state just-updated)))
  ;; (cl 88 (jstr (chain -object (keys (@ self props table-refs)))) (@ self props glyphs))

  (defun render-glyph (points con-height xos yos next-line nexcon-height next-xos next-yos is-last is-root)
    (let* ((height-factor (+ 1 (@ (j-query (+ "#branch-" (@ self props data branch-index)
					      "-" (@ self props data branch-id)
					      " table.form tbody tr:first-child td:last-child"))
				  0 client-height)))
				  ;; take the height factor from the first single-height cell
				  ;; TODO: a better way to find it? search for first cell with rowspan=1? x
	   (x-offset (- xos 3))
	   (y-offset (+ 0 yos (- con-height height-factor)))
	   (next-y-offset (+ 1 next-yos (- nexcon-height height-factor)))
	   (y-int (/ height-factor 16))
	   (output ""))
      (loop for pix from 0 to (1- (@ points length))
	 do (if (or (not is-last)
		    (and is-last next-line)
		    (and is-last is-root (not next-line))
		    (and is-last (not next-line)
			 (not (= pix (1- (@ points length))))))
			 ;; don't plot the last point if this is the last line in the glyph and isn't connected
			 ;; to a glyph below it, so the "tail" is not left hanging. The only exception is for
			 ;; the root glyph, whose tail extends to the bottom of the pane
		(setq output (+ output (if (equal output "") "M " "L ")
				(+ x-offset (* y-int (getprop points pix 0)))
				" " (+ y-offset (* y-int (getprop points pix 1)))
				" "))))
      (if (and next-line is-last)
	  (loop for pix from 0 to (1- (@ next-line length))
	     do (setq output (+ output "L " (+ x-offset (* y-int (getprop next-line pix 0)))
				" " (+ next-y-offset (* y-int (getprop next-line pix 1)))
				" "))))
      (if (and is-root is-last)
	  (setq output (+ output "L " x-offset " " (1- (@ self state dims 1)))))
      output))

  (if (and (@ this state space)
	   (@ this props data root-params top)
	   (@ this props data element-specs))
      (let ((display #()))
	;(cl :scc (@ this state space))
	(loop for glix from 0 to (1- (@ self state space length))
	   do (if (getprop (@ self props data element-specs) glix)
		  (let* ((origin (getprop (@ self props data element-specs) glix))
			 (successor (if (not (= "undefined" (getprop (@ self state data succession) glix)))
					(getprop (@ self props data element-specs)
						 (getprop (@ self state data succession) glix))))
			 (container-height (@ origin "height"))
			 (nexcon-height (if successor (@ successor height)))
			 (next-line (if successor (getprop (@ this state space)
							   (getprop (@ self state data succession) glix)
							   0)))
			 (nxo (if successor successor (create left nil top nil)))
			 (each-line 
			  (list (if (not (or (= "undefined" (typeof origin))
					     (= "undefined" (typeof nxo))))
				    (chain (getprop (@ self state space) glix)
					   (map (lambda (line index)
						  (if (not (= 0 index))
						      (jsl (:path :key (+ "line-" index)
								  :d (render-glyph
								      line container-height
								      (@ origin left) (@ origin top)
								      next-line nexcon-height
								      (@ nxo left) (@ nxo top)
								      (= index (1- (@ (getprop (@ self state space) 
											       glix) length)))
								      (= glix
									 (@ self props data base-atom)))))))))))))
		    (chain display (push (panic:jsl (:g :id (+ "glyph-" (@ self props data branch-id) 
							       "-" glix)
							:ref (+ "g" glix)
							:key (+ "glyph-g-" glix)
							(:g :key (+ "glyph-colsh1-" glix)
							    :class-name "glyph-shadow"
							    :transform "translate(2)"
							    (@ each-line 0))
							(:g :key (+ "glyph-colsh2-" glix)
							    :class-name "glyph-shadow"
							    :transform "translate(-1)"
							    (@ each-line 0))
							(:g :key (+ "glyph-col-" glix)
							    :class-name "glyph"
							    (@ each-line 0)))))))))
	(panic:jsl (:svg :class-name "dendroglyphs"
			 :id (+ "dend" (new (chain (-date) (get-time))))
			 :style (create height (+ (@ self state dims 1) "px")
					width (+ (@ self state dims 0) "px"))
			 :ref (+ "formTable-" (@ self state data branch-id))
			 display)))
      (panic:jsl (:svg :class-name "dendroglyphs")))))
