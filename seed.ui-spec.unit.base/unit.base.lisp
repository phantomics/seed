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
     (if (not (= "set" (@ next-props context mode)))
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
							       (let ((new-val (create vl (@ event
											    target
											    value))))
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
					   (if (and (@ content pr)
						    (@ content pr pkg)
						    (not (= "common-lisp" (@ self props data
										  content pr pkg)))
						    (or (not (@ content-meta breadth))
							(= 1 (@ content-meta breadth))))
					       (panic:jsl (:sup
							   (:-overlay-trigger
							    :placement "right"
							    :overlay (panic:jsl
								      (:-tooltip
								       :id "package-info"
								       (:span "package: ")
								       (:-seed-symbol
									:symbol (@ self props data
											content
											pr pkd))))
							    (:span :class-name
								   (+ "package-tag mini"
								      (if (and
									   (@ self props data content pr)
									   (= (@ self props data
										      content pr pkg)
									      (@ self props context
										      working-system)))
									  " native" ""))
								   (:span :class-name "regular"
									  (@ content pr pkd 0 0 0))
								   (:span :class-name "native"
									  "●")))))))))
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
		     (if (and (@ content pr)
			      (@ content pr pkg)
			      (not editor-active)
			      (@ content-meta breadth)
			      (< 1 (@ content-meta breadth)))
			 (panic:jsl (:-overlay-trigger
				     :placement "right"
				     :overlay (panic:jsl (:-tooltip
							  :id "package-name-display"
							  (:span "package: ")
							  (:-seed-symbol :symbol (@ content pr pkd))))
				     (:span :class-name
					    (+ "package-tag"
					       (if (and (@ self props data content pr)
							(= (@ self props data content pr pkg)
							   (@ self props context working-system)))
						   " native" ""))
					    (:span
					     (:-seed-symbol
					      :symbol (@ content pr pkd)
					      :common (and (@ self props data content pr)
							   (= "common-lisp"
							      (@ self props data content pr pkg)))
					      :native (and (@ self props data content pr)
							   (= (@ self props data content pr pkg)
							      (@ self props context
								      working-system)))))))))
		     (if (and (@ content mt)
			      (or (@ content mt comment) (= "" (@ content mt comment))))
			 (funcall (lambda (self)
				    (panic:jsl (:-autosize-input
						:class-name (+ "meta-comment"
							       (if (= 1 (@ self props context focus meta))
								   " focus" ""))
						:disabled (not (= 1 (@ self props context focus meta)))
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
		      (if (not (= "undefined" (typeof (@ self props data content type))))
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
     (if (not (= "set" (@ next-props context mode)))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (let ((branch-index (@ this state data content mt branch-index))
	(point-offset (@ this state data content mt point-offset))
	(is-composite (not (= "undefined" (typeof (@ this state data content mt branch-index)))))
	(sub-point-present (not (= "undefined" (typeof (@ this state data content mt point-offset))))))
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
     (if (not (= "set" (@ next-props context mode)))
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
			      (if (not (= (@ content vl)
					  (@ self state space)))
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
     (if (not (= (@ item value) (@ this state space)))
	 (progn (setf (@ this state data content vl) (@ item value 0 vl))
		(chain this state context methods (grow))
		(chain this props context methods (set-delta (create vl (@ item value 0 vl)))))))
   :component-will-receive-props
   (lambda (next-props)
     (if (not (= "set" (@ next-props context mode)))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (let ((self this))
    (panic:jsl (:div :class-name "content"
		     (:div :class-name "menu-holder"
			   (:-select :name "form-select"
				     :value (let* ((values (chain self state data content mt mode options
								  (map (lambda (item) (@ item value 0 vl)))))
						   (current-value (getprop (@ self state data content mt mode options)
									   (chain values 
										  (index-of (@ self state space))))))
					      (if (not (= "undefined" (typeof current-value)))
						  (funcall (lambda (item) (create label (@ item title)
										  value (@ item value)))
							   current-value)))
				     :options (chain self state data content mt mode options
						     (map (lambda (item) (create label (@ item title)
										 value (@ item value)))))
				     :on-change (lambda (value)
						  ;;(chain console (log :inter (@ self state) (@ self props) value))
						  (chain self (designate value)))))))))

 (textfield
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) nil)))
   :designate
   (lambda (item) 
     (setf (@ this state data content vl) item)
     (chain this state context methods (grow)))
   :component-will-receive-props
   (lambda (next-props)
     (if (not (= "set" (@ next-props context mode)))
	 (chain this (set-state (chain this (initialize next-props)))))))
  (let ((self this))
    (panic:jsl (:div :class-name "content"
		     (:div :class-name "textfield-holder"
			   (:input :class-name "textfield"
				   :value (if (@ self state space)
					      (@ self state space)
					      (@ self state data content vl))
				   :on-change
				   (lambda (event)
				     (chain self (set-state (create space (@ event target value)))))
				   :on-focus (lambda (event)
					       ;;(chain self state context methods (set-mode "set"))
					       (chain self (set-state (create space 
									      (@ event target value)))))
				   :on-blur (lambda (event)
					      ;;(chain self state context methods (set-mode "move"))
					      (chain self (designate (@ self state space))))))))))
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
     (if (not (= "set" (@ next-props context mode)))
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
			    :type "bla"
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
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) nil)))
   :component-will-receive-props
   (lambda (next-props)
     (chain this (set-state (chain this (initialize next-props))))))
  (let ((self this))
    (cl :egeg5 (@ self state data))
    (panic:jsl (:div (:div :class-name "list-interface-holder"
			   ((@ -react-bootstrap -panel)
			    (:div :class-name "panel-heading"
				  (:div :class-name "title" (@ self state data data mt mode title))
				  (if (@ self state data data mt mode removable)
				      (panic:jsl (:span :class-name "remove"
							:on-click (lambda (event)
								    (chain self props context methods
									   (delete-point
									    (list (@ self state data data ly)
										  (@ self state data data ct)))))
							"X"))))))
		     ;;(@ self state data content)
		     ))))
 (list
  (:get-initial-state
   (lambda () (chain this (initialize (@ this props))))
   :initialize
   (lambda (props)
     (funcall inherit this props
	      (lambda (d) (@ d data))
	      (lambda (pd) nil)))
   :designate
   (lambda (item)
     (chain this state data params (md (lambda (data) 
					 (chain data (push (@ item value)))
					 data)))
     (chain this state context methods (grow)))
   :component-will-receive-props
   (lambda (next-props)
     (chain this (set-state (chain this (initialize next-props))))))
  (let ((self this))
    (panic:jsl (:div :class-name "list-interface-holder"
		     ((@ -react-bootstrap -panel)
		      (:div :class-name "panel-heading"
			    (:-select
			     :name "form-select"
			     :value (let ((values (chain self state data params mt mode options
							 (map (lambda (item) (@ item value))))))
				      (getprop (@ self state data params mt mode options)
					       (chain values (index-of (@ self state space)))))
			     :options (chain self state data params mt mode options
					     (map (lambda (item) (create label (@ item title)
									 value (@ item value)))))
			     :on-change (lambda (value) (chain self (designate value))))
			    (:div :class-name "list-info"
				  (if (@ self state data params mt mode removable)
				      (panic:jsl (:span :class-name "remove" 
							:on-click 
							(lambda (event)
							  (chain self props context methods
								 (delete-point 
								  (list (@ self state data params ly)
									(@ self state data params ct)))))
							"X")))
				  (:div :class-name "list-label"
					(+ (@ self state data params pr count)
					   " items")))))
		     (@ self state data content))))))
