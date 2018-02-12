;;; react.base.lisp

(in-package #:seed.ui-spec.react.base)

(defpsmacro cl (&rest items)
  `(chain console (log ,@items)))

(defpsmacro jstr (item)
  `(chain -j-s-o-n (stringify ,item)))

(defpsmacro for-data-branch (id branches-list action)
  "Perform an operation on the Javascript representation of each data branch within a Seed system."
  (let ((val (gensym)) (index (gensym)))
    `(let ((,val nil))
       (loop for ,index in ,branches-list do (if (= (@ ,index id) ,id)
						 (setf ,val (funcall ,action ,index))))
       ,val)))

(defmacro react-portal-core (&rest content)
  "Specify a React portal interface implementing different interfaces for Lisp forms and other data types."
  `(,@(loop for item in content append (list (macroexpand (if (listp item)
							      item (list item)))))
     (defun inherit (self prop-data process-data map-data)
       (let* ((data (funcall process-data prop-data))
	      (c (@ prop-data context))
	      (is-vista (= "function" (typeof (@ self props fill))))
	      (is-parent-vista (@ c is-vista))
	      (display-vertical (or (and (@ c meta) (= "__y" (@ c meta axis)))
				    (or (= "short" (@ c breadth))
					(= "brief" (@ c breadth)))))
	      (this-index (if (@ c index) (@ c index) 0)) ;; add 0 if there's no explicit index 
	      (path (chain c path (concat (list this-index))))
	      (trace (if (< (@ c trace) (@ path length))
			 (chain c trace (concat (list 0)))
			 (@ c trace)))
	      (on-trace (progn
			  ;; (if (= 4 (@ c path length))
			  ;;     (cl :ac (@ c on-trace) prop-data))
			  (and (@ c on-trace)
			     (or (= (getprop (@ c trace) (1- (@ path length)))
				    (getprop path (1- (@ path length))))
				 ;; if no trace information exists beyond the
				 ;; path length, presume that the 0-index branch
				 ;; is the one to follow to the point
				 (and (< (@ c trace length) (@ path length))
				      ;; make sure trace and path match up to the
				      ;; point where path goes further
				      ;; TODO: ACTUALLY, NOT VALID
				      ;; (= (getprop trace (1- (@ trace length)))
				      ;;    (getprop path (1- (@ trace length))))
				      ;;(= 0 (if (@ c index) (@ c index) 0))
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
				      (= 0 (getprop path (1- (@ path length)))))))))
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
			  (progn (loop for x from (1- (@ retracers length)) downto 0 do
				      ;; prevent motion vector from propagating if the orientation
				      ;; switches from vertical to horizontal
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
					    ;; if the movement vector is negative, once a valid branch has been
					    ;; found, run the trace along the highest-numbered downstream branches.
					    ;; the indices of the highest-numbered branches are found by running
					    ;; the retracers functions from those branches with no argument,
					    ;; which should cause them to return the breadth of their rendered
					    ;; elements.
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
      (create save (panic:jsl (:span :on-click (lambda () (chain self context methods
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
						 (if (@ sector 1 0) (@ sector 1 0) (@ sector 1))
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
	    (if (and sector-data (= "__vista" (@ sector-data if type))
		     ;; don't render the vista if the value inside is nil
		     (or (not (@ sector vl))
			 (not (= "nil" (@ sector vl)))))
		(vista sector
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
			   (respond-standard sector))
		       (if (@ sector-data if enclose)
			   (getprop window (chain sector-data if enclose (slice 2)))
			   enclose-blank)))))))

    (defun enclose-blank (self body)
      body)

    (defun enclose-branches-main (self body)
      (labels ((find-selected-index (id)
		 (let ((in-segment nil))
		   (loop for segix from 1 to (1- (@ self props context meta index format length))
		      do (if (let ((segment (getprop (@ self props context meta index format)
						     segix))
				   (found nil))
			       (loop for index from 0 to (1- (@ segment length))
				  do (if (= id (getprop segment index "vl"))
					 (setq found true)))
			       found)
			     (setq in-segment segix)))
		   (1- in-segment))))
	(if (and (@ self props action)
		 (= "setBranchById" (@ self props action id)))
	    (setf (@ self props context meta point)
		  (find-selected-index (@ self props action params id))))
	(panic:jsl (:div :class-name "branch-segment" (getprop body (@ self props context meta point))))))

    (defun enclose-branch-segment (self body)
      (let ((portion (/ 12 (@ body length))))
	(panic:jsl (:div :class-name "view"
			 (:div :class-name "main"
			       (:div :class-name "branches"
				     (:-grid (:-row :class-name "show-grid"
						    (chain body (map (lambda (element index)
								       (panic:jsl (:-col :md portion
											 :class-name "column-outer"
											 :key (+ "branch-" index)
											 :id (+ "branch-" index)
											 element)))))))))))))
      
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
	(subcomponent (@ view-modes form-view)
		      branch :context (index
				       0
				       initial-motion #(0 -1)
				       set-control-target
				       (lambda (index) (chain self (set-state (create control-target index))))))))
     
    (defun enclose-overview (self body)
      ;(cl :ixd (@ self state data) (@ self props))
      (panic:jsl (:div :class-name (+ "overview" (if (@ self state context on-trace)
						     " point" ""))
		       body (:div :class-name "footer"
				  (if (< 0 (@ self state data branches length))
				      (panic:jsl (:div :class-name "title-container"
						       (:h3 :class-name "title" "seed"))))))))

    ;; (defun fill-main-stage (self space)
    ;;   (defvar stuff nil)
    ;;   (setf (@ self size) 0)
    ;;   (if (< 0 (@ self state data branches length))
    ;; 	  (chain self state data branches (map (lambda (branch index)
    ;; 						 (if (= "stage" (@ branch id))
    ;; 						     (panic:jsl (:div :class-name "stage-content"
    ;; 								      (funcall (generate-vistas self)
    ;; 									       ;; 0 for the first item in the space
    ;; 									       (@ branch data 1) 0)))))))))

    (defun fill-branch (self space)
      ;; (cl 22 self space)
      ;; (cl 21 (@ self state))
      (if (and (@ self props action)
	       (= "setBranchById" (@ self props action id)))
	  (let* ((set-index nil))
	    (loop for brix from 0 to (1- (@ self state data branches length))
	       when (= (@ self props action params id)
		       (getprop (@ self state data branches) brix "id"))
	       do (setq set-index brix))
	    ;;(cl :eeo set-index (@ self state data branches))
	    ))
      (setf (@ self size) (@ space length))
      (if (= "undefined" (typeof set-interaction))
	  (setq set-interaction (lambda (interaction-name interaction)
				  (setf (getprop interactions interaction-name)
					interaction))))
      (if (= "undefined" (typeof get-interaction))
	  (setq get-interaction (lambda (interaction-name) (getprop interactions interaction-name))))
      (if (= "undefined" (typeof fetch-pane-element))
	  (setq fetch-pane-element (lambda (element) (if element
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
	     ;; (visible-branches (chain self state data branches
	     ;; 			      (map (lambda (this-branch index)
	     ;; 				     (cond ((or (= (@ this-branch id) "stage")
	     ;; 						(= (@ this-branch id) "clipboard")
	     ;; 						(= (@ this-branch id) "history"))
	     ;; 					    0)
	     ;; 					   (t 1))))))
	     ;; (visible-branch-count (if (< 0 (@ visible-branches length))
	     ;; 			       (chain visible-branches (reduce (lambda (total i) (+ total i))))
	     ;; 			       1))
	     (flip-axis (lambda (vector) (list (@ vector 1) (- (@ vector 0)))))
	     ;; (portion (chain -math (floor (/ 12 visible-branch-count))))
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
			     (subcomponent (@ view-modes form-view)
					   branch
					   :context
					   (index 
					    0
					    parent-system (@ self props context working-system)
					    branch-index index
					    ;; TODO: the above only needed for glyph rendering -
					    ;; is there a way to obviate?
					    force-render t
					    ;(@ sub-con pane-specs) (@ self element-specs)
					    fetch-pane-element fetch-pane-element
					    trace-category "major"
					    parent-meta (@ self props context meta)
					    retracer (@ self retrace)
					    set-interaction set-interaction
					    menu-content
					    (if (and (@ self state branch-modes)
						     (= "menu" (getprop (@ self state branch-modes) index)))
						(@ self props space 0 mt if contextual-menu format))
					    history-id (if (@ element-ids history-index) "history" nil)
					    clipboard-id (if (@ element-ids cboard-index) "clipboard" nil)
					    ;; cut the trace if the menu is active - prevents
					    ;; movement commands from registering in form area
					    ;; and menu at the same time
					    on-trace (if (and (not (= "undefined" 
								      (typeof (@ self state branch-modes))))
							      (= "menu" (@ self state branch-modes 0)))
							 false (@ self state context on-trace)))))
			    ((and (= (@ branch type 0) "matrix")
				  (= (@ branch type 1) "spreadsheet"))
			     (subcomponent (@ view-modes sheet-view)
					   branch :context (index
							    0
							    branch-index index
							    trace-category "major"
							    parent-meta (@ self props context meta)
							    pane-specs (@ self element-specs)
					                    ;;pane-element (@ self pane-element)
							    fetch-pane-element fetch-pane-element
							    retracer (@ self retrace)
							    set-interaction set-interaction
							    history-id (if (@ element-ids history-index)
									   "history" nil)
							    clipboard-id (if (@ element-ids cboard-index)
									     "clipboard" nil))))
			    ((and (= (@ branch type 0) "graphic")
				  (= (@ branch type 1) "bitmap"))
			     (subcomponent -remote-image-view (@ branch data)
					    :context (index index)))
			    ((= (@ branch type 0) "html-element")
			     (subcomponent -html-display (@ branch data)
					    :context (index index)))))
	     (sub-controls (if (not (= "nil" (@ self props context meta secondary-controls format 0 vl)))
			       ;; don't display the sub-controls if the value is 'nil', i.e. there's nothing to show
			       (subcomponent (@ view-modes form-view)
					      (create id "sub-controls"
						      data (@ self props context meta secondary-controls format))
					      :context (view-scope 
							"short"
							index 1
							get-interaction get-interaction
							movement-transform flip-axis)))))
	;(cl :subc (@ self props context meta secondary-controls format))
	(if element (panic:jsl (:div :class-name (+ "portal-column " (chain branch type (join " ")))
				     (:div :class-name (+ "header" (if (@ self state context on-trace)
								       " point" ""))
					   (:div :class-name "branch-info"
						 (:span :class-name "id" (@ branch id))
						 (if (= true (@ branch meta locked))
						     (panic:jsl (:span :class-name "locked-indicator"
								       "locked")))))
				     (:div :class-name "holder"
					   (:div :class-name "pane"
						 ;; TODO: WARNING: CHANGE THIS AND THE
						 ;; GLYPH RENDERING BREAKS BECAUSE
						 ;; THE FIRST TERMINAL TD CAN'T BE FOUND!
						 ;; FIGURE OUT WHY
						 :id (+ "branch-" index "-" (@ branch id))
						 :ref (lambda (ref)
							(let ((element (j-query ref)))
							  (if (@ element 0)
							      (fetch-pane-element element))))
						 element)
					   (:div :class-name (+ "footer horizontal-view" (if (= 1 this-index)
											     " point" ""))
						 (:div :class-name "inner" sub-controls))))))))

    (defun respond-branches-main (self next-props)
      ;; toggle the activation of the contextual menu in a branch
      ;; the controlShiftMenu action is intercepted here
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
			;; ;; dismiss the menu when the user interacts with an entry
			;; ;; TODO: this logic needs to encompass a lot more use cases
			;; (if (and (= index (@ next-props context index))
			;; 	 (@ next-props action)
			;; 	 (or (= "triggerPrimary" (@ next-props action id))
			;; 	     (= "triggerSecondary" (@ next-props action id))))
			;;     (setf (getprop new-modes index) "normal"))
			;; set the branch-mode to menu if the movement vector is rightward
			(if (and (= index (@ next-props context index))
				 (@ next-props action)
				 (= "controlShiftMenu" (@ next-props action id)))
			    (setf (getprop new-modes index) 
				  (if (= 1 (@ next-props action params vector 0))
				      "menu" "normal"))))))
	  (chain self (set-state (create action nil branch-modes new-modes))))))

    (defun fill-branches-adjunct (self space)
      ;(cl :fl space)
      (if (< 0 (@ self state data branches length))
	  (chain space
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
						 (subcomponent (@ view-modes form-view)
							       branch :context (index index)))))))))))

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
								       (chain item (substr 1 (- (@ item length) 
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
	    ;; (chain console (log 905 this))
	    (let* ((self this)
		   (this-date (new (-date)))
		   (modes (list "move" "set"))
		   (data (for-data-branch "systems" (@ self props data) (@ self set-up-systems)))
		   (space (for-data-branch "systems" (@ self props data)
					   (lambda (item) (chain item data (slice 1)))))
		   (gen-methods
		    (funcall 
		     (lambda (self)
		       ;;(cl :dat data)
		       (lambda ()
			 (let ((grow-fn (lambda (working-system)
					  (lambda (branch-id data params callback)
					    (chain self (transact "grow"
								  (list working-system branch-id data params)
								  (if (not (= "undefined" (typeof callback)))
								      (funcall callback))))))))
			   (create grow (grow-fn)
				   in-context-grow (lambda (ws) (grow-fn ws))
				   build-retracer (@ self build-retracer)
				   set-mode (@ self set-mode)
				   load-branch (@ self fill)
				   set-branch-by-id (@ self set-branch-by-id)
				   set-trace (@ self set-trace)
				   register-branch-path (@ self register-branch-path)
				   trace-branch (@ self trace-branch)))))
		     this)))
	      ;(cl 333 (@ self props data))
	      (create data data
		      space space
		      is-portal t
		      point 0
		      mark nil
		      action nil
		      context (create trace #(0 0)
				      on-trace t
				      path #()
				      branch-paths (create)
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
	  :set-up-systems
	  (lambda (item) (let ((systems nil))
			   ;;(cl 89 (@ item data 1))
			   (loop for datum in (@ item data 1)
			      do (if (and (= "[object Array]" (chain -object prototype to-string (call datum)))
					  (@ datum 0 mt)
					  (@ datum 0 mt if)
					  (= "__portalSpecs" (@ datum 0 mt if name)))
				     (setq systems (create branches #()
							   portal-name (@ datum 0 vl)
							   systems (@ datum 1)
							   working-system nil))))
			   systems))
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
			 ;; check whether space is subdivided into plain lists; if so, one should be subtracted
			 ;; from the space length since the space will have a plain list at its beginning that
			 ;; pads its length by one. TODO: this is clumsy, is there a better way to determine the
			 ;; navigable area within vistas?
			 (< -1 new-point (@ self size)))
			    ;; (+ (if (and (@ self state space 1)
			    ;; 		(@ self state space 1 0)
			    ;; 		(@ self state space 1 0 ty)
			    ;; 		(= "plain" (@ self state space 1 0 ty 0)))
			    ;; 	   -1 0)
			    ;;    (@ self state space length))
			    ;(count-vistas)
					;))
		    ;; set the upper bound to the space length - 1, since one member of the space is always a
		    ;; plain-list initial marker
		    new-point false))))
	  :retrace
	  (lambda (vector)
	    ;; in this retrace function, the point is *** SOMETHING
	    (let* ((self this)
	    	   (path (chain self state context path (concat (list (@ self state context index)))))
	    	   (current-point (if (getprop (@ self state context trace)
	    				       (1- (@ path length)))
	    			      (getprop (@ self state context trace)
	    				       (1- (@ path length)))
	    			      0))
	    	   (new-point (+ current-point (@ vector 0))))
	      ;; (cl :ccr current-point new-point (@ self state space) (@ self rendered))
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
	    ;; activate the "move" mode by default
	    (chain (@ this state ui listeners move)
		   (listen)))
	  :set-trace
	  (lambda (new-trace)
	    ;; (cl :newtrace (@ this state context trace) new-trace)
	    (let ((self this))
	      (chain self (set-state (create action nil
					     context (chain j-query (extend (create) (@ self state context)
									    (create trace new-trace))))))))
	  :set-mode
	  (lambda (mode)
	    (defvar self this)
	    (defvar this-date (new (-date)))
	    ;; TODO: the set-state must be done with a function so that the mode and action are set
	    ;; at the same time
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
	  :set-branch-by-id
	  (lambda (id)
	    (chain this (set-state (lambda () (create action (create id "setBranchById"
								     params (create id id)))))))
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
			    ;; (chain console (log "DAT2" data (@ self state data) (@ self state)))
			    ;; (chain console (log "DAT2" (chain -j-s-o-n (stringify data))))
			    (chain self (set-state (lambda (previous-state current-props)
						     (create
						      data 
						      ;; TODO: REPLACE SELF STATE BELOW WITH PREVIOUS-STATE
						      (chain j-query (extend (create)
									     (@ self state data)
									     (if (@ params 0)
										 (create branches data)
										 (for-data-branch
										  "systems" data
										  (@ self set-up-systems)))))
						      action nil
						      context
						      (chain j-query
						      	     (extend (create) (@ self state context)
						      		     (create updated (chain this-date 
											    (get-time)))))))))
			    (if (not (@ params 0))
				(chain self (fill (@ data 0 meta active-system))))
			    (if callback (callback)))
			  error (lambda (data err) (chain console (log 11 data err)))))))
	  :fill
	  (lambda (system-id)
	    (defvar self this)
	    (chain this (set-mode "move"))
	    (chain this (load-branch-data
			 system-id
			 (lambda (stage-data data)
			   (let ((this-date (new (-date)))
				 (new-space (chain j-query (extend #() (@ self state space)))))
			     ;; when the system is loaded, set the trace to #(1), pointing to the first branch
			     (chain self (set-state (create data (chain j-query (extend (create) (@ self state data)
											(create branches data)))
							    space (for-data-branch
								   "systems" stage-data
								   (lambda (item) (chain item data (slice 1))))
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
		     (ajax (create url "../portal"
				   type "POST"
				   data-type "json"
				   content-type "application/json; charset=utf-8"
				   data (chain -j-s-o-n (stringify (list (@ window portal-id) "grow" null null null
									 (create active-system system-id))))
				   success (lambda (data)
					     (chain self (load-b-data data system-id callback)))
				   error (lambda (data err) (chain console (log 11 data err))))))))
	  :load-b-data
	  (lambda (stage-data system-id callback)
	    (let ((self this))
	      (extend-state context (create working-system system-id))
	      (chain j-query
		     (ajax (create url "../portal"
				   type "POST"
				   data-type "json"
				   content-type "application/json; charset=utf-8"
				   data (chain -j-s-o-n (stringify (list (@ window portal-id) "grow" system-id)))
				   success (lambda (data)
					     (callback stage-data data))
				   error (lambda (data err) (chain console (log 11 data err))))))))
	  :register-branch-path
	  (lambda (category name path)
	    (let* ((self this)
		   (new-paths (chain j-query (extend (create) (@ self state context branch-paths)))))
	      (if (or (= "undefined" (typeof (getprop new-paths category)))
		      (= "undefined" (typeof (getprop new-paths category name))))
		  (chain self (set-state (create context
						 (chain j-query
							(extend (create) (@ self state context)
								(create branch-paths
									(progn
									  (if (= "undefined"
										 (typeof (getprop new-paths
												  category)))
									      (setf (getprop new-paths category)
										    (create)))
									  (setf (getprop new-paths category name)
										path)
									  new-paths))))))))))
	  :trace-branch
	  (lambda (category name)
	    ;; TODO: make this work
	    (cl 9191 category name (@ this state context))
	    ;; (chain this (set-state ;; (create trace (getprop (@ this state branch-paths)
	    ;; 			   ;; 			  category name))
	    ;; 			   (create context (chain j-query (extend (create) (@ this state context)
	    ;; 								  (create trace
	    ;; 									  (getprop (@ this state context
	    ;; 											   branch-paths)
	    ;; 										   category name)))))))
	    )
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
	    ;; actions at the portal level are handled with the did-update method
	    ;; since it does not receive a props update upon command execution
	    (handle-actions (@ self state action) (@ self state) (@ self props)
	  		    :actions-point-and-focus
	  		    ((move (chain self (set-state (create action nil)))
				   (chain self (move (@ params vector))))))))
       ;(cl 234 (jstr (@ this state context)) (@ this state context))
       ;(chain this (build-retracer 0 (create breadth "full") (@ this state space)))
       ;(cl 888 (@ this state) (chain this (build-retracer 0 (create breadth "full") (@ this state space))))
       ;(cl 921 (@ this props) (@ this state) (@ this state space))
       (let* ((self this))
	 ;; (cl :5sp (@ this state space) (@ this state data))
	 (panic:jsl (:div :class-name "portal" (chain this state space (map (generate-vistas self)))
			  (if (= 0 (@ this state data branches length))
			      (panic:jsl (:div :class-name "intro-animation"
					       (:div :class-name "animation-inner"
						     (funcall (lambda ()
								(loop for n from 0 to 11 collect
								     (panic:jsl (:div :key (+ "sc-" n)
										      :id (+ "star-caster-" n)))))))
					       (:h3 :class-name "title" "seed"))))))))

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
