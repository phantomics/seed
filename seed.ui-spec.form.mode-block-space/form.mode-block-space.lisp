;;;; seed.ui-spec.form.mode-block-space.lisp

(in-package #:seed.ui-model.react)

(defpsmacro cl (&rest items)
  `(chain console (log ,@items)))

(specify-components
 block-space-view-mode
 (block-space-view
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
       ;; (if (@ self props context trace-category)
       ;; 	   (chain self props context methods (register-branch-path (@ self props context trace-category)
       ;; 								   (@ self props data id)
       ;; 								   (@ state context path))))
       state))
   :element-specs #()
   :container-element nil
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
      :actions-any-brancho
      ((set-branch-by-id
     	(if (= (@ params id) (@ self props data id))
     	    (chain self props context methods (set-trace (@ self props context path))))))
      :actions-point-and-focus
      (
       ;; (move
       ;; 	(chain self (move (@ params vector))))
       ;; (delete-point
       ;; 	(if (not (= true (@ next-props data meta locked)))
       ;; 	    (chain self state context methods (grow-point nil (create)))))
       ;; (trigger-primary
       ;; 	(cond ((= "move" (@ self state context mode))
       ;; 	       (if (not (= true (@ next-props data meta locked)))
       ;; 		   (chain self state context methods (set-mode "set"))))
       ;; 	      ((= "set" (@ self props context mode))
       ;; 	       (progn (chain self (set-state (create action-registered nil)))
       ;; 		      (chain self state context methods (grow-point (@ self state point-attrs delta)
       ;; 								    (create)))
       ;; 		      (chain self state context methods (set-mode "move"))))))
       ;; (trigger-secondary
       ;; 	(chain self editor-instance (focus))
       ;; 	(chain self state context methods (set-mode "write")))
       (trigger-anti
     	(chain self state context methods (set-mode "move"))))))
   :should-component-update
   (lambda (next-props next-state)
     (or (not (@ next-state context current))
	 (not (= (@ next-state context mode)
		 (@ this state context mode)))
	 (@ next-state action-registered)))
   :component-did-mount
   (lambda ()
     (cl :ll 5 (@ this state))
     (let* ((self this)
	    ;; (cl #())
	    ;; (error-found false)
	    (section (/ (@ self state space length) 4))
	    (radius (/ (@ self state space length) 2))
	    (new-space (-voxel-space (create materials (list "#8baba8" "#f3827c" "#dfe0de" "#4f5e5d" "#000000")
					     material-flat-color t
					     chunk-size section
					     generate (lambda (x y z)
							;;(setq cl (chain cl (concat (list (list x y z)))))
							(getprop self "state" "space"
								 (+ radius (mod x radius))
								 (+ radius (mod y radius))
								 (+ radius (mod z radius)))
							;; (if (= y -2) 2 0)
							))
				     ))
	    (create-player (-voxel-space-player new-space))
	    (new-player (create-player)))
       ;;(cl :coords cl)
       (chain new-player yaw position (set 2 5 2))
       (chain new-player (possess))
       (chain new-space (append-to (@ this container-element)))))
   ;; :component-did-update
   ;; (lambda ()
   ;;   (if (and (= "set" (@ this state context mode))
   ;; 	      (@ this state context is-point))
   ;; 	 (chain (j-query (+ "#sheet-view-" (@ this props data id)
   ;; 			    " .atom.mode-set.point .editor input"))
   ;; 		(focus))))
   )
  (defvar self this)
  ;;(cl "SHR" (@ this state just-updated))
  ;; (chain console (log :cel (@ self state data) (@ self props context) (@ self state context)))
  ;;(chain console (log :ssp (@ self state space)))
  ;;(let ((-data-sheet (new -react-data-sheet)))
  ;;(chain console (log :dd (@ self props context)))
  (panic:jsl (:div :ref (lambda (ref)
			  (if (not (@ self container-element))
			      (setf (@ self container-element) ref)))))))
