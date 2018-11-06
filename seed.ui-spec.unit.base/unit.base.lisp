;;;; seed.ui-spec.unit.base.lisp

(in-package #:seed.ui-model.react)

(specify-components
 interface-units
 (cell-standard
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) (@ pd data content vl))))
   :display-switch
   (lambda () (chain self (set-state (create open (not (@ self state open))))))
   :component-will-receive-props
   (lambda (next-props)
     (defvar self this)
     (if (/= "set" (@ next-props context mode))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (setq self this)
  (let* ((content (@ this state data content))
	 (content-meta (@ this props data meta))
	 (editor-active (and (@ content-meta is-parent-point)
			     (@ content-meta is-point)
			     (= "set" (@ this props context mode))
			     (or (not (@ this props context focus))
				 (= 0 (@ this props context focus meta))))))
    (panic:jsl (:div :class-name
		     (funcall (lambda (state)
				(+ "content" 
				   (if (@ state open) " focus" "")
				   (funcall (lambda ()
					      (defvar name "")
					      (loop for tix from 0 to (1- (@ content ty length))
						 do (setq name (+ name " type-" (getprop (@ content ty) tix))))
					      name))))
			      (@ this state))
		     (if editor-active
			 (funcall (lambda (self)
				    (panic:jsl (:div :class-name "editor"
						     (:input :class-name "data"
							     :value (@ content vl)
							     :on-change
							     (lambda (event)
							       ;; assign both the local and parent state
							       (let ((new-val (create vl (@ event target value))))
								 (extend-state :deep data
									       (create content new-val))
								 (chain self props context methods
									(set-delta new-val))))))))
				  this)
			 (panic:jsl (:span :class-name (if (@ content ti) "title" "text")
					   :ref "target"
					   (if (@ content ti)
					       (panic:jsl (:-seed-symbol :symbol (@ content ti)))
					       (@ content vl))
					   ;; (if (and (@ content pr)
					   ;; 	    (@ content pr pkg)
					   ;; 	    (/= "common-lisp" (@ self props data content pr pkg))
					   ;; 	    (or (not (@ content-meta breadth))
					   ;; 		(= 1 (@ content-meta breadth))))
					   ;;     (panic:jsl (:sup (:-overlay-trigger
					   ;; 			 :placement "right"
					   ;; 			 ;; :overlay (panic:jsl
					   ;; 			 ;; 	   (:-tooltip
					   ;; 			 ;; 	    :id "package-info"
					   ;; 			 ;; 	    (:span "package: ")
					   ;; 			 ;; 	    (:-seed-symbol
					   ;; 			 ;; 	     :symbol (@ self props data content
					   ;; 			 ;; 			     pr pkd))))
					   ;; 			 (:span :class-name
					   ;; 				(+ "package-tag mini"
					   ;; 				   (if (and (@ self props data content pr)
					   ;; 					    (= (@ self props data
					   ;; 						       content pr pkg)
					   ;; 					       (@ self props context
					   ;; 						       working-system)))
					   ;; 				       " native" ""))
					   ;; 				(:span :class-name "regular"
					   ;; 				       (@ content pr pkd 0 0 0))
					   ;; 				(:span :class-name "native"
					   ;; 				       "●"))))))
					   )))
		     (:div :class-name "breaker")
		     (if (@ self props context is-point)
			 (panic:jsl
			  (:div (if (@ self props context menu-content)
				    (let ((rendered-menu
					   (subcomponent (@ view-modes form-view)
							 (create 
							  id "menu"
							  data (@ self props context menu-content))
							 :context (inert
								   t
								   on-trace t
								   branch (@ self props context branch)
								   view-scope "short"))))
				      (panic:jsl (:-overlay :show t
							    :target (@ this refs target)
							    :container self
							    :placement "right"
							    (:-popover 
							     :class-name "menu-popover form-view"
							     rendered-menu))))))))
		     ;; (if (and (@ content pr)
		     ;; 	      (@ content pr pkg)
		     ;; 	      (not editor-active)
		     ;; 	      (@ content-meta breadth)
		     ;; 	      (< 1 (@ content-meta breadth)))
		     ;; 	 (panic:jsl (:-overlay-trigger
		     ;; 		     :placement "right"
		     ;; 		     ;; :overlay (panic:jsl (:-tooltip
		     ;; 		     ;; 			  :id "package-name-display"
		     ;; 		     ;; 			  (:span "package: ")
		     ;; 		     ;; 			  (:-seed-symbol :symbol (@ content pr pkd))))
		     ;; 		     (:span :class-name
		     ;; 			    (+ "package-tag"
		     ;; 			       (if (and (@ self props data content pr)
		     ;; 					(= (@ self props data content pr pkg)
		     ;; 					   (@ self props context working-system)))
		     ;; 				   " native" ""))
		     ;; 			    (:span (:-seed-symbol
		     ;; 				    :symbol (@ content pr pkd)
		     ;; 				    :common (and (@ self props data content pr)
		     ;; 						 (= "common-lisp"
		     ;; 						    (@ self props data content pr pkg)))
		     ;; 				    :native (and (@ self props data content pr)
		     ;; 						 (= (@ self props data content pr pkg)
		     ;; 						    (@ self props context
		     ;; 							    working-system)))))))))
		     (if (and (@ content mt)
			      (or (@ content mt comment) (= "" (@ content mt comment))))
			 (funcall (lambda (self)
				    (panic:jsl (:-autosize-input
						:class-name (+ "meta-comment"
							       (if (= 1 (@ self props context focus meta))
								   " focus" ""))
						:disabled (/= 1 (@ self props context focus meta))
						:value (@ content mt comment)
						:on-change
						(lambda (event)
						  (let ((new-val 
							 (create mt (create comment 
									    (@ event target value)))))
					            ;;(extend-state :deep data (create content new-val))
						    (chain j-query (extend t (@ self state data content)
									   new-val))
						    (chain self props context methods
							   (set-delta new-val)))))))
				  this))))))

 (cell-spreadsheet
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (let ((self this))
       (funcall inherit this props
		(lambda (d) (chain j-query (extend (create input-value
							   (if (@ d data content data-inp)
							       (@ d data content data-inp)
							       "")
							   type (@ d data content type))
						   (@ d data))))
		(lambda (pd) (if (@ pd data content data-com)
				 (@ pd data content data-com 0)
				 (@ pd data content data-inp))))))
   :display-switch
   (lambda () (chain self (set-state (create open (not (@ self state open))))))
   :component-will-receive-props
   (lambda (next-props) (chain this (initialize next-props))))
  (defvar self this)
  (panic:jsl (:div :class-name
		   (+ "content type-"
		      (if (/= "undefined" (typeof (@ self props data content type)))
			  (chain self props data content type (substr 2))
			  ;; remove the first two characters; since this is a converted
			  ;; keyword, they will always be "__"
			  "null")
		      (if (@ self props data content data-com)
			  (+ " it-" (@ self props data content data-com length))
			  "")
		      (if (@ self props data meta is-point) " point" "")
		      (if (@ self props data content data-inp)
			  (if (@ self props data content data-com)
			      " computed-input" " input")
			  ""))
		   (if (and (@ self props data meta is-point)
			    (@ self props data meta is-parent-point)
			    (= "set" (@ self props context mode))) ;; TODO: IS THIS THE CORRECT MODE VAR?
		       (panic:jsl (:div :class-name "editor"
					(:input :class-name "data"
						:value (@ self state data input-value)
						:on-change
						(lambda (val)
						  (chain self props context methods
							 (set-delta (@ val target value)))
						  (extend-state data (create input-value (@ val target value))))))))
		   (:span :class-name "overridden-text"
			  (@ self props data content data-inp-ovr))
		   (:span :class-name "text"
			  (if (and (@ self props data content)
				   (= "__function" (@ self props data content type)))
			      (+ "f" (let ((to-append ""))
				       (loop for x from 0 to (1- (@ self props data content args-count))
					  do (setq to-append (chain to-append (concat "."))))
				       to-append))
			      (if (@ self props data content data-com)
				  (@ self props data content data-com 0)
				  (@ self props data content data-inp)))))))
 (bar
  (:get-initial-state 
   (lambda ()
     (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) (@ pd data content vl))))
   :component-will-receive-props
   (lambda (next-props)
     (if (/= "set" (@ next-props context mode))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (let ((branch-index (@ this state data content mt branch-index))
	(point-offset (@ this state data content mt point-offset))
	(is-composite (/= "undefined" (typeof (@ this state data content mt branch-index))))
	(sub-point-present (/= "undefined" (typeof (@ this state data content mt point-offset)))))
    (panic:jsl (:div
		(:div :class-name (+ "bar"
				     (if is-composite " composite" "")
				     (if (and sub-point-present (@ this state data content mt))
					 (if (= 0 point-offset)
					     " sub-point" "")
					 ""))
		      :style (create width
				     (+ (- 100 (if (and is-composite (@ this state data content mt))
					           ;; 1 is added to the branch index to 
					           ;; allow for the point indicator to the right
						   (* 12 (1+ branch-index))
						   0))
					"%")
				     margin-left
				     (+ (if (and is-composite (@ this state data content mt))
					    (* 12 branch-index)
					    0)
					"%"))
		      (:div))
		(if is-composite (panic:jsl (:div :class-name "point-marker" (:div))))))))
 (color-picker
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) (@ pd data content vl))))
   :display-switch
   (lambda () (chain self (set-state (create open (not (@ self state open))))))
   :component-will-receive-props
   (lambda (next-props)
     (if (/= "set" (@ next-props context mode))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (let ((self this)
	(content (@ this state data content))
	(content-meta (@ this props data meta)))
    (panic:jsl (:div :class-name "content"
		     (:div :class-name "rgb-holder"
			   (:-overlay-trigger
			    :placement "bottom" :trigger "click"
			    :on-click
			    (lambda ()
			      (if (/= (@ content vl)
				      (@ self state space))
				  ;; TODO: BOTH OF THE BELOW ACTIONS ARE NEEDED
				  ;; TO UPDATE THE VALUE ON THE SERVER AND CLIENT SIDES
				  (progn (setf (@ content vl) (@ self state space)
					       (@ content pr) (create "rgb-string" (@ self state space)))
					 (chain self state context methods (grow))
					 (chain self props context methods
						(set-delta
						 (create pr (create "rgb-string" (@ self state space))
							 vl (@ self state space)))))))
			    :overlay (panic:jsl (:-popover
						 :id "color-picker-popover" :title "Color Picker"
						 (:-sketch-color-picker
						  :color (@ this state space)
						  :on-change
						  (lambda (color event)
						    (chain self (set-state (create space (@ color hex)))))
						  (:span "Tooltip content."))))
			    (:div (:div :class-name "rgb-control"
					:style (create background
						       (@ this state space)
						       margin "2px"))
				  (:span :class-name "rgb-string"
					 (chain this state space (substr 1))))))))))

 (select
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) (@ pd data content vl))))
   :designate
   (lambda (item)
     (if (/= (@ item value) (@ this state space))
	 (progn (setf (@ this state data content vl) (@ item value 0 vl))
		(chain this state context methods (grow))
		(chain this props context methods (set-delta (create vl (@ item value 0 vl)))))))
   :component-will-receive-props
   (lambda (next-props)
     (if (/= "set" (@ next-props context mode))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (let ((self this))
    (panic:jsl (:div :class-name "content"
		     (:div :class-name "menu-holder"
			   (:div :class-name "dropdown"
				 ((@ -react-bootstrap -dropdown-button)
				  ;; :title (let* ((values (chain self state data content mt mode options
				  ;; 			       (map (lambda (item) (@ item value 0 vl)))))
				  ;; 		(current-value (getprop (@ self state data content mt mode options)
				  ;; 					(chain values 
				  ;; 					       (index-of (@ self state space))))))
				  ;; 	   (if (/= "undefined" (typeof current-value))
				  ;; 	       (funcall (lambda (item) (create label (@ item title)
				  ;; 					       value (@ item value)))
				  ;; 			current-value)))
				  :title (@ self state data content vl)
				  :id (+ "select-dropdown-" (@ self state data content ix))
				  :key (+ "select-dropdown-" (@ self state data content ix))
				  (chain self state data content mt mode options
					 (map (lambda (item index)
						(panic:jsl ((@ -react-bootstrap -menu-item)
							    :event-key index
							    :key index
							    :on-click
							    (lambda () (chain self (designate item)))
							    (@ item title))))))))
			   ;; (:-select :name "form-select"
			   ;; 	     :value (let* ((values (chain self state data content mt mode options
			   ;; 					  (map (lambda (item) (@ item value 0 vl)))))
			   ;; 			   (current-value (getprop (@ self state data content mt mode options)
			   ;; 						   (chain values 
			   ;; 							  (index-of (@ self state space))))))
			   ;; 		      (if (/= "undefined" (typeof current-value))
			   ;; 			  (funcall (lambda (item) (create label (@ item title)
			   ;; 							  value (@ item value)))
			   ;; 				   current-value)))
			   ;; 	     :options (chain self state data content mt mode options
			   ;; 			     (map (lambda (item) (create label (@ item title)
			   ;; 							 value (@ item value)))))
			   ;; 	     :on-change (lambda (value)
			   ;; 			  ;;(chain console (log :inter (@ self state) (@ self props) value))
			   ;; 			  (chain self (designate value))))
			   )))))

 (textfield
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     ;(cl 9090 props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) (if (and (@ this state) (@ this state space))
			       (@ this state space)
			       nil))))
   :component-will-receive-props
   (lambda (next-props)
     (if (/= "set" (@ next-props context mode))
   	 (chain this (set-state (chain this (initialize next-props)))))))
  (let* ((self this)
	 (content (@ self state data content)))
    (panic:jsl (:div :class-name "content"
		     (:div :class-name "textfield-holder"
			   (:div :class-name "input-group"
				 (:div :class-name "input-wrapper form-control"
				       (:input :class-name "textfield"
					       :value (@ content vl)
					       :on-change (lambda (event)
							    (extend-state
							     :deep data
							     (create content
								     (create vl (@ event target value))))
							    (chain self props context methods
								   (set-delta (create vl (@ event target value)))))
					       :on-focus (lambda (event)
							   (if (/= "set" (@ self state context mode))
							       (chain self state context methods
								      (set-mode "set"))))
					       :on-blur (lambda (event)
							  (chain self state context methods (set-mode "move"))
							  ;; (chain self (designate (@ self state space)))
							  (chain self state context methods (grow)))))
				 (if (and (@ self props data content pr)
					  (@ self props data content pr meta)
					  (@ self props data content pr meta mode)
					  (@ self props data content pr meta mode title))
				     (panic:jsl (:span :class-name "input-group-append"
						       (:span :class-name "label-holder input-group-text"
							      (@ self props data content
								      pr meta mode title)))))))))))
  
 ;; (textfield
 ;;  (:get-initial-state
 ;;   (lambda () (chain this (initialize (@ this props))))
 ;;   :initialize
 ;;   (lambda (props)
 ;;     (cl 9090 props)
 ;;     (funcall inherit this props
 ;; 	      (lambda (d) (@ d data))
 ;; 	      (lambda (pd) (if (and (@ this state) (@ this state space))
 ;; 			       (@ this state space)
 ;; 			       nil))))
 ;;   :designate
 ;;   (lambda (item) 
 ;;     (setf (@ this state data content vl) item)
 ;;     (chain this state context methods (grow)))
 ;;   :content ""
 ;;   :component-will-receive-props
 ;;   (lambda (next-props)
 ;;     (if (not (= "set" (@ next-props context mode)))
 ;;   	 (chain this (set-state (chain this (initialize next-props))))))
 ;;   )
 ;;  (let ((self this))
 ;;    (cl :ssl (@ self content))
 ;;    (panic:jsl (:div :class-name "content"
 ;; 		     (:div :class-name "textfield-holder"
 ;; 			   (:input :class-name "textfield"
 ;; 				   :value (if (@ self content)
 ;; 					      (@ self content)
 ;; 					      (@ self state data content vl))
 ;; 				   :on-change (lambda (event)
 ;; 						(cl :ee (@ event target))
 ;; 						(setf (@ self content)
 ;; 						      (@ event target value))
 ;; 						(chain self (set-state (create space (@ event target value))))
 ;; 						)
 ;; 				   :on-focus (lambda (event)
 ;; 					       (cl :eve event (@ self state data content vl))
 ;; 					       (chain self state context methods (set-mode "set"))
 ;; 					       (chain self (set-state (create space
 ;; 					       				      (@ self state data content vl))))
 ;; 					       (setf (@ self content)
 ;; 						     (@ self state data content vl)))
 ;; 				   :on-blur (lambda (event)
 ;; 				   	      (chain self state context methods (set-mode "move"))
 ;; 				   	      (chain self (designate (@ self state space))))
 ;; 				   ))))))

 
 (textarea
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) nil)))
   :designate
   (lambda (item) (chain this state context methods (grow (create vl item))))
   :component-will-receive-props
   (lambda (next-props)
     (if (/= "set" (@ next-props context mode))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (let ((self this))
    (panic:jsl (:div :class-name "content"
		     (:div :class-name "info-tabs"
			   (if (@ self state data content mt mode title)
			       (panic:jsl (:span :class-name "title" 
						 (@ self state data content mt mode title))))
			   (if (@ self state data content mt mode removable)
			       (panic:jsl (:span :class-name "remove" 
						 :on-click (lambda (event)
							     (chain self props context methods
								    (delete-point 
								     (list 
								      (@ self state data content ly)
								      (@ self state data content ct)))))
						 "X"))))
		     (:div :class-name "textarea-holder"
			   (:-autosize-textarea
			    :class-name "textarea"
			    ;; :type "bla"
			    :value (if (@ self state space)
				       (@ self state space)
				       (@ self state data content vl))
			    :on-change (lambda (event)
					 (chain self (set-state (create space (@ event target value)))))
			    :on-focus (lambda (event)
					(chain self state context methods (set-mode "set"))
					(chain self (set-state (create space (@ event target value))))
					(chain self state context methods 
					       (set-point (@ self state data content))))
			    :on-blur (lambda (event)
				       (chain self state context methods (set-mode "move"))
				       (chain self (designate (@ self state space))))))))))

 (item
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props) (funcall inherit this props
			    (lambda (d) (@ d data))
			    (lambda (pd) nil)))
   :permute
   (lambda (input)
     (if (and (@ window -drag-source)
	      (@ window -drop-target))
	 (let* ((over-data nil)
		(collect-source (lambda (connect monitor)
				  (create connect-drag-source (chain connect (drag-source))
					  connect-drag-preview (chain connect (drag-preview))
					  is-dragging (chain monitor (is-dragging)))))
		(collect-target (lambda (connect) (create connect-drop-target (chain connect (drop-target)))))
		(item-source (create begin-drag (lambda (props) (create id (@ props data data ix)
									ly (@ props data data ly)
									ct (@ props data data ct)
									original-index (@ props data data ct)))
				     end-drag (lambda (props monitor component)
						(if (chain monitor (did-drop))
						    (let ((item (chain monitor (get-item)))
							  (drop-result (chain monitor (get-drop-result))))
						      (chain props context methods (sort (list (@ item ly)
											       (@ item ct))
											 over-data)))))))
		(item-target (create can-drop (lambda (props) t)
				     hover (lambda (props monitor) (setq over-data (@ props data data))))))
	   (funcall (chain window (-drop-target "item" item-target collect-target))
		    (funcall (chain window (-drag-source "item" item-source collect-source))
			     input)))))
   :component-will-receive-props
   (lambda (next-props) (chain this (set-state (chain this (initialize next-props))))))
  (let* ((self this)
	 (this-mode (@ self state data data mt mode))
	 (handle (if (@ window -drag-source)
		     (chain self props (connect-drag-source (panic:jsl (:span :class-name "title"
									      (@ this-mode title)))))
		     (panic:jsl (:span :class-name "title" (@ this-mode title)))))
	 (content (panic:jsl (:div :class-name "item"
				   (:div :class-name (+ "item-interface-holder element palette-adjunct navbar"
							(if (@ this-mode toggle) " with-toggle" ""))
					 (if (@ this-mode toggle)
					     (panic:jsl (:div :class-name "btn-group toggle"
							      (:button :on-click
								       (lambda (event)
									 (setf (@ this-mode toggle)
									       (if (= "__on" (@ this-mode toggle))
										   "__off" "__on"))
									 (chain self state context methods
										(grow)))
								       (if (= "__on" (@ this-mode toggle))
									   "On" "Off")
								       (:div :class-name "button-detail")))))
					 (:div :class-name "main"
					       (:div :class-name "sortable-glyph"
						     (seed-icon :sortable))
					       handle
					       (if (@ this-mode removable)
						   (panic:jsl
						    (:span :class-name "remove"
							   :on-click
							   (lambda (event)
							     (chain self props context methods
								    (delete-point
								     (list (@ self state data data ly)
									   (@ self state data data ct)))))
							   (seed-icon :close))))))
				   (if (@ this-mode open)
				       (panic:jsl (:div :class-name "content" (@ self state data content))))))))
    (chain self props (connect-drag-preview (chain self props (connect-drop-target content))))))

 (list
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props) (funcall inherit this props
			    (lambda (d) (@ d data))
			    (lambda (pd) nil)))
   :designate
   (lambda (item)
     (chain this state data params (md (lambda (data) (chain data (push (@ item value)))
					 data)))
     (chain this state context methods (grow)))
   :component-will-receive-props
   (lambda (next-props) (chain this (set-state (chain this (initialize next-props))))))
  (let ((self this))
    ;; (cl :aa (@ self state data))
    (panic:jsl (:div :class-name "element palette-adjunct"
		     (:div :class-name "list-interface-holder"
			   (:div :class-name "navbar"
				 (:div :class-name "dropdown"
				       ((@ -react-bootstrap -dropdown-button)
					:title "Select"
					:id (+ "select-dropdown-" (@ self state data params ix))
					:key (+ "select-dropdown-" (@ self state data params ix))
					(chain self state data params mt mode options
					       (map (lambda (item index)
						      (panic:jsl ((@ -react-bootstrap -menu-item)
								  :event-key index
								  :key index
								  :on-click
								  (lambda () (chain self (designate item)))
								  (@ item title))))))))
				 (:div :class-name "list-info"
				       (:span :class-name "list-label"
					      (+ (@ self state data params pr count)
						 (if (= 1 (@ self state data params pr count))
						     " item" " items")))
				       (if (@ self state data params mt mode removable)
					   (panic:jsl (:span :class-name "remove" 
							     :on-click 
							     (lambda (event)
							       (chain self props context methods
								      (delete-point 
								       (list (@ self state data params ly)
									     (@ self state data params ct)))))
							     (seed-icon :close))))))
			   (@ self state data content)))))))
