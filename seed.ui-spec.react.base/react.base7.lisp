;;; react.base.lisp

(in-package #:seed.ui-spec.react.base)

(defpsmacro handle-actions (action-obj state props &rest pairs)
  (let ((conditions (list :actions-branch-id
			  ; actions to be taken when the branch's id matches one specified
			  (lambda (action-list)
			    `(cond ,@(mapcar (lambda (action)
					       (let ((action-id (first action))
						     (branch-id (second action))
						     (action-content (cddr action)))
						 `((and (= action ,action-id) 
							(= ,branch-id (@ self state data id)))
						   ,@action-content
						   (if action-confirm (action-confirm)))))
					     action-list)))
			  :actions-point
			  (lambda (action-list)
			    `(cond ,@(mapcar (lambda (action)
					       (let ((action-id (first action))
						     (action-content (rest action)))
						 `((and (= action ,action-id) 
							(or (@ state context is-point)
							    (and (@ props meta)
								 (@ props meta is-point))))
						   ,@action-content
						   (if action-confirm (action-confirm)))))
					     action-list)))
			  :actions-point-and-focus
			  (lambda (action-list)
			    `(cond ,@(mapcar (lambda (action)
					       (let ((action-id (first action))
						     (action-content (rest action)))
						 `((and (= action ,action-id)
							;(@ state context in-focus)
							(or (@ state context is-point)
							    (and (@ props meta)
								 (@ props meta is-point))))
						   (if (and (@ state point-attrs props)
							    (@ state point-attrs props meta)
							    (@ state point-attrs props meta if)
							    (@ state point-attrs props meta if interaction)
							    (@ self interactions)
							    (getprop self "interactions"
								     (chain state point-attrs props meta if 
									    interaction (substr 2)))
							    (getprop self "interactions"
								     (chain state point-attrs props meta if
									    interaction (substr 2))
								     ,action-id))
						       (funcall (getprop self "interactions"
									 (chain state point-attrs props meta if 
										interaction (substr 2))
									 ,action-id)
								self (@ state point-data))
						       (progn ,@action-content))
						   (if action-confirm (action-confirm)))))
					     action-list))))))
    `(if ,action-obj
	 (let ((action (@ ,action-obj id))
	       (params (@ ,action-obj params))
	       (action-confirm (@ ,action-obj confirm))
	       (state ,state) (props ,props))
	   ,@(loop for item in pairs when (and (keywordp item) (getf conditions item))
		collect (funcall (getf conditions item)
				 (getf pairs item)))))))

(defpsmacro extend-state (&rest items)
  (let ((deep (eq :deep (first items))))
    (labels ((process-pairs (items &optional output)
	       (if items 
		   (process-pairs (cddr items)
				  (append output (list (first items)
						       `(chain j-query (extend ,@(if deep (list t))
									       (create)
									       (@ self state ,(first items))
									       ,(second items))))))
		   output)))
      `(chain self (set-state (create ,@(process-pairs (if deep (rest items)
							   items))))))))

(defpsmacro subcomponent (symbol data &optional sub-context)
  (let ((context (gensym)))
    `(let* ((sub-con (chain j-query (extend t (create) (@ self state context))))
	    (,context (progn ,@sub-context sub-con)))
       (panic:jsl (,(if (symbolp symbol)
			(intern (string-upcase symbol) "KEYWORD")
			symbol)
		    :data ,data
		    :context ,context
		    :action (if (not (= "undefined" (typeof (@ self act))))
				; the act property is only present at the top-level portal component
				(@ self state action)
				(@ self props action)))))))

(defpsmacro vista (space context fill-by &optional respond-by encloser)
  `(panic:jsl (:-vista
	       :key (+ "vista-" index)
	       :fill ,fill-by
	       :extend-response ,respond-by
	       :enclose ,(if encloser encloser `(lambda (item) item))
	       :data (@ self state data)
	       :space ,space
	       :context ,context
	       :action (if (not (= "undefined" (typeof (@ self act))))
			   ; the act property is only present at the top-level portal component
			   (@ self state action)
			   (@ self props action)))))

