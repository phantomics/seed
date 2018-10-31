;;;; seed.ui-spec.stage.base.lisp

(in-package #:seed.ui-spec.stage.base)

(defmacro simple-stage (portal &key (branches nil) (sub-nav nil))
  `(lambda ()
     (let ((branch-specs (if (of-sprout-meta ,portal :active-system)
			     (get-portal-contact-branch-specs ,portal
							      (intern (string-upcase
								       (of-sprout-meta ,portal :active-system))
								      "KEYWORD")))))
       `(((meta ((meta ,,(intern (package-name *package*) "KEYWORD")
		       :mode (:view :portal-name))
		 ,@(if (not branch-specs)
		       `((meta ,(get-portal-contacts ,portal)
			       :mode (:view :portal-system-list :index -1)
			       :each (:mode (:interaction :select-system)))))
		 ,@(if branch-specs
		       `((meta ,(of-sprout-meta ,portal :active-system)
			       :mode (:options ,(mapcar (lambda (system-name)
							  `(:title ,(lisp->camel-case system-name)
								   :value ,(string-downcase system-name)))
							(get-portal-contacts ,portal))
					     :view :select))))
		 ,@(if branch-specs `((meta ,(funcall ,(macroexpand sub-nav)
						      (loop for item in
							   (rest (assoc :primary
									(rest (first (find-form-in-spec
										      'display-params
										      (first branch-specs))))))
							   append item))
					    :mode (:view :system-branch-list :index 0 :sets (2))
					    :each (:mode (:interaction :select-branch))))))
		:mode (:view :vista :breadth :short :layout :column :name :portal-specs
			   :fill :fill-overview :enclose :enclose-overview)))
	 (meta ,(if branch-specs (funcall ,(macroexpand branches)
					  branch-specs))
	       ;; is the transparent property needed here?
	       :mode (:view :vista :transparent t))))))

(defmacro simple-branch-layout (&rest extend)
  "A layout for display of major and adjunct branches within a Seed system."
  `(lambda (branch-specs)
     (labels ((prospec-branch (spec)
		(let* ((name (intern (string-upcase (first spec)) "KEYWORD"))
		       (param-checks (mapcar #'cadr (find-form-in-spec 'is-param spec)))
		       (stage-params (cdar (find-form-in-spec 'stage-params spec)))
		       (primary-controls (getf stage-params :primary-controls))
		       (secondary-controls (append (or (find :save param-checks) (find :revert param-checks)))))
		  `(meta ,(append (if primary-controls (list :top-controls))
				  (list :body)
				  (if secondary-controls (list :sub-controls)))
			 :mode (:view :vista :ct 0 :fill :fill-branch :branch ,name
				    ,@(if primary-controls (list :starting-index -1))
				    :extend-response :respond-branches-main :axis :y
				    ,@(if primary-controls
					  `(:primary-controls
					    (:format (,(funcall ,(macroexpand (append (getf extend :controls)))
								nil (reverse (getf stage-params
										   :primary-controls)))))))
				    :secondary-controls
				    (:format (,(funcall ,(macroexpand (append (getf extend :controls)))
							spec (reverse (getf stage-params :secondary-controls)))))
				    :contextual-menu
				    (:format ,,@(if (< 0 (length (getf extend :menu)))
						    (list `(funcall ,(macroexpand (append (getf extend :menu)
											  (list 'meta)))
								    (getf stage-params :contextual-menu)))))))))

	      (prospec-segment (specs)
	      	(labels ((process-section (section)
	      		   (if (listp section)
	      		       `(meta ,(mapcar #'process-section section)
				      :mode (:view :vista :enclose :enclose-branch-segment))
	      		       (prospec-branch (labels ((find-spec (target specs)
							  (if specs
							      (if (eq target (intern (string-upcase (caar specs))
										     "KEYWORD"))
								  (first specs)
								  (find-spec target (rest specs))))))
						 (find-spec section branch-specs))))))
	      	  (mapcar #'process-section
	      		  (rest (assoc :primary (rest (first (find-form-in-spec 'display-params
	      									(first specs)))))))))
	      
	      (prospec-nav (specs)
		(rest (assoc :primary (rest (first (find-form-in-spec 'display-params (first specs)))))))

	      (prospec-adj (specs) ;;(specs &optional output)
		(second (assoc :adjunct (rest (first (find-form-in-spec 'display-params (first specs))))))))
       `((meta ((meta ,(prospec-segment branch-specs)
		      :mode (:view :vista :name :branches :enclose :enclose-branches-main :point 0
				 :index (:format
					 ,(rest (assoc :primary
						       (rest (first (find-form-in-spec 'display-params
										       (first branch-specs)))))))
				 :navigation (:format (,(prospec-nav branch-specs)))))
		(meta ,(prospec-adj branch-specs)
		      :mode (:view :vista :name :branches-adjunct :breadth :brief
				 :fill :fill-branches-adjunct :enclose :enclose-branches-adjunct)))
	       :mode (:view :vista))))))


(defmacro simple-sub-navigation-layout (&key (omit nil))
  "List items for use as menu options for a nav menu displaying the visible branches within a Seed system."
  `(lambda (branch-specs)
     (loop for branch in branch-specs collect `(meta ,branch :mode (:view :branch-selector
									  :target ,branch)))))