(defpsmacro for-data-branch (id branches-list action)
  (let ((val (gensym)) (index (gensym)))
    `(let ((,val nil))
       (loop for ,index in ,branches-list
	  do (if (= (@ ,index id) ,id)
		 (setf ,val (funcall ,action ,index))))
       ,val)))

(defpsmacro cl (&rest items)
  `(chain console (log ,@items)))

(defpsmacro jstr (item)
  `(chain -j-s-o-n (stringify ,item)))

(defmacro extend-rcomps-base ()
  `((defvar cell-components
      (funcall
        (lambda ()
    	  (defvar tr (create))
    	  ;(defvar self this)
    	  (panic:defcomponent (@ tr cell-standard)
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
    					  (+ "content" (if (@ state open) " focus" "")
    					     (funcall
    					      (lambda ()
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
					                                 ; assign both the local and parent state
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
    						     (subcomponent -form-view
    								   (create 
								    id "menu"
								    data (@ self props context menu-content))
    								   ((setf (@ sub-con inert) t
    									  (@ sub-con on-trace) t
    									  (@ sub-con branch)
    									  (@ self props context branch)
    									  (@ sub-con view-scope) "short")))))
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
			       				      ;(extend-state :deep data (create content new-val))
			       				      (chain j-query (extend t (@ self state data content)
			       				  			     new-val))
			       				      (chain self props context methods
			       				  	     (set-delta new-val)))))))
			       		    this))
			       ))))

    	  (panic:defcomponent (@ tr cell-spreadsheet)
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
    				    ; remove the first two characters; since this is a converted
    				    ; keyword, they will always be "__"
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
    			     	      (= "set" (@ self props context mode))) ; TODO: IS THIS THE CORRECT MODE VAR?
    			     	 (panic:jsl (:div :class-name "editor"
    			     			  (:input :class-name "data"
    			     				  :value (@ self state data input-value)
    			     				  :on-change
    			     				  (lambda (val)
    							    (chain self props context methods
    								   (set-delta (@ val target value)))
    							    (extend-state data (create input-value
    										       (@ val target value))))))))
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
    	  tr)))


    (defvar interface-modules
      (funcall
       (lambda ()
    	 (let ((im (create))
    	       (self this))
    	   (panic:defcomponent (@ im bar)
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
					                      ; 1 is added to the branch index to 
					                      ; allow for the point indicator to the right
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
    	   (panic:defcomponent (@ im color-picker)
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
    				       ; TODO: BOTH OF THE BELOW ACTIONS ARE NEEDED
    				       ; TO UPDATE THE VALUE ON THE SERVER AND CLIENT SIDES
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

    	   (panic:defcomponent (@ im select)
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
    					  :value (let ((values (chain self state data content mt if options
    								      (map (lambda (item) (@ item value 0 vl))))))
    						   (funcall (lambda (item)
    							      (create label (@ item title)
    								      value (@ item value)))
    							    (getprop (@ self state data content mt if options)
    								     (chain values 
    									    (index-of (@ self state space))))))
    					  :options (chain self state data content mt if options
    							  (map (lambda (item) (create label (@ item title)
    										      value (@ item value)))))
    					  :on-change (lambda (value) (chain self (designate value)))))))))

    	   (panic:defcomponent (@ im textfield)
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
    	       ;(cl :abc (@ self state))
    	       ;(cl 19 -autosize-textarea 55 -autosize-input)
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
    					                  ;(chain self state context methods (set-mode "set"))
    							  (chain self (set-state (create space 
    											 (@ event target value)))))
    					      :on-blur (lambda (event)
    							 ;(cl :out (@ self state space))
    					                 ;(chain self state context methods (set-mode "move"))
    							 (chain self (designate (@ self state space))))))))))
    	   (panic:defcomponent (@ im textarea)
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
    				      (if (@ self state data content mt if title)
    					  (panic:jsl (:span :class-name "title" 
    							    (@ self state data content mt if title))))
    				      (if (@ self state data content mt if removable)
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
    				       		  (chain self (designate (@ self state space)))))
    				      )))))
    	   (panic:defcomponent (@ im item)
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
    	       (panic:jsl (:div :class-name "list-interface-holder"
    				((@ -react-bootstrap -panel)
    				 (:div :class-name "panel-heading"
    				       (:div :class-name "title" (@ self state data params mt if title))
    				       (if (@ self state data params mt if removable)
    					   (panic:jsl (:span :class-name "remove"
    							     :on-click (lambda (event)
    									 (chain self props context methods
    										(delete-point
    										 (list
    										  (@ self state data params ly)
    										  (@ self state data params ct)))))
    							     "X")))))))))
    	   (panic:defcomponent (@ im list)
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
    		  ;(if (not (= "set" (@ next-props context mode)))
    		  (chain this (set-state (chain this (initialize next-props))))))
    	     (let ((self this))
    	       (cl 919 (@ self state data))
    	       (panic:jsl (:div :class-name "list-interface-holder"
    				((@ -react-bootstrap -panel)
    				 (:div :class-name "panel-heading"
    				       (:-select
    					:name "form-select"
    					:value (let ((values (chain self state data params mt if options
    								    (map (lambda (item) (@ item value))))))
    						 (getprop (@ self state data params mt if options)
    							  (chain values (index-of (@ self state space)))))
    					:options (chain self state data params mt if options
    							(map (lambda (item) (create label (@ item title)
    										    value (@ item value)))))
    					:on-change (lambda (value) (chain self (designate value))))
    				       (:div :class-name "list-info"
    					     (if (@ self state data params mt if removable)
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
    				(@ self state data content)))))
	   
    	   im))))

     (defun inherit (self prop-data process-data map-data)
       (let* ((data (funcall process-data prop-data))
	      (c (@ prop-data context))
	      (is-vista (= "function" (typeof (@ self props fill))))
	      (is-parent-vista (@ c is-vista))
	      (display-vertical (or (and (@ c meta) (= "__y" (@ c meta axis)))
				    (or (= "short" (@ c breadth))
					(= "brief" (@ c breadth)))))
	      (this-index (if (@ c index) (@ c index) 0)) ; add 0 if there's no explicit index 
	      (path (chain c path (concat (list this-index))))
	      (trace (if (< (@ c trace) (@ path length))
			 (chain c trace (concat (list 0)))
			 (@ c trace)))
	      (on-trace (and (@ c on-trace)
			     (or (= (getprop (@ c trace) (1- (@ path length)))
				    (getprop path (1- (@ path length))))
				 ; if no trace information exists beyond the
				 ; path length, presume that the 0-index branch
				 ; is the one to follow to the point
				 (and (< (@ c trace length) (@ path length))
					; make sure trace and path match up to the
					; point where path goes further
					; TODO: ACTUALLY, NOT VALID
				      ;; (= (getprop trace (1- (@ trace length)))
				      ;;    (getprop path (1- (@ trace length))))
					;(= 0 (if (@ c index) (@ c index) 0))
				      ;; (let ((matched true))
				      ;;   (loop for x from (@ c trace length)
				      ;; 	to (1- (@ path length)) do
				      ;; 	  ;; (cl :uu (@ c trace) path 
				      ;; 	  ;;     (getprop path x)
				      ;; 	  ;;     (- (@ path length)
				      ;; 	  ;; 	 (@ c trace length))
				      ;; 	  ;;     (1- (@ path length)))
				      ;; 	  (if (not (= 0 (getprop path x)))
				      ;; 	      (setq matched false)))
				      ;;   (if (< (@ path length) 5)
				      ;; 	 (cl :ma (@ c trace)
				      ;; 	     (@ path) matched
				      ;; 	     (- (@ path length)
				      ;; 			 (@ c trace length))
				      ;; 	     (1- (@ path length))
				      ;; 	     ))
				      ;;   matched)
				      (= 0 (getprop path (1- (@ path length))))))))
	      (is-point (and on-trace (or (= (@ path length) (@ trace length))
					  (not is-vista))))
	      (retracers (if (@ self props enclose)
			     (chain c retracers (concat (list (chain c methods (build-retracer self)))))
			     (@ c retracers)))
	      (orientations (if (@ self props enclose)
				(chain c orientations (concat (list display-vertical)))
				(@ c orientations)))
	      (dont-render false)
	      (new-trace false)
	      (vertical-sequence-matched false)
	      (vertical-sequence-broken false)
	      (context
	       ;; (if (> 5 (@ path length))
	       ;; 	  (cl :tr path c display-vertical (@ c is-parent-vertical)
	       ;; 	      ;trace path (@ c index) (= 0 (getprop path (1- (@ path length)))) c
	       ;; 	      ;(if (@ self state) (@ self state space)) self
	       ;; 	      ;(@ self props context) (@ self state)
	       ;; 	      ;is-vista
	       ;; 	      ;:ont (@ self props context on-trace) on-trace
	       ;; 	      ;:isp (@ self props context is-point) is-point
	       ;; 	      ))
	       (progn (if (and is-point is-parent-vista (@ prop-data action)
			       (= "retrace" (@ prop-data action id)))
			  (progn ;(cl :rr retracers orientations)
				 (loop for x from (1- (@ retracers length)) downto 0 do
					; prevent motion vector from propagating if the orientation
					; switches from vertical to horizontal
				      (if (and (getprop orientations x)
					       (not (= 0 (@ prop-data action params vector 1))))
					  (setq vertical-sequence-matched true))
				      (if (and vertical-sequence-matched (not (getprop orientations x)))
					  (setq vertical-sequence-broken true))
				      (if (and (not new-trace)
					       (not vertical-sequence-broken)
					       (= "function" (typeof (getprop retracers x))))
					  (let ((shift-value (funcall (getprop retracers x)
								      (@ prop-data action params vector)
								      path)))
					    (if (or shift-value (= 0 shift-value))
						(setf new-trace (chain path (slice 0 x) (concat shift-value)))))))
					    ; if the movement vector is negative, once a valid branch has been
					    ; found, run the trace along the highest-numbered downstream branches.
					    ; the indices of the highest-numbered branches are found by running
					    ; the retracers functions from those branches with no argument,
					    ; which should cause them to return the breadth of their rendered
					    ; elements.
				 ;; (if (and (< (@ new-trace length) (@ retracers length))
				 ;; 	     (> 0 (@ prop-data action params vector 0)))
				 ;; 	(chain new-trace (push nil)))
				 
				 
				 ;; TODO: CURRENTLY, THIS ONLY WORKS FOR HORIZONTAL MOVEMENT - ADJUST
				 ;; SO THAT VERTICAL MOTION IS HANDLED AS WELL
		     			;(cl :newt new-trace)
				 (if new-trace (chain c methods (set-trace new-trace)))))
		      (if (and (@ self props meta) (@ self props meta transparent))
			  c (create trace trace
				    path path
				    on-trace on-trace
				    retracers retracers
				    orientations orientations
				    is-point is-point
				    working-system (@ c working-system)
				    movement-transform (if (@ c movement-transform)
							   (@ c movement-transform)
							   (lambda (input) input))
				    index (@ c index)
				    is-vista is-vista
				    dont-render dont-render
				    updated (@ c updated)
				    methods (if (@ self modulate-methods)
						(chain self (modulate-methods (@ c methods)))
						(@ c methods))
				    mode (@ c mode)
				    current (if (not (= "undefined" (typeof (@ c current))))
						(@ c current)
						(and (@ self state)
						     (@ self state context)
						     (= (@ c updated) (@ self state context updated)))))))))
	 (create action (@ prop-data action)
		 action-registered nil
		 data data
		 space (if map-data 
			   (funcall map-data prop-data)
			   data)
		 context context)))

    (defvar interface-components
      (create save (panic:jsl (:span :on-click
				     (lambda ()
				       (chain self context methods 
					      (grow (@ branch id) 
						    (@ branch data) 
						    (create save true))))
				     "save"))))

    (defun generate-vistas (parent)
      (flet ((fill-standard (sub-space)
	       (lambda (self space)
		 (let ((space sub-space))
		   (setf (@ self size) (@ space length))
		   (chain space (map (generate-vistas self))))))
	     (respond-standard (sub-space) (lambda (self space))))
	(lambda (sector index)
	  (let* ((self parent)
		(initial-sector (if (@ sector 0)
				    (if (@ sector 0 mt)
					(@ sector 0)
					(if (= "plain" (@ sector 0 ty 0))
					    (if (@ sector 1)
						(if (@ sector 1 0)
						    (@ sector 1 0)
						    (@ sector 1))
						(@ sector 0))
					    (@ sector 0)))
				    sector))
		(sector-data (@ initial-sector mt))
		;; (sector-space (if (and (@ sector 0)
		;; 		       (@ sector 0 ty)
		;; 		       (= "plain" (@ sector 0 ty 0)))
		;; 		  (chain sector (slice 1))
		;; 		  sector))
		)
	    ;(cl :sc sector initial-sector sector-data)
	    ;(cl :sec sector); sector-space)
	    ;(if transparent (cl 554 index :sec sector (@ parent state context)))
	    (if (and (= "__vista" (@ sector-data if type)))
		(vista sector;-space
		       (let ((ex (create breadth 
					 (if (@ sector-data if breadth)
					     (chain sector-data if breadth (slice 2))
					     "full")
					 parent-breadth 
					 (if (@ parent props context)
					     (@ parent props context breadth))
					 index index
					 meta (@ sector-data if)
					 parent-meta (if (@ parent props context)
							 (@ parent props context meta)))))
			 (chain j-query (extend (create) (@ parent state context) ex)))
		       (if (@ sector-data if fill)
			   (getprop window (chain sector-data if fill (slice 2)))
			   (fill-standard (chain sector (slice 1))))
		       (if (@ sector-data if extend-response)
			   (getprop window (chain sector-data if extend-response (slice 2)))
			   ;(respond-standard (chain sector (slice 1)))
			   (respond-standard sector)
			   )
		       (if (@ sector-data if enclose)
			   (getprop window (chain sector-data if enclose (slice 2)))
			   enclose-blank)))))))

    (defun enclose-blank (self body)
      body)

    (defun enclose-branches-main (self body)
      (panic:jsl (:div :class-name "view" 
		       (:div :class-name "main" 
			     (:div :class-name "branches" 
				   (:-grid (:-row :class-name "show-grid" body)))))))

    (defun enclose-branches-adjunct (self body)
      (panic:jsl (:div :class-name (+ "adjunct-view"
				      (if (= 0 (@ self props context focus))
					  " focus" "")
				      (if (@ self props context is-point)
					  " point" ""))
		       (:div :class-name "status")
		       (:div :class-name (+ "branches" (if (= 1 (@ self props context focus))
							   " focus" ""))
			     body))))

    (defun fill-overview (self space)
      (let ((branch (create data space id "systems")))
	(subcomponent -form-view branch
		      ((setf (@ sub-con index) 0
			     (@ sub-con initial-motion) #(0 -1)
			     (@ sub-con set-control-target)
			     (lambda (index) (chain self (set-state (create control-target index)))))))))
     
    (defun enclose-overview (self body)
      (panic:jsl (:div :class-name (+ "overview" (if (@ self state context on-trace)
						     " point" ""))
		       body (:div :class-name "footer"
				  (if (< 0 (@ self state data branches length))
				      (panic:jsl (:div :class-name "title-container"
						       (:h3 :class-name "title" "seed"))))))))

    (defun fill-main-stage (self space)
      (defvar stuff nil)
      (setf (@ self size) 0)
      (if (< 0 (@ self state data branches length))
	  (chain self state data branches (map (lambda (branch index)
						 (if (= "stage" (@ branch id))
						     (panic:jsl (:div :class-name "stage-content"
								      (funcall (generate-vistas self)
									       ; 0 for the first item in the space
									       (@ branch data 1) 0)))))))))

    (defun fill-branch (self space)
      ;(cl 22 self space)
      ;(cl 21 (@ self state))
      (setf (@ self size) (@ space length))
      (if (= "undefined" (typeof set-interaction))
	  (setq set-interaction (lambda (interaction-name interaction)
				  (setf (getprop interactions interaction-name)
					interaction))))
      (if (= "undefined" (typeof get-interaction))
	  (setq get-interaction (lambda (interaction-name)
				  (getprop interactions interaction-name))))
      (if (= "undefined" (typeof fetch-pane-element))
	  (setq fetch-pane-element (lambda (element)
				     (if element
					 (setf (@ self pane-element) element)
					 (@ self pane-element)))))
      ;(cl :ad (@ self props context meta))
      (let* ((branch (chain self state data branches
	     		    (find (lambda (branch)
	     			    (= (@ branch id) (chain self props context meta branch (substr 2)))))))
	     (index (@ self props context meta ct))
	     (interactions (create))
	     (element-ids (funcall (lambda ()
				     (let ((history-index nil)
					   (cboard-index nil))
				       (chain self props data branches (map (lambda (branch index)
									      (if (= "history" (@ branch id))
										  (setq history-index index))
									      (if (= "clipboard" (@ branch id))
										  (setq cboard-index index)))))
				       (create history-index history-index
					       cboard-index cboard-index)))))
	     ;; (set-interaction (lambda (interaction-name interaction)
	     ;; 			 (setf (getprop interactions interaction-name)
	     ;; 			       interaction)))
	     ;; (get-interaction (lambda (interaction-name)
	     ;; 			(getprop interactions interaction-name)))
	     (visible-branches (chain self state data branches
				      (map (lambda (this-branch index)
					     (cond ((or (= (@ this-branch id) "stage")
							(= (@ this-branch id) "clipboard")
							(= (@ this-branch id) "history"))
						    0)
						   (t 1))))))
	     (visible-branch-count (if (< 0 (@ visible-branches length))
				       (chain visible-branches (reduce (lambda (total i) (+ total i))))
				       1))
	     (flip-axis (lambda (vector) (list (@ vector 1) (- (@ vector 0)))))
	     (portion (chain -math (floor (/ 12 visible-branch-count))))
	     (trace-index (getprop (@ self state context trace) 
				   (@ self state context path length)))
	     (this-index (if (@ self state context on-trace)
			     (if (not (= "undefined" (typeof trace-index)))
				 trace-index 0)
			     -1))
	     (element (cond ((or (not branch)
				 (= (@ branch id) "stage")
				 (= (@ branch id) "clipboard")
				 (= (@ branch id) "history"))
			     nil)
			    ((= (@ branch type 0) "form")
			     (subcomponent -form-view branch
					   ((setf (@ sub-con index) 0
						  (@ sub-con branch-index) index
						  ; TODO: the above only needed for glyph rendering -
						  ; is there a way to obviate?
						  (@ sub-con force-render) t
						  ;(@ sub-con pane-specs) (@ self element-specs)
						  (@ sub-con fetch-pane-element) fetch-pane-element
						  (@ sub-con parent-meta) (@ self props context meta)
						  (@ sub-con retracer) (@ self retrace)
						  (@ sub-con set-interaction) set-interaction
						  (@ sub-con menu-content)
						  (if (and (@ self state branch-modes)
							   (= "menu" (getprop (@ self state branch-modes) index)))
						      (@ self props space 0 mt if contextual-menu format))
						  (@ sub-con history-id)
						  (if (@ element-ids history-index)
						      "history" nil)
						  (@ sub-con clipboard-id)
						  (if (@ element-ids cboard-index)
						      "clipboard" nil))
					    ; cut the trace if the menu is active - prevents
					    ; movement commands from registering in form area
					    ; and menu at the same time
					    (if (and (not (= "undefined" (typeof (@ self state branch-modes))))
						     (= "menu" (@ self state branch-modes 0)))
					    	(setf (@ sub-con on-trace) false)))))
			    ((and (= (@ branch type 0) "matrix")
				  (= (@ branch type 1) "spreadsheet"))
			     (subcomponent -sheet-view branch
					   ((setf (@ sub-con index) 0
						  (@ sub-con parent-meta) (@ self props context meta)
						  (@ sub-con pane-specs) (@ self element-specs)
						  ;(@ sub-con pane-element) (@ self pane-element)
						  (@ sub-con fetch-pane-element) fetch-pane-element
						  (@ sub-con retracer) (@ self retrace)
						  (@ sub-con set-interaction) set-interaction
						  (@ sub-con history-id)
						  (if (@ element-ids history-index)
						      "history" nil)
						  (@ sub-con clipboard-id)
						  (if (@ element-ids cboard-index)
						      "clipboard" nil)))))
			    ((and (= (@ branch type 0) "graphic")
				  (= (@ branch type 1) "bitmap"))
			     (subcomponent -remote-image-view (@ branch data)
					   ((setf (@ sub-con index) index))))
			    ((= (@ branch type 0) "html-element")
			     (subcomponent -html-display (@ branch data)
					   ((setf (@ sub-con index) index))))))
	     (sub-controls (if (not (= "nil" (@ self props context meta secondary-controls format 0 vl)))
			       ; don't display the sub-controls if the value is 'nil', i.e. there's nothing to show
			       (subcomponent -form-view
					     (create id "sub-controls"
						     data (@ self props context meta secondary-controls format))
					     ((setf (@ sub-con view-scope) "short"
						    (@ sub-con index) 1
						    (@ sub-con get-interaction) get-interaction
						    (@ sub-con movement-transform) flip-axis))))))
	;(cl :subc (@ self props context meta secondary-controls format))
	(if element (panic:jsl (:-col :class-name (+ "portal-column " (chain branch type (join " ")))
				      :md portion
				      :key (+ "branch-" index)
				      :id (+ "branch-" index)
				      (:div :class-name (+ "header" (if (@ self state context on-trace)
									" point" ""))
					    (:div :class-name "branch-info"
						  (:span :class-name "id" (@ branch id))
						  (if (= true (@ branch meta locked))
						      (panic:jsl (:span :class-name "locked-indicator"
									"locked")))))
				      (:div :class-name "holder"
					    (:div :class-name "pane"
					          ; TODO: WARNING: CHANGE THIS AND THE
					          ; GLYPH RENDERING BREAKS BECAUSE
					          ; THE FIRST TERMINAL TD CAN'T BE FOUND!
					          ; FIGURE OUT WHY
						  :id (+ "branch-" index "-main")
						  :ref (lambda (ref)
							 (let ((element (j-query ref)))

							   (if (@ element 0)
							       ;; (setf (@ self element-specs)
							       ;; 	     (create height (@ element 0 client-height)
							       ;; 		     width (@ element 0 client-width))
							       ;; 	     ;(@ self pane-element) element
							       ;; 	     )
							       (fetch-pane-element element)
							       ))
							 )
						  element)
					    (:div :class-name (+ "footer horizontal-view" (if (= 1 this-index)
											      " point" ""))
						  (:div :class-name "inner" sub-controls))))))))

    (defun respond-branches-main (self next-props)
      ; toggle the activation of the contextual menu in a branch
      ; the controlShiftMenu action is intercepted here
      ;(cl :space (@ self props data) space rendered)
      ;(cl :resp self)
      (flet ((set-control-target (index)
	       (chain self (set-state (create control-target index)))))
	(if (= "undefined" (typeof (@ self state control-target)))
	    (set-control-target 0))
	(if (and (= "undefined" (typeof (@ self state branch-modes)))
		 (not (= 0 (@ self props data branches length))))
	    (chain self (set-state (create branch-modes (chain self props data branches (map (lambda (branch index)
											       "normal")))))))
	(let ((new-modes (chain j-query (extend #() (@ self state branch-modes)))))
	  (chain next-props data branches
		 (map (lambda (branch index)
			;; ; dismiss the menu when the user interacts with an entry
			;; ; TODO: this logic needs to encompass a lot more use cases
			;; (if (and (= index (@ next-props context index))
			;; 	 (@ next-props action)
			;; 	 (or (= "triggerPrimary" (@ next-props action id))
			;; 	     (= "triggerSecondary" (@ next-props action id))))
			;;     (setf (getprop new-modes index) "normal"))
			; set the branch-mode to menu if the movement vector is rightward
			(if (and (= index (@ next-props context index))
				 (@ next-props action)
				 (= "controlShiftMenu" (@ next-props action id)))
			    (setf (getprop new-modes index) 
				  (if (= 1 (@ next-props action params vector 0))
				      "menu" "normal"))))))
	  (chain self (set-state (create action nil branch-modes new-modes))))))

    (defun fill-branches-adjunct (self space)
      ;(cl :fla self space (@ self state context index))
      ;(cl :fl space)
      (chain space;(@ space 1)
	     (filter (lambda (sector)
		       (let ((branch (chain self state data branches
					    (find (lambda (branch) (= (@ branch id) (@ sector vl)))))))
			 (< 0 (@ branch data length)))))
	     (map (lambda (sector index)
		    (setf (@ self size) (1+ (@ self size)))
		    (let ((branch (chain self state data branches
					 (find (lambda (branch) (= (@ branch id) (@ sector vl))))))
			  (active-index (if (@ self state context on-trace)
					    (if (= (@ self state context path length)
						   (@ self state context trace length))
						0 (getprop (@ self state context trace)
							   (@ self state context path length)))
					    -1)))
		      (chain branch data
			     (map (lambda (item index)
				    (if (= "[object Array]" (chain -object prototype to-string (call item)))
					(chain item (map (lambda (sub index)
							   (if (not (= "undefined" (typeof (@ sub mt))))
							       (setf (@ sub mt if) (create type "__bar"))
							       (progn (setf (@ sub mt) 
									    (create if (create type "__bar")))
								      sub))))))
				    item)))
		      (panic:jsl (:div :class-name (+ "display-" (@ branch id) " view-section"
						      (if (= index active-index) " point" ""))
				       :key (+ "display-" index)
				       (:div :class-name "header"
					     (:div :class-name "branch-info"
						   (:span :class-name "id-char" 
							  (cond ((= "history" (@ branch id)) "●")
								((= "clipboard" (@ branch id)) "■")))))
				       (:div :class-name "content"
					     (subcomponent -form-view branch 
							   ((setf (@ sub-con index) index)))))))))))

     ;; (panic:defcomponent -seed-symbol
     ;; 	 ()
     ;;   (let ((self this)
     ;; 	     (segments (@ this props symbol)))
     ;; 	 (panic:jsl (:span :class-name (+ "seed-symbol" (if (@ this props common) " common" ""))
     ;; 			   (chain (@ this props symbol)
     ;; 				  (map (lambda (item-set set-index)
     ;; 					 (chain item-set
     ;; 						(map (lambda (item index)
     ;; 						       (let ((fl (@ item 0))
     ;; 							     (ll (if (< 1 (@ item length))
     ;; 								     (getprop item (1- (@ item length)))
     ;; 								     "")))
     ;; 							 (panic:jsl
     ;; 							  (:span :key (+ "atom-part-" index)
     ;; 								 :class-name (+ "" (if (= index 0)
     ;; 										       "leading" ""))
     ;; 								 (if (< 0 (@ set-index))
     ;; 								     (panic:jsl (:span :class-name "divider" ".")))
     ;; 								 (:span :class-name "fl" fl)
     ;; 								 (:span :class-name "m"
     ;; 									(chain item (substr 1 (- (@ item length) 
     ;; 												 2))))
     ;; 								 (:span :class-name "ll" ll))))))))))))))
    
    (defun -seed-symbol (props)
      (let ((segments (@ props symbol)))
	(panic:jsl (:span :class-name (+ "seed-symbol" (if (@ props common) " common" ""))
			  (chain (@ props symbol)
				 (map (lambda (item-set set-index)
					(chain item-set
					       (map (lambda (item index)
						      (let ((fl (@ item 0))
							    (ll (if (< 1 (@ item length))
								    (getprop item (1- (@ item length)))
								    "")))
							(panic:jsl
							 (:span :key (+ "atom-part-" index)
								:class-name (+ "" (if (= index 0)
										      "leading" ""))
								(if (< 0 (@ set-index))
								    (panic:jsl (:span :class-name "divider")))
								(:span :class-name "fl" fl)
								(:span :class-name "m"
								       (chain item 
									      (substr 1 (- (@ item length) 
											   2))))
								(:span :class-name "ll" ll))))))))))))))

    (defvar -vista
      (create-react-class 
       (create get-initial-state (lambda () (chain this (initialize (@ this props))))
	       size 0
	       initialize (lambda (props)
			    (let* ((self this)
				   (data (funcall inherit self props
						  (lambda (d) (@ d data))
						  (lambda (pd) (@ pd data)))))
			      (setf (@ data context view-scope)
				    (if (@ props context view-scope)
					(cond ((= "full" (@ props context view-scope))
					       (@ props context breadth))
					      ((= "short" (@ props context view-scope))
					       (if (= "brief" (@ props context breadth))
						   "brief" "short"))
					      ((= "brief" (@ props context view-scope))
					       "brief"))
					(@ props context breadth))
				    (@ data space) (@ props space))
			      data))
	       component-will-receive-props (lambda (next-props)
					      (let ((self this))
						(setf (@ self size) 0)
						(chain this (set-state (chain this (initialize next-props))))
						(chain this props (extend-response this next-props))))
	       render (lambda ()
			(defvar self this)
			(if (or (not (@ this props data))
				(= 0 (@ this props data length)))
			    (panic:jsl (:div))
			    (progn (setf (@ self rendered) (chain self props (fill self (@ self state space))))
				   (panic:jsl (:div :class-name (+ "vista " (@ self props context breadth))
						    (chain self props (enclose self (@ self rendered)))))))))))

     ;; (panic:defcomponent -vista
     ;; 	 (:get-initial-state
     ;; 	  (lambda () (chain this (initialize (@ this props))))
     ;; 	  :size 0
     ;; 	  :initialize
     ;; 	  (lambda (props)
     ;; 	    (let* ((self this)
     ;; 		   (data (funcall inherit self props
     ;; 				  (lambda (d) (@ d data))
     ;; 				  (lambda (pd) (@ pd data)))))
     ;; 	      (setf (@ data context view-scope)
     ;; 		    (if (@ props context view-scope)
     ;; 			(cond ((= "full" (@ props context view-scope))
     ;; 			       (@ props context breadth))
     ;; 			      ((= "short" (@ props context view-scope))
     ;; 			       (if (= "brief" (@ props context breadth))
     ;; 				   "brief" "short"))
     ;; 			      ((= "brief" (@ props context view-scope))
     ;; 			       "brief"))
     ;; 			(@ props context breadth))
     ;; 		    (@ data space) (@ props space))
     ;; 	      data))
     ;; 	  :component-will-receive-props
     ;; 	  (lambda (next-props)
     ;; 	    (let ((self this))
     ;; 	      (setf (@ self size) 0)
     ;; 	      (chain this (set-state (chain this (initialize next-props))))
     ;; 	      (chain this props (extend-response this next-props)))))
     ;;   (defvar self this)
     ;;   (if (or (not (@ this props data))
     ;; 	       (= 0 (@ this props data length)))
     ;; 	   (panic:jsl (:div))
     ;; 	   (progn (setf (@ self rendered) (chain self props (fill self (@ self state space))))
     ;; 		  (panic:jsl (:div :class-name (+ "vista " (@ self props context breadth))
     ;; 				   (chain self props (enclose self (@ self rendered))))))))

    ;;  (defun -vista (props)
    ;;  	 (setf 
    ;; 	  ;; (@ this get-initial-state)
    ;; 	  ;; (lambda () (chain this (initialize props)))
    ;; 	  (@ this size) 0
    ;; 	  (@ this initialize)
    ;; 	  (lambda ()
    ;; 	    (let* ((self this)
    ;; 		   (data (funcall inherit self props
    ;; 				  (lambda (d) (@ d data))
    ;; 				  (lambda (pd) (@ pd data)))))
    ;; 	      (setf (@ data context view-scope)
    ;; 		    (if (@ props context view-scope)
    ;; 			(cond ((= "full" (@ props context view-scope))
    ;; 			       (@ props context breadth))
    ;; 			      ((= "short" (@ props context view-scope))
    ;; 			       (if (= "brief" (@ props context breadth))
    ;; 				   "brief" "short"))
    ;; 			      ((= "brief" (@ props context view-scope))
    ;; 			       "brief"))
    ;; 			(@ props context breadth))
    ;; 		    (@ data space) (@ props space))
    ;; 	      data))
    ;;  	  (@ this component-will-receive-props)
    ;;  	  (lambda (next-props)
    ;; 	    (let ((self this))
    ;; 	      (setf (@ self size) 0)
    ;; 	      (chain this (set-state (chain this (initialize next-props))))
    ;; 	      (chain props (extend-response this next-props))))
    ;; 	  (@ this render)
    ;; 	  (lambda ()
    ;; 	    (defvar self this)
    ;; 	    (cl :ss self)
    ;; 	    (if (or (not (@ props data))
    ;; 		    (= 0 (@ props data length)))
    ;; 		(panic:jsl (:div))
    ;; 		(progn (setf (@ self rendered) (chain props (fill self (@ self state space))))
    ;; 		       (panic:jsl (:div :class-name (+ "vista " (@ props context breadth))
    ;; 					(chain props (enclose self (@ self rendered)))))))))
    ;; 	 (setf (@ this state) (chain this (initialize)))
    ;; 	 (cl :vv this))
    
    ;; (setf (@ -vista prototype) (chain -object (create (@ -react -component prototype)))
    ;; 	  (@ -vista prototype constructor) -vista)

     (panic:defcomponent -portal
	 (:get-initial-state
	  (lambda ()
	    ;(cl :abc (@ this props data))
	    (let* ((self this)
		   (this-date (new (-date)))
		   (modes (list "move" "set"))
		   (data (for-data-branch "systems" (@ self props data)
					  (lambda (item)
					    (let ((systems nil))
					      (loop for datum in (@ item data 1)
						 do (if (and (= "[object Array]" (chain -object prototype to-string 
											(call datum)))
							     (@ datum 0 mt)
							     (@ datum 0 mt if)
							     (= "__portalSpecs" (@ datum 0 mt if name)))
							(setq systems 
							      (create branches #()
								      portal-name (@ datum 0 vl)
								      systems (@ datum 1)
								      working-system nil))))
					      systems))))
		   (space (for-data-branch "systems" (@ self props data)
					   (lambda (item) (chain item data (slice 1)))))
		   (gen-methods
		    (funcall 
		     (lambda (self)
		       (lambda ()
			 (create grow (lambda (branch-id data params callback)
					(chain self (transact "grow" 
							      (list (@ self state context working-system)
								    branch-id data params)
							      (if (not (= "undefined" (typeof callback)))
								  (funcall callback)))))
				 build-retracer (@ self build-retracer)
				 set-mode (@ self set-mode)
				 load-branch (@ self fill)
				 set-trace (@ self set-trace))))
		     this)))
	      ;(cl 333 (@ self props data))
	      (create data data
		      space space
		      is-portal t
		      point 0
		      mark nil
		      action nil
		      context (create trace
				      #(0 0)
				      on-trace t
				      path #()
				      retracers (list (@ self retrace))
				      orientations (list false)
				      methods (gen-methods)
				      mode (@ modes 0)
				      updated (chain this-date (get-time)))
		      ui (create modes modes
				 listeners (funcall (lambda ()
						      (let ((listeners (create)))
							(loop for mix from 0 to (1- (@ modes length))
							   do (setf (getprop listeners (getprop modes mix))
								    (new (chain window -keypress (-listener)))))
							listeners)))))))
	  :build-retracer
	  (lambda (self)
	    (lambda (primal-vector)
	      (let* ((display-vertical (or (and (@ self props context meta)
						(= "__y" (@ self props context meta axis)))
					   (not (= "full" (@ self state context view-scope)))))
		     (vector (if display-vertical
				 (chain (list (- (@ primal-vector 1)) (@ primal-vector 0))
					(concat (chain primal-vector (slice 2))))
				 primal-vector))
		     (path (chain self state context path (concat (list (@ self props context index)))))
		     (current-point (if (getprop (@ self state context trace) (1- (@ path length)))
					(getprop (@ self state context trace) (1- (@ path length)))
					0))
		     (new-point (+ current-point (@ vector 0)))
		     (count-vistas (lambda ()
				     (if (not (@ self state space)) 0
					 (chain self state space (slice 1)
						(map (lambda (item index)
						       (let ((index-item (if (= "[object Array]" 
										(chain -object prototype to-string 
										       (call item)))
									     (@ item 0) item)))
							 (and index-item (@ index-item mt) (@ index-item mt if)
							      (= "__vista" (@ index-item mt if type))))))
						(reduce (lambda (total this-item)
							  (+ total (if this-item 1 0)))))))))
		
		(if (and (= 0 (@ vector 1))
			 (not (= 0 (@ vector 0)))
			 ; check whether space is subdivided into plain lists; if so, one should be subtracted
			 ; from the space length since the space will have a plain list at its beginning that
			 ; pads its length by one. TODO: this is clumsy, is there a better way to determine the
			 ; navigable area within vistas?
			 (< -1 new-point
			    (@ self size)
			    ;; (+ (if (and (@ self state space 1)
			    ;; 		(@ self state space 1 0)
			    ;; 		(@ self state space 1 0 ty)
			    ;; 		(= "plain" (@ self state space 1 0 ty 0)))
			    ;; 	   -1 0)
			    ;;    (@ self state space length))
			    ;(count-vistas)
			    ))
		    ; set the upper bound to the space length - 1, since one member of the space is always a
		    ; plain-list initial marker
		    new-point false))))
	  :retrace
	  (lambda (vector)
	    ; in this retrace function, the point is *** SOMETHING
	    (let* ((self this)
	    	   (path (chain self state context path (concat (list (@ self state context index)))))
	    	   (current-point (if (getprop (@ self state context trace)
	    				       (1- (@ path length)))
	    			      (getprop (@ self state context trace)
	    				       (1- (@ path length)))
	    			      0))
	    	   (new-point (+ (@ vector 0)
	    			 current-point)))
	      ;(cl :ccr current-point new-point (@ self state space) (@ self rendered))
	      (if (< -1 new-point (@ self state space length))
	    	  new-point false)))
	  :component-did-mount
	  (lambda ()
	    (loop for mix from 0 to (1- (@ this state ui modes length))
	       do (chain (getprop (@ this state ui listeners) (getprop (@ this state ui modes) mix))
			 (register_many (funcall (getprop keystroke-maps (getprop (@ this state ui modes) mix))
						 this)))
		 (chain (getprop (@ this state ui listeners) (getprop (@ this state ui modes) mix))
			(stop_listening)))
	    (setf (@ window kls) (@ this state ui listeners))
	    ; activate the "move" mode by default
	    (chain (@ this state ui listeners move)
		   (listen)))
	  :set-trace
	  (lambda (new-trace)
	    ;(cl :newtrace (@ this state context trace) new-trace)
	    (let ((self this))
	      (chain self (set-state (create action nil
					     context (chain j-query (extend (create)
									    (@ self state context)
									    (create trace new-trace))))))))
	  :set-mode
	  (lambda (mode)
	    (defvar self this)
	    (defvar this-date (new (-date)))
	    ; TODO: the set-state must be done with a function so that the mode and action are set
	    ; at the same time
	    (chain this (set-state (lambda (previous-state current-props)
				     (let ((found false)
					   (new-state
					    (create context
						    (chain j-query
							   (extend (create) (@ previous-state context)
								   (create mode
									   (getprop (chain (@ self state ui modes)
											   (sort (lambda (a b)
												   (= b mode))))
										    0))))
						    action nil)))
				       (if (not (= -1 (chain (@ self state ui modes) (index-of mode))))
					   (loop for mix from 0 to (1- (@ self state ui modes length))
					      do (if (= mode (getprop (@ self state ui modes) mix))
						     (chain (getprop (@ self state ui listeners)
								     (getprop (@ self state ui modes) mix))
							    (listen))
						     (chain (getprop (@ self state ui listeners)
								     (getprop (@ self state ui modes) mix))
							    (stop_listening)))))
				       new-state)))))
	  :act
	  (lambda (id params)
	    (chain this (set-state (lambda () (create action (create id id params params))))))
	  :transact
	  (lambda (portal-method params callback)
	    (defvar self this)
	    ;; (chain console (log "par" params
	    ;; 			(chain (list (@ window portal-id) portal-method)
	    ;; 			       (concat params))))
	    (chain j-query
		   (ajax (create 
			  url "../portal"
			  type "POST"
			  data-type "json"
			  content-type "application/json; charset=utf-8"
			  data (chain -j-s-o-n (stringify (chain (list (@ window portal-id) portal-method)
								 (concat params))))
			  success
			  (lambda (data)
			    (defvar this-date (new (-date)))
			    ;(chain console (log "DAT2" data (@ self state data) (@ self state)))
			    ;(chain console (log "DAT2" (chain -j-s-o-n (stringify data))))
			    (chain self (set-state (lambda (previous-state current-props)
						     (create
						      data ; TODO: REPLACE SELF STATE BELOW WITH PREVIOUS-STATE
						      (chain j-query (extend (create) (@ self state data)
									     (create branches data)))
						      action nil
						      context
						      (chain j-query
						      	     (extend (create) (@ self state context)
						      		     (create updated (chain this-date 
											    (get-time)))))))))
			    (if callback (callback)))
			  error (lambda (data err) (chain console (log 11 data err)))))))
	  :fill
	  (lambda (system-id)
	    (defvar self this)
	    (chain this (set-mode "move"))
	    (chain this (load-branch-data
			 system-id
			 (lambda (data)
			   (let ((this-date (new (-date))))
			     ; when the system is loaded, set the trace to #(1), pointing to the first branch
			     (chain self (set-state (create data (chain j-query (extend (create) (@ self state data)
											(create branches data)))
							    context
							    (chain j-query
								   (extend (create) (@ self state context)
									   (create updated
										   (chain this-date (get-time))
										   trace #(1))))))))))))
	  :load-branch-data
	  (lambda (system-id callback)
	    (let ((self this))
	      (extend-state context (create working-system system-id))
	      (chain j-query
		     (ajax (create
			    url "../portal"
			    type "POST"
			    data-type "json"
			    content-type "application/json; charset=utf-8"
			    data (chain -j-s-o-n (stringify (list (@ window portal-id) "grow" system-id)))
			    success (lambda (data)
				      ;(chain console (log "DAT1" data))
				      (callback data))
			    error (lambda (data err) (chain console (log 11 data err))))))))
	  ;; :should-component-update
	  ;; (lambda (next-props next-state)
	  ;;   (or (@ next-state just-updated)
	  ;;   	(and (@ this state context in-focus)
	  ;; 	     ; don't update if an action was received, since the
	  ;; 	     ; props are always repropagated after the action is completed and nullified
	  ;;   	     (and (not (@ this state action))
	  ;; 		  (@ this state context is-point)))))
	  :component-did-update
	  (lambda ()
	    (defvar self this)
	    ; actions at the portal level are handled with the did-update method
	    ; since it does not receive a props update upon command execution
	    (handle-actions (@ self state action) (@ self state) (@ self props)
	  		    :actions-point-and-focus
	  		    (("move" (chain self (set-state (create action nil)))
				     (chain self (move (@ params vector))))))))
       ;(cl 234 (jstr (@ this state context)) (@ this state context))
       ;(chain this (build-retracer 0 (create breadth "full") (@ this state space)))
       ;(cl 888 (@ this state) (chain this (build-retracer 0 (create breadth "full") (@ this state space))))
       ;(cl 921 (@ this props) (@ this state) (@ this state space))
       (let* ((self this))
	 ;(cl :5sp (@ this state space) (@ this state data))
	 (panic:jsl (:div :class-name "portal" (chain this state space (map (generate-vistas self)))
			  (if (= 0 (@ this state data branches length))
			      (panic:jsl (:div :class-name "intro-animation"
					       (:div :class-name "animation-inner"
						     (funcall (lambda ()
								(loop for n from 0 to 11 collect
								     (panic:jsl (:div :key (+ "sc-" n)
										      :id (+ "star-caster-" n)))))))
					       (:h3 :class-name "title" "seed"))))))))

     (panic:defcomponent -glyph-display
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
		    ; add 3 or subtract 3 for the margin beneath the table TODO a more elegant way to do this? x
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
       ;(chain console (log "RE" (@ self state just-updated)))
       ;(cl 88 (jstr (chain -object (keys (@ self props table-refs)))) (@ self props glyphs))

       (defun render-glyph (points con-height xos yos next-line nexcon-height next-xos next-yos is-last is-root)
	 (let* ((height-factor (+ 1 (@ (j-query (+ "#branch-" (@ self props data branch-index)
						   "-" (@ self props data branch-id)
						   " table.form tbody tr:first-child td:last-child"))
				       0 client-height)))
		; take the height factor from the first single-height cell
		; TODO a better way to find it? search for first cell with rowspan=1? x
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
		     ; don't plot the last point if this is the last line in the glyph and isn't connected
		     ; to a glyph below it, so the "tail" is not left hanging. The only exception is for
		     ; the root glyph, whose tail extends to the edge of the pane
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
	     ;(cl :scc (@ this state data succession))
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
									   (= index
									      (1- (@ (getprop (@ self state space) 
											      glix) length)))
									   (= glix
									      (@ self props data base-atom))
									   )))))))))))
			 ;; (chain console (log 100 glix origin (chain (j-query (getprop (@ self props table-refs) 
			 ;; 				       (+ "a" glix))) (offset-parent) (attr "class"))
			 ;; 		     ))
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
	     ;(chain (j-query ".dendroglyphs") (html ""))
	     (panic:jsl (:svg :class-name "dendroglyphs"
			      :id (+ "dend" (new (chain (-date) (get-time))))
			      :style (create height (+ (@ self state dims 1) "px")
					     width (+ (@ self state dims 0) "px"))
			      :ref (+ "formTable-" (@ self state data branch-id))
			      display)))
	   (panic:jsl (:svg :class-name "dendroglyphs"))))

     (panic:defcomponent -form-view
	 (:get-initial-state
	  (lambda ()
	    (chain j-query (extend (create point (if (= "full" (@ this props context view-scope))
						     #(0 0) #(0))
					   point-attrs (create index 0 value nil delta nil start 0 fresh t
							       depth 0 breadth 1 path #() props #())
					   point-data nil
					   index -1
					   focus (create meta 0
							 macro 0)
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
				   (lambda (d)
				     (chain j-query (extend (@ props data) (@ d data))))
				   (lambda (pd) (@ pd data data)))))
	      ;; (if (and (@ props data meta)
	      ;; 	       (@ self state)
	      ;; 	       (@ self state point-attrs)
	      ;; 	       (not (= "undefined" (typeof (@ props data meta point-to))))
	      ;; 	       (not (= "full" (@ props context view-scope))))
	      ;; 	  (setf (@ state point-attrs)
	      ;; 		(chain j-query (extend (@ self state point-attrs)
	      ;; 				       (create index (@ props data meta point-to))))))
	      ; TODO: copy of point-to was eliminated here to prevent paradoxes; see if it's not needed
	      (if (@ self props context set-interaction)
		  (progn (chain self props context
				(set-interaction "commit" (lambda ()
							    (chain state context methods
								   (grow #() (create save true))))))
			 (chain self props context
				(set-interaction "revert" (lambda ()
							    (chain state context methods
								   (grow #() (create revert true))))))))
	      state))
	  :modulate-methods
	  (lambda (methods)
	    (let ((self this))
	      (chain j-query 
		     (extend (create set-delta (lambda (value) (extend-state point-attrs (create delta value)))
				     set-point (lambda (datum)
						 (chain self (set-point (list (@ datum ly) (@ datum ct)))))
				     delete-point (lambda (point) (chain self (delete-point point))))
			     methods
			     (create grow
				     (lambda (data meta alternate-branch)
				       (let ((space (let ((new-space (chain j-query
									    (extend #() (@ self state space)))))
						      (chain self (assign (@ self state point-attrs index)
									  new-space data)))))
					 (chain methods
						(grow (if (= "undefined" (typeof alternate-branch))
							  (@ self state data id)
							  alternate-branch)
						      ; TODO: it may be desirable to add certain metadata to 
						      ; the meta for each grow request, that's what the 
						      ; derive-metadata function below may later be used for
						      space meta))))
				     grow-branch
				     (lambda (space meta callback)
				       (chain methods (grow (@ self state data id) 
							    space meta callback))))))))
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
	  (create select-system
		  (create click (lambda (self datum)
				  (chain self (set-state (create index (@ datum ix))))
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
		  commit 
		  (create click (lambda (self datum)
				  (funcall (chain self props context (get-interaction "commit"))))
			  trigger-primary (lambda (self datum)
					    (funcall (chain self props context (get-interaction "commit"))))
			  trigger-secondary (lambda (self datum)
					      (funcall (chain self props context (get-interaction "commit")))))
		  revert 
		  (create click (lambda (self datum)
				  (funcall (chain self props context (get-interaction "revert"))))
			  trigger-primary (lambda (self datum)
					    (funcall (chain self props context (get-interaction "revert"))))
			  trigger-secondary (lambda (self datum)
					      (funcall (chain self props context (get-interaction "revert")))))
		  insert
		  (create
		   click
		   (lambda (self datum)
		     (let* ((branch (@ self props context branch))
			    (new-space (chain j-query (extend #() (@ branch state space)))))
		       (chain branch (seek (@ branch state point) (@ branch state point 0) new-space
					   (lambda (target target-list target-parent target-index path)
					     ;(cl :form (@ datum mt format) target-parent)
					     ;(chain target-parent (splice target-index 0 (@ datum mt format)))
					     (setf (getprop target-parent target-index)
						   (@ datum mt format)))))
		       (chain branch state context methods (grow new-space))))
		   trigger-primary
		   (lambda (self datum)
		     (let* ((branch (@ self props context branch))
			    (new-space (chain j-query (extend #() (@ branch state space)))))
		       (chain branch (seek (@ branch state point) (@ branch state point 0) new-space
					   (lambda (target target-list target-parent target-index path)
					     ;(cl :form (@ datum mt format) target-parent)
					     ;(chain target-parent (splice target-index 0 (@ datum mt format)))
					     (setf (getprop target-parent target-index)
						   (@ datum mt format)))))
		       (chain branch state context methods (grow new-space))))
		   ))
	  :set-focus
	  (lambda (key value)
	    (let ((self this)
		  (new-object (chain j-query (extend (create) (@ self state focus)))))
	      (setf (getprop new-object key)
		    (min 1 (max 0 value)))
	      (extend-state focus new-object)))
	  :shift-focus
	  (lambda (key vector)
	    (let ((self this)
		  (new-object (chain j-query (extend (create) (@ self state focus)))))
	      (setf (getprop new-object key)
		    (min 1 (max 0 (+ (getprop (@ self state focus) key)
				     (@ vector 0)))))
	      (extend-state focus new-object)))
	  :set-point
	  (lambda (target path)
	    ;(if (= nil target) (cl :nil (@ this state) (@ this props)))
	    (let ((self this)
		  (path (if path path (list (@ target ly) (@ target ct)))))
	      ;(cl :set (list (@ target ly) (@ target ct) (@ target dp)) target)
	      (if target ; just in case a null target is passed, which shouldn't happen
		  (progn (chain self (set-state (create point (if (= 2 (@ self state point length))
					                          ; assign the point depending on this form's
					                          ; spatial dimensions
								  (list (@ target ly) (@ target ct))
								  (list (@ target ct)))
							point-data target
							action-registered t
					                ; need to set this so that component updates
							point-attrs
							(chain j-query (extend (create)
									       (@ self state point-attrs)
									       (create index (@ target ix)
										       fresh false
										       props
										       (chain
											j-query
											(extend t (create)
												(@ target pr)))
										       value (if (@ target vl)
												 (@ target vl)
												 nil)
										       path path
										       start (@ target ct)
										       atom-macros
										       (if (@ target am)
											   (@ target am)
											   #())
										       form-macros
										       (if (@ target fm)
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
						 (/ (@ self state pane-element 0 client-height)
						    2)))
					(if (> (@ self state pane-element 0 scroll-top)
					       (getprop (@ self element-specs) (@ target ix) "top"))
					    (setf (@ self state pane-element 0 scroll-top)
						  (- (getprop (@ self element-specs) (@ target ix) "top")
						     (/ (@ self state pane-element 0 client-height)
							2)))))))))))
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
  		            ; axis is inverted, hence < instead of >
	  		    do (setf (@ to-seek 1) (max 0 (if (> 0 (@ motion 1))
							      (+ (@ self state point-attrs start)
								 (@ self state point-attrs breadth))
							      (1- (@ self state point-attrs start))))))
			 ;(cl :m0 (@ to-seek 0) (@ self state point-attrs depth) (@ self state point 0))
			 ;(cl :tos to-seek)
			 (chain self (seek to-seek (@ to-seek 0) nil
					   (lambda (target list parent index path)
					     ;; (cl :ta (if (= 0 (@ motion 0))
					     ;; 		 (@ self state point-attrs depth)
					     ;; 		 (if (> 0 (@ motion 0))
					     ;; 		     (+ (@ motion 0)
					     ;; 			(@ target ly))
					     ;; 		     (+ (@ motion 0)
					     ;; 			(@ self state point-attrs
					     ;; 				depth)))))
					     (let ((new-target
						    (chain j-query
							   (extend (create)
								   target
								   (create dp (if (= 0 (@ motion 0))
										  (@ self state point-attrs depth)
										  (if (> 0 (@ motion 0))
										      (@ target ly)
										      (max (+ (@ motion 0)
											      (@ self state
												      point-attrs
												      depth))
											   (@ target ly)))))))))
					       ;(cl :tr motion (@ new-target dp) (@ new-target ly) new-target)
					       ; extend the target data so that the layer is set as the sought
					       ; x-coordinate as long as the point is moving vertically or inward. x
					       ; thus, the layer will remain the same when moving vertically,
					       ; preventing it from being knocked down to a low level when
					       ; traversing shallow lists, and the point will always decrement
					       ; to the layer previous to the visible point. x
					       (chain self (set-point new-target path)))))))
		  (let ((target-index (+ (getprop (@ self state point) (1- (@ self state point length)))
					 (- (@ motion 1)))))
		    ; don't seek if the target index is less than 0
		    ; this is impossible and causes an infinite loop
		    (if (<= 0 target-index)
			(chain self (seek (list target-index)
					  -1 nil (lambda (target list parent index path)
						   (chain self (set-point target path))))))))))
	  ;:seek-counter 0
	  :seek
	  (lambda (coords layer form callback path)
	    ;(setf (@ this seek-counter) (1+ (@ this seek-counter)))
	    ;(if (< (@ this seek-counter) 25)
		(let ((self this) 
		      (path (if path path #()))
		      (form (if form form (chain this state space (slice 1))))
		      (index (getprop coords (1- (@ coords length))))
		      (found-form nil) (member-start 0) (form-index 0) (at-end false) (this-end false))
					;(if (@ self props context ii) (cl :fr form))
					; don't seek if there's nothing in the form
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
					;(cl found-form at-end layer)
			(if (and (not at-end)
				 (not (= 0 layer)))
					; if the layer > 0, this is a 2D form and there may be more layers below this one
					; if the layer < 0, this is a 1D form with a starting layer of -1
			    (chain this (seek coords (1- layer) found-form callback path))
			    (if found-form
				(funcall callback
					 (if (= "[object Array]" (chain -object prototype to-string (call found-form)))
					     (@ found-form 0)
					     found-form)
					 (if (= "[object Array]" (chain -object prototype to-string (call found-form)))
					     found-form)
					 form form-index path)))))));)
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
	    ; TODO: the property and sub-property system is convoluted, try to simplify it...
	    (loop for fix from 0 to (1- (@ form length))
	       do (if (= "[object Array]" (chain -object prototype to-string (call (getprop form fix))))
		      (chain this (assign index (getprop form fix) changed))
		      (if (= index (@ (getprop form fix) ix))
			  (setf (getprop form fix)
				(chain j-query (extend (getprop form fix) changed))))))
	    form)
	  :build
	  (lambda (state)
	    (defvar self this)
	    (let* ((new-space (chain j-query (extend #() (@ state space)))))
	      ; the element-specs are set to nil whenever the table is rebuilt
	      ; so that new coordinates may be sent to the glyph-drawing component
	      ;(cl :aa (@ self state point-attrs index))
	      (setf (@ self element-specs) #())
	      ;(cl :nw new-space)
	      (chain self
	      	     (build-form new-space
				 (lambda (meta state)
				   (cl :ns new-space)
				   (chain self (set-state (chain j-query
	      			    				 (extend state
	      			    					 (create space new-space
	      			    						 rendered-content2 (@ meta output)
	      			    						 point-attrs (@ state point-attrs)
	      			    						 meta (chain
	      			    						       j-query
	      			    						       (extend t (create)
	      			    							       (@ self state 
	      			    								       data meta)
	      			    							       meta))))))))))))
	  :build-form
	  (lambda (data callback meta state)
	    (let* ((self this)
		   (each-meta (create))
		   (is-start (= "undefined" (typeof meta)))
					; is this the beginning of the form?
		   (meta (if meta meta (create succession #() max-depth 0 output #())))
		   (state (if state state (create row 0 column 0)))
		   (last-index nil)
		   (context-begins false)
		   (is-plain-list (= "plain" (@ data 0 ty 0)))
		   (increment-breadth (lambda (number) (setf (@ data 0 br) (+ (if (or number (= 0 number))
										  number 1)
									      (@ data 0 br))
							     (getprop meta "breadth")
							     (@ data 0 br)))))
	      (if is-plain-list (cl :mn (@ data 0)))
	      (if (@ data 0)
	  	  (progn (setf (@ data 0 br) 0
			       (@ data 0 sl) 0)
			 ; breadth is initially 0, as is the list of sub-lists
			 (if (and (@ data 0 fm) (< 0 (@ data 0 fm length)))
	  		     (setf (@ state reader-context) (chain data 0 fm)
	  			   (@ meta context-start) (@ data 0 ix)
	  			   context-begins true))
			 ; handle reader macros for forms
	  		 (if (and (@ data 0 am) (< 0 (@ data 0 am length)))
	  		     (setf (@ state reader-context) (@ data 0 am)
	  			   (@ meta context-start) (@ data 0 ix)
	  			   context-begins true))
			 ; handle reader macros for atoms
	  		 (if (@ data 0 mt)
	  		     (progn (setf (@ data 0 pr) (create meta (@ data 0 mt)))
	  			    (if (@ data 0 mt if)
	  				(setf (@ data 0 md) (lambda (fn) (setf data (funcall fn data)))
	  				      (@ data 0 pr count) (1- (@ data length))))
	  			    (if (@ data 0 mt each)
	  				(setf each-meta (@ data 0 mt each)
	  				      (@ data 0 pr meta) (chain j-query (extend t (create)
	  										(@ data 0 mt each)
	  										(@ data 0 pr meta)))))))
			 ; assign atom properties from metadata
	  		 (setf (@ data 0 ct) (@ state row)
	  		       (@ data 0 ly) (max 0 (1- (@ state column)))
	  		       (@ data 0 cx) (if context-begins
	  		       			 (chain state reader-context (concat (list "start")))
	  		       			 (@ state reader-context)))
			 ; assign column, row and reader macro content
			 ;; (if (and (@ data 0 mt)
			 ;; 	  (@ data 0 mt if)
			 ;; 	  (= "__item" (@ data 0 mt if type)))
			 ;;     (progn (setf (@ data 0 cont)
			 ;; 		  (chain data (slice 1))
			 ;; 		  (@ data 0 br) 1)
			 ;; 	    ;(setf data (list (@ data 0)))
			 ;; 	    (if (= "undefined" (typeof (getprop meta "output" (@ state row))))
			 ;; 		(setf (getprop meta "output" (@ state row))
			 ;; 		      #()))
			 ;; 	    (chain (getprop meta "output" (@ state row))
			 ;; 		   (push (@ data 0)))
			 ;; 	    ;(cl :nd (list (@ data 0)))
			 ;; 	    )
	  		 (chain data
	  			(map (lambda (datum index)
	  			       (if (and (= 1 index)
						(not is-plain-list))
	  				   (setf (@ state column) (1+ (@ state column))))
				       ; increment the column, but not for plain lists
	  			       (if (> (1+ (@ state column))
				       	      (@ meta max-depth))
	  			       	   (setf (@ meta max-depth) (1+ (@ state column))))
				       ; increment the maximum depth
	  			       (if (= "[object Array]" (chain -object prototype to-string (call datum)))
					   ; if this item is a list
	  				   (progn
					     (if (= "plain" (@ datum 0 ty 0))
					         ; add the length of the sub-list, minus the first element,
					         ; to the total length of this list's sub-lists
						 (progn
						   (cl :plt datum)
						   (setf (@ data 0 sl) (+ (@ data 0 sl)
									(- (@ datum length) 2)))))
	  				     (if (and (or (and is-plain-list (< 0 index))
							  ; start incrementing right away in plain lists,
							  ; like the main form list
							  (< 1 index))
						      (not (and is-plain-list (= 1 index))))
	  					 (setf (@ state row) (1+ (@ state row))))
					     ; increment the row, but not if this is the form at the beginning of
					     ; a plain list and this is not the plain list that encloses the
					     ; whole form; i.e. isStart is not true
					     (if (or last-index (= 0 last-index))
						 (setf (getprop meta "succession" last-index)
						       (@ datum 0 ix)))
					     (setf last-index (@ datum 0 ix))
					     ; set succession data for drawing glyphs
	  				     (chain self (build-form
							  datum (lambda (output sub-state)
								  ;; (cl :io (@ data 0) ;state sub-state
								  ;;     datum
								  ;;     (@ data 0 br)
								  ;;     (and (not is-start)
								  ;; 	   (= "plain" (@ datum 0 ty 0))))
								  (cl :out output)
								  (if (and (not is-start)
									   (= "plain" (@ datum 0 ty 0)))
								      ;(setf (@ data 0 br) 1)
								      (increment-breadth)
								      ;; (increment-breadth (1+ (- (@ sub-state row)
								      ;; 				(@ state row))))
								      (increment-breadth (@ output breadth)))
								  ; increment the breadth based on the difference
								  ; between the current row and the row reached
								  ; within the sub-list
								  (setf (@ state row) (+ (@ sub-state row))))
							  meta (chain j-query (extend (create) 
										      state (if is-plain-list
												(create)
												(create)))))))
					; if this item is an atom
	  				   (let ((pr (chain j-query 
	  						    (extend t (create)
	  							    (create meta (chain j-query 
	  										(extend (create)
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
	  				           ; concatenate macro styles if the atom
	  				           ; is within an existing macro
	  					   (@ datum cx) (if (@ datum am)
	  							    (if (@ state reader-context)
	  								(chain state reader-context
	  								       (concat (list (@ datum am) "start")))
	  								(list (@ datum am) "start"))
	  							    (@ state reader-context)))
					     ; increment the column if the list head is a plain list marker
					     ; and this is not the plain list that encloses the form;
					     ; this ensures that the elements within the plain list will have
					     ; their layers correctly marked. x
					     (if (and (not is-start)
						      (= "plain" (@ datum ty 0)))
					     	 (setf (@ state column) (1+ (@ state column))))
					     ; push datum to output array; the index is incremented because
					     ; the indices start with 0 but the array indices start with 1
	  				     (if (= "undefined" (typeof (getprop meta "output" (@ state row))))
	  					 (setf (getprop meta "output" (@ state row))
	  					       #()))
	  				     (chain (getprop meta "output" (@ state row))
	  					    (push datum))))))) ;)
	  		 (funcall callback meta state)))))
	  :build-list
	  (lambda (data atom-builder form-builder callback output)
	    (let ((self this)
		  (datum (@ data 0))
		  (output (if output output #())))
	      ;(cl :build output)
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
	    ;(defvar bla (@ cell-components cell-standard))
	    ;(cl :aa (@ datum ix) datum)
	    ;(if (null (@ self state start))
	    ;    (chain self (set-state (create start (@ datum ix)))))
	    ;(cl :A (@ datum vl) (@ datum br))
	    (panic:jsl (:div :key (+ "form-view-td-" (@ datum ix))
			     :on-click (lambda ()
			     		 ; if this cell does not have a custom interface, set it as point
			     		 ; when clicked, cells with custom interfaces have unique behaviors
			     		 ; implemented using the set-point method as passed through
			     		 ; the modulate-methods function in this component
			     		 (let ((interaction (if (and (@ datum pr)
								     (@ datum pr meta)
								     (@ datum pr meta if)
								     (@ datum pr meta if interaction))
								(getprop (@ self interactions)
									 (chain datum pr meta if interaction 
										(substr 2))
									 "click"))))
			     		   (if interaction
			     		       (funcall interaction self datum)
			     		       (let ((datum (chain j-query
								   (extend (create)
									   datum (create dp (@ datum ly))))))
						 (chain self (set-point datum))))))
			     :id (+ (@ self state data id)
				    "-atom-" (@ datum ix))
			     :class-name (+ "atom-inner"
			    		    ;; (+ " mode-" (@ self state context mode))
			    		    ;; (+ " row-" (@ datum ct))
					    ; TODO: IS THERE A BETTER WAY TO HANDLE POINTS IN LISTS VS. FORMS?
					    ; SUCH AS HAVING THE POINT DESIGNATION WORK IN A MORE SIMILIAR WAY FOR
					    ; BOTH TYPES
					    (+ " ot-" (@ self state point-attrs index))
					    (if (= (@ self state point-attrs index)
						   (@ datum ix))
						" point" "")
					    (if (= (@ self state index) (@ datum ix))
						" index" "")
					    (if (and (@ datum mt)
						     (@ datum mt if))
						(cond ((or (= "__portalName" (@ datum mt if type))
							   (and (@ datum mt atom)
								(= "__portalName" (@ datum mt atom if type))))
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
					                        ; only use the delta value if the state is
					                        ; "set"
					                        ; TODO: this causes flickering
					                        ; HOW TO PREVENT FLICKERING
					                        ; make sure the action is "recall"
							       (= (@ self state point-attrs index)
								  (@ datum ix)))
							  (@ self state point-attrs delta)
							  datum);)
						      meta (create branch-id (@ self state data id)
								   is-point (= (@ self state point-attrs index)
									       (@ datum ix))
								   is-parent-point (@ self state context is-point)
								   breadth (@ datum br)))))
			       ;; (if (and (@ datum mt) (@ datum mt if)
			       ;; 		(= "__bar" (@ datum mt if type)))
			       ;; 	   (cl :celd cell-data datum (@ self state point-attrs)))
			       (if (and (@ datum mt)
					(@ datum mt if))
				   (cond ((= "__colorPicker" (@ datum mt if type))
				   	  (subcomponent (@ interface-modules color-picker)
				   			cell-data))
				   	 ((= "__item" (@ datum mt if type))
				   	  (subcomponent (@ interface-modules item)
				   			cell-data))
				   	 ((= "__select" (@ datum mt if type))
				   	  (subcomponent (@ interface-modules select)
				   			cell-data))
				   	 ((= "__textfield" (@ datum mt if type))
				   	  (subcomponent (@ interface-modules textfield)
				   			cell-data))
				   	 ((= "__textarea" (@ datum mt if type))
				   	  (subcomponent (@ interface-modules textarea)
				   			cell-data))
				   	 ((= "__bar" (@ datum mt if type))
				   	  (subcomponent (@ interface-modules bar)
				   			cell-data))
				   	 (t (subcomponent (@ cell-components cell-standard)
				   			  cell-data)))
				   (subcomponent (@ cell-components cell-standard)
						 cell-data
						 ((setf (@ sub-con branch) self
							(@ sub-con focus) (@ self state focus)
							(@ sub-con is-point)
							(= (@ self state point-attrs index)
							   (@ datum ix))
							;; (@ sub-con rendered-menu)
							;; (@ self props context rendered-menu)
							(@ sub-con menu-content)
							(@ self props context menu-content)))))))))
	  :render-list
	  (lambda (rows-input callback)
	    (let ((self this)
		  (count 0))
	      (labels ((process-list (input output)
			 (let ((output (if output output #())))
			   (if (= 0 (@ input length))
			       output
			       (process-list (chain input (slice 1))
					     (if (and (= "[object Object]" (chain -object prototype to-string 
										  (call (@ input 0))))
						      (= "plain" (@ input 0 ty 0)))
						 output
						 (if (and (= "[object Array]" (chain -object prototype to-string
										     (call (@ input 0)))))
						     (chain output 
							    (concat
							     (list (panic:jsl
								    (:li :key (+ "list-" (@ input 0 ix))
									 (:ul :class-name "form-view in"
									      (process-list (@ input 0) nil)))))))
						     (progn (setf (@ input 0 ct) count
								  count (1+ count))
							    (chain output
								   (concat (list (panic:jsl
										  (:li 
										   :key (+ "list-" (@ input 0 ix))
										   (chain self
											  (render-atom
											   (@ input 
											      0))))))))))))))))
		(funcall callback
			 (panic:jsl (:ul :class-name (+ "form-view " (@ self props context view-scope))
					 (process-list rows-input)))))))
	  :render-sub-list2
	  (lambda (datum content)
	    (let ((self this))
	      (panic:jsl (:td :key (+ "form-view-td-" (@ datum ix))
			      :ref (lambda (ref)
				     (if (and ref (not (and (@ datum mt) (@ datum mt if)
							    (= "__item" (@ datum mt if type)))))
				         ; don't assign element spec locations to items within specially-rendered
				         ; sub-lists
					 (labels ((pos (element offset)
						    (let* ((offset (if offset offset (create left 0 top 0)))
							   (this-offset (create 
									 left (+ (@ offset left)
										 (@ element 0 offset-left))
									 top (+ (@ offset top)
										(@ element 0 offset-top))
									 height (@ element 0 client-height)
									 width (@ element 0 client-width))))
					              ; return the offset if the measurement reaches the container
						      (if (= "pane" (chain (j-query element) (offset-parent) 
									   (attr "class")))
							  (setf (getprop (@ self element-specs) (@ datum ix))
								this-offset)
							  (pos (chain (j-query element) (offset-parent))
							       this-offset)))))
					   (pos (j-query ref)))))
			      :class-name (+ (if (and (@ datum mt) (@ datum mt if)
						      (= "list" (@ datum mt if type)))
						 "special-table" "sub-table")
					     (+ " mode-" (@ self state context mode))
					     (if (= (@ datum ix) (@ self state point-attrs index))
						 " point" ""))
			      :id (+ (@ self state data id) "-atom-"
				     (@ datum ix))
			      :col-span (- (@ self state meta max-depth) (@ datum ly))
 			      ; get the number of rows in the sub-list for the container rowspan
			      (:div :class-name "spacer")
			      (cond ((and (@ datum mt) (@ datum mt if)
					  (= "__list" (@ datum mt if type)))
				     (subcomponent (@ interface-modules list)
						   ; remove the first element from the content,
						   ; since this element usually comes from after
						   ; the plain list marker
						   (create content (chain self (render-table-body content))
							   params datum)))
				    ((and (@ datum mt) (@ datum mt if)
					  (= "__item" (@ datum mt if type)))
				     (subcomponent (@ interface-modules item)
						   (create content (chain self (render-table-body content))
							   params datum)))
				    (t (chain self (render-table-body content))))))))
	  :render-table-body
	  (lambda (rows is-root)
	    (let ((self this))
	      (panic:jsl (:table :class-name (+ "form" (if is-root " root" ""))
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
									    row-data))))))))))
	  :render-table
	  (lambda (rows-input callback)
	    (defvar self this)
	    (labels ((generate-cell (datum)
		       (panic:jsl (:td :key (+ "table-" (@ datum ix))
				       :col-span (if (not (@ datum br))
						     (- (@ self state meta max-depth) (@ datum ly))
						     1)
				       :row-span (if (@ datum br) (@ datum br)
						     ;(- (@ datum br) (@ datum sl))
						     1)
				       :ref (lambda (ref)
					      (if ref
						  (let ((in-special-form false))
						    (labels ((pos (element offset)
							       (let* ((offset (if offset offset 
										  (create left 0 top 0)))
								      (this-offset 
								       (create left (+ (@ offset left)
										       (@ element 0 offset-left))
									       top (+ (@ offset top)
										      (@ element 0 offset-top))
									       height 
									       (if (@ offset height)
										   (@ offset height)
										   (@ element 0 client-height))
									       width (@ element 0 client-width))))
					                         ; return the offset if the measurement
							         ; reaches the container
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
						      (if (and (@ datum mt) (@ datum mt if)
							       (= "list" (@ datum mt if type)))
							  " special-table" ""))
		       (chain self (render-atom datum)))))
		     (process-rows (rows output)
		       (let ((cells (@ rows 0))
			     (is-outer-form (if (not output)
						t false))
			     (output (if output output (list #()))))
			 ;(cl :cell cells)
			 (if (= 0 (@ rows length))
			     (chain output (slice 0 (1- (@ output length))))
			     ; remove final empty list that gets appended to output before returning it
			     (if (= 0 (@ cells length))
				 (process-rows (chain rows (slice 1))
					       (chain output (concat (list #()))))
				 (if (= "plain" (@ cells 0 ty 0))
				     ; create a sub-table for plain lists
				     (process-rows
				      (chain rows (slice (@ cells 0 br)))
				      (let ((empty-rows #())
					    (enclose-table (if is-outer-form
							       (lambda (input) (chain self
										      (render-table-body input t)))
							       (lambda (input)
								 ;(cl :cells cells)
								 ;(cl :inp cells)
								 (chain self (render-sub-list2 (@ cells 0)
											       input))))))
					(chain output (slice 0 (1- (@ output length)))
					       (concat (list (chain
							      (getprop output (1- (@ output length)))
							      (concat
							       (enclose-table
								(process-rows
								 (chain (list (chain cells (slice 1)))
									(concat
									 (chain rows
										(slice 1 (@ cells 0 br)))))
								 ; add the blank output array so that the
								 ; process-rows function knows that it is not
								 ; the outer form
								 (list #())))))))
					       (concat (list #())))))
				     (process-rows (chain (list (chain cells (slice 1)))
							  (concat (chain rows (slice 1))))
						   (chain output (slice 0 (1- (@ output length)))
							  (concat
							   (list (chain (getprop output (1- (@ output length)))
									(concat 
									 (generate-cell (@ cells 0))))))))))))))
	      (cl :ri rows-input)
	      (funcall callback (process-rows rows-input))))

	  :component-will-receive-props
	  (lambda (next-props)
	    (defvar self this)
	    ;; (cl 7989 (jstr (getprop (chain this (initialize next-props)) "space" 1 0))
	    ;; 	(not (@ next-props context current)))

	    (let ((new-state (chain this (initialize next-props))))
	      (if (@ self state context is-point)
		  (setf (@ new-state action-registered)
			(@ next-props action)))
	      (if (not (= (@ next-props data branch-id)
			  (@ this props data branch-id)))
		  (setf (@ new-state meta) nil
			(@ new-state space) nil
			(@ new-state data) nil))
	      ;; (if (and (not (@ self state pane-element))
	      ;; 	       (not (= "undefined" (typeof (@ self props context fetch-pane-element)))))
	      ;; 	  (setf ;(@ new-state pane-specs)
	      ;; 		;(@ self props context pane-specs)
	      ;; 		(@ new-state pane-element)
	      ;; 		(chain self props context (fetch-pane-element))))
	      (if (and (not (@ self state pane-element))
		       (not (= "undefined" (typeof (@ self props context fetch-pane-element)))))
		  (setf (@ new-state pane-element)
			(chain (j-query (+ "#branch-" (@ self props context index)
					   "-" (@ self props data id))))))
	      ;; (if (not (= "undefined" (typeof (@ self props context fetch-pane-element))))
	      ;; 	  (progn (cl :ffe (@ self props context))
	      ;; 		 (cl :ffe (chain self props context (fetch-pane-element)))))
	      (if (not (@ next-props context current))
		  ; only build the form display object if the form is in "full" display mode
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
	     :actions-branch-id
	     (("recordMove"
	       "clipboard"
	       (chain self (move (@ params vector)))
	       (chain self state context methods (grow (create) (create vector (@ params vector))))))
	     :actions-point-and-focus
	     (("move"
	       (chain self (move (chain self state context (movement-transform (@ params vector))))))
	      ("controlShiftMeta"
	       (if (and (= "undefined" (typeof (@ self state point-attrs props meta comment)))
			(< 0 (@ params vector 0)))
		   (chain self state context methods (grow (create mt (create comment "")
								   am (list "meta")))))
	       (chain self (shift-focus "meta" (@ params vector))))
	      ("record"
	       (if (@ self props context clipboard-id)
		   (chain self state context methods
		   	  (grow (create)
				(create vector (@ params vector)
					point-to (@ self state point-attrs path)
					branch (@ self state data id))
		   		(@ self props context clipboard-id)))))
	      ("recall"
	       (if (and (@ self props context history-id)
			(not (= true (@ next-props data meta locked))))
		   (chain self state context methods (grow (create)
		   					   (create vector (@ params vector)
		   						   "recall-branch" (@ self state data id))
		   					   (@ self props context history-id)))))
	      ("commit"
	       (if (not (= true (@ next-props data meta locked)))
		   (chain self state context methods (grow #() (create save true)))))
	      ("revert"
	       (chain self state context methods (grow #() (create revert true))))
	      ("setPointType"
	       (if (not (= true (@ next-props data meta locked)))
		   (progn (chain self state context methods (set-mode "set"))
			  (chain self (set-state (create action-registered nil)))
			  (chain self state context methods
				 (grow (create ty (@ params type) vl (@ params default)))))))
	      ("addReaderMacro"
	       (if (not (= true (@ next-props data meta locked)))
		   (progn (chain self (set-state (create action-registered nil)))
			  (chain self state context methods
				 (grow (if (@ self state point-attrs is-atom)
					   (create am (chain (list (@ params name))
							     (concat (@ self state point-attrs atom-macros))))
					   (create fm (chain (list (@ params name))
							     (concat (@ self state point-attrs
									     form-macros))))))))))
	      ("removeReaderMacro"
	       (if (not (= true (@ next-props data meta locked)))
		   (progn (chain self (set-state (create action-registered nil)))
			  (chain self state context methods 
				 (grow (if (@ self state point-attrs is-atom)
					   (create am (chain self state point-attrs form-macros (slice 1)))
					   (if (< 0 (@ self state point-attrs atom-macros length))
					       (create am (chain self state point-attrs atom-macros (slice 1)))
					       (create fm (chain self state point-attrs form-macros
								 (slice 1))))))))))
	      ("deletePoint"
	       (if (not (= true (@ next-props data meta locked)))
		   (chain this (delete-point (@ this state point)))))
	      ("insert"
	       (let ((new-space (chain j-query (extend #() (@ self state space))))
		     (new-item (create vl "" ty (list "symbol")) ))
		 (chain this (seek (@ this state point) (@ this state point-attrs depth) new-space
				   (lambda (target target-list target-parent target-index path)
				     (if (= 0 (@ params vector 0)) ; if this is top level...
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
	      ("triggerSecondary"
	       (if (not (= true (@ next-props data meta locked)))
		   (progn (chain self (set-state (create action-registered nil)))
			  (chain self state context methods (set-mode "set")))))
	      ("triggerPrimary"
	       (cond ((= "move" (@ self state context mode))
		      (if (not (= true (@ next-props data meta locked)))
			  (chain self state context methods (set-mode "set"))))
		     ((= "set" (@ self state context mode))
		      (chain self (set-state (create action-registered nil)))
		      (chain self state context methods (grow (@ self state point-attrs delta)))
		      (chain self (set-focus "meta" 0))
		      (chain self state context methods (set-delta nil))
		      (chain self state context methods (set-mode "move")))))
	      ("triggerAnti"
	       (chain self (set-state (create action-registered nil)))
	       (chain self (set-focus "meta" 0))
	       (chain self state context methods (set-delta nil))
	       (chain self state context methods (set-mode "move")))
	      ))
	    )
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
	      ;(cl 5432 (@ self state action-registered))
	      ;; (if (= "short" (@ self props context view-scope))
	      ;; 	  (cl :upd (@ self state point-attrs value) (jstr (@ self state point-attrs props))
	      ;; 	      (@ self state point-attrs)))
	      ; if the point-attrs are marked as fresh, i.e. the form view has just been created,
	      ; perform a point movement to correctly set the point-attrs
	      (if (and (@ self state point-attrs fresh)
		       (< 0 (@ self state space length)))
		  ; only do the movement if there's something in the form's space
		  ; i.e. it isn't an empty form
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
		       (= null (@ self state point-attrs delta)))
		  (let* ((input-ref (chain (j-query (+ "#form-view-" (@ this state data id)
						       " .atom.mode-set.point .editor input"))))
			 (temp-val (chain input-ref (val))))
		    ; need to momentarily blank the value so the cursor goes to the end on all browsers
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
		    (chain input-ref (val temp-val))))))
	  )
       (defvar self this)
       ;; (if (or (= (@ self state data id) "clipboard")
       ;; 	       (= (@ self state data id) "history"))
       ;; 	   (cl :ren (@ self state data) (@ self props context) (@ self state context)
       ;; 	       (@ self state point-attrs)))
       ;(cl :ax (chain self props context (tracer #(1 0))))
       ;; (if (@ self props context ii) (cl :aa (@ self state) (@ self state context trace)
       ;; 					 (@ self state context path)))

       (if (or (not (= "undefined" (typeof (@ this state rendered-content2))))
	       (and (= "[object Array]" (chain -object prototype to-string (call (@ this state rendered-content2))))
		    (= 0 (@ this state rendered-content2 length))))
	   (cond ((= "full" (@ this props context view-scope))
		  (let* ((root-index (labels ((find-index (item)
						(if (= "[object Object]"
						       (chain -object prototype to-string (call item)))
						    (@ item ix)
						    (find-index (@ item 0)))))
				       (find-index (getprop (@ this state space)
							    (1- (@ this state space length))))))
			 (glyph-content (chain j-query (extend (create branch-id (@ self state data id)
								       base-atom root-index
								       branch-index (@ self props context 
											    branch-index)
								       root-params (@ self root-params)
								       point-index (@ self state point-attrs index))
							       (@ self state meta)))))
		    (chain self (render-table (@ this state rendered-content2)
					      (lambda (rendered)
						; send the base-atom to the glyph-display so that the stem
						; at the bottom of the glyph pattern can be drawn
						;(cl :gly glyph-content)
						(panic:jsl (:div :class-name "matrix-view form-view"
								 :id (+ "form-view-" (@ self state data id))
								 (subcomponent -glyph-display glyph-content)
								 rendered)))))))
		 (t (chain self (render-list (@ this state space)
					     (lambda (rendered depth base-atom)
					       (panic:jsl (:div :class-name "form-view"
								:id (+ "form-view-" (@ self state data id))
								rendered)))))))
	   (panic:jsl (:div))))

     (panic:defcomponent -sheet-view
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
						      ; TODO: it may be desirable to add certain metadata to
						      ; the meta for each grow request, that's what the
						      ; derive-metadata function below may later be used for
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
							    :class-name (+ "atom"
									   (+ " mode-" (@ self state context mode))
									   (if is-point " point" ""))
							    (if is-point
								(panic:jsl (:div :class-name "point-marker")))
							    (subcomponent (@ cell-components cell-spreadsheet)
									  (create content (getprop data row col)
										  meta (create is-point is-point
											       is-parent-point
											       (@ self state 
												       context 
												       is-point)))))
						       ))))))
		     row)
		   (chain cells (push (panic:jsl (:tr :key (+ "row-" row)
						      this-row)))))
	      cells))
          :move
          (lambda (motion)
            (let* ((self this)
                   (mo (chain motion (map (lambda (axis index)
					    (* axis (if (getprop (@ self state meta invert-axis) index)
							-1 1)))))))
              (chain this (set-state (create point (list (if (< -1
								(+ (@ mo 0) (@ this state point 0))
								(@ this state space 0 length))
							     (+ (@ mo 0) (@ this state point 0))
							     (@ this state point 0))
							 (if (< -1
								(+ (@ mo 1) (@ this state point 1))
								(@ this state space length))
							     (+ (@ mo 1) (@ this state point 1))
							     (@ this state point 0))))))))
	  :assign
	  (lambda (value matrix)
	    (let* ((x (@ this state point 0))
		   (y (@ this state point 1))
		   (original-value (getprop matrix y x)))
	      (setf (getprop matrix y x)
		    (if (= "[object Array]" (chain -object prototype to-string (call original-value)))
			(if (not (null value))
			    ; assign the unknown type for now; 
			    ; an accurate type will be assigned server-side
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

	    ;(cl :nxm (@ self state context))

	    (handle-actions
	     (@ next-props action) (@ self state) next-props
	     :actions-point-and-focus
	     (("move"
	       (chain self (move (@ params vector))))
	      ("deletePoint"
	       (if (not (= true (@ next-props data meta locked)))
		   (chain self state context methods (grow-point nil (create)))))
	      ("record"
	       ;(chain self (set-state (create action-registered nil)))
	       ;(cl :rec (@ self state))
	       (if (@ self props context clipboard-id)
		   (chain self state context methods (grow-point (create)
								 (create vector (@ params vector)
									 point (@ self state point)
									 branch (@ self state data id))
								 (@ self props context clipboard-id)))))
	      ("recall"
	       (if (and (@ self props context history-id)
			(not (= true (@ next-props data meta locked))))
		   (chain self state context methods (grow-point (create)
								 (create vector (@ params vector)
									 "recall-branch" (@ self state data id))
								 (@ self props context history-id)))))
	      ("triggerPrimary"
	       (cond ((= "move" (@ self state context mode))
		      (if (not (= true (@ next-props data meta locked)))
			  (chain self state context methods (set-mode "set"))))
		     ((= "set" (@ self props context mode))
		      (progn (chain self (set-state (create action-registered nil)))
			     (chain self state context methods (grow-point (@ self state point-attrs delta)
									   (create)))
			     (chain self state context methods (set-mode "move"))))))
	      ("triggerSecondary"
	       (if (not (= true (@ next-props data meta locked)))
		   (chain self state context methods (set-mode "set"))))
	      ("triggerAnti"
	       (chain self state context methods (set-mode "move")))
	      ("commit"
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
	  :component-did-mount
	  (lambda () ;(chain this props context methods (register-layer (@ this state context layer)))
	    ;(chain this props context methods (chart (@ this state) (@ this set-state)))
		  )
	  )
       (defvar self this)
       ;(cl "SHR" (@ this state just-updated))
       ;(cl :cel (@ self state data) (@ self props context) (@ self state context))
       (panic:jsl (:div :class-name "matrix-view spreadsheet-view"
			:id (+ "sheet-view-" (@ this state data id))
			(:table :class-name "form"
				:ref (+ "formSheet" (@ this state data id))
				(:thead (:tr (chain self (build-sheet-heading (@ self state space)))))
				(:tbody (chain self (build-sheet-cells (@ self state space)))))))
       )

     (panic:defcomponent :-html-display
	 (:get-initial-state
	  (lambda ()
	    (create content-string (@ this props data)))
	  :component-will-receive-props
	  (lambda (next-props)
	    (chain this (set-state (create content-string (@ next-props data))))))
       (panic:jsl (:div :class-name "element-view"
			(:div :class-name "html-display"
			      :dangerously-set-inner-h-t-m-l
			      (create __html (@ this state content-string))))))

     (panic:defcomponent :-remote-image-view
	 (:get-initial-state
	  (lambda ()
	    (create image-uri (@ this props data)))
	  :component-will-receive-props
	  (lambda (next-props)
	    (defvar this-date (new (-date)))
	    (chain this (set-state (create image-uri
					   (+ (@ this props data) "?"
					      (chain this-date (get-time))))))))
       (panic:jsl 
	(:div :class-name "element-view"
	      (:img :src (@ this state image-uri)))))
     ))
