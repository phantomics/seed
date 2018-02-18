;;;; seed.ui-spec.stage.base.lisp

(in-package #:seed.ui-spec.stage.base)

(defmacro simple-stage (portal &key (branches nil) (sub-nav nil))
  `(lambda ()
     (let ((branch-specs (if (of-sprout-meta ,portal :active-system)
			     (get-portal-contact-branch-specs ,portal (intern (string-upcase
									       (of-sprout-meta ,portal
											       :active-system))
									      "KEYWORD")))))
       `(((meta ((meta ,,(intern (package-name *package*) "KEYWORD")
		       :if (:type :portal-name))
		 ,@(if (not branch-specs)
		       `((meta ,(get-portal-contacts ,portal)
			       :if (:type :portal-system-list :index -1)
			       :each (:if (:interaction :select-system)))))
		 ,@(if branch-specs
		       `((meta ,(of-sprout-meta ,portal :active-system)
			       :if (:options ,(mapcar (lambda (system-name)
							`(:title ,(lisp->camel-case system-name)
								 :value ,(string-downcase system-name)))
						      (get-portal-contacts ,portal))
					     :type :select))))
		 ,@(if branch-specs `((meta ,(funcall ,(macroexpand sub-nav)
						      branch-specs)
					    :if (:type :system-branch-list :index 0 :sets (2))
					    :each (:if (:interaction :select-branch))))))
		:if (:type :vista :breadth :short :layout :column :name :portal-specs
			   :fill :fill-overview :enclose :enclose-overview)))
	 (meta ,(if branch-specs (funcall ,(macroexpand branches)
					  branch-specs))
	       ;; is the transparent property needed here?
	       :if (:type :vista :transparent t))))))

(defmacro simple-branch-layout (&key (omit nil) (adjunct nil) (extend nil))
  "A layout for display of major and adjunct branches within a Seed system."
  `(lambda (branch-specs)
     (labels ((prospec-branch (spec)
		(let* ((name (intern (string-upcase (first spec)) "KEYWORD"))
		       (param-checks (mapcar #'cadr (find-form-in-spec 'is-param spec)))
		       (stage-params (cdar (find-form-in-spec 'stage-params spec)))
		       (secondary-controls (append (if (find :save param-checks)
						       (list `(meta :save :if (:interaction :commit))))
						   (if (find :revert param-checks)
						       (list `(meta :revert :if (:interaction :revert)))))))
		  `(meta (:body ,@(if secondary-controls (list :sub-controls)))
			 :if (:type :vista :ct 0 :fill :fill-branch :branch ,name
				    :extend-response :respond-branches-main :axis :y
				    :secondary-controls (:format (,secondary-controls))
				    :contextual-menu
				    (:format ,,@(if (< 0 (length (getf extend :menu)))
						    (list `(funcall ,(macroexpand (append (getf extend :menu)
											  (list 'meta)))
								    (getf stage-params :contextual-menu)))))))))

	      (prospec-segment (specs)
	      	(labels ((process-section (section)
	      		   (if (listp section)
	      		       `(meta ,(mapcar #'process-section section)
				      :if (:type :vista :enclose :enclose-branch-segment))
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

	      (prospec-adj (specs &optional output)
		(second (assoc :adjunct (rest (first (find-form-in-spec 'display-params (first specs))))))))
       `((meta ((meta ,(prospec-segment branch-specs)
		      :if (:type :vista :name :branches :enclose :enclose-branches-main :point 0
				 :index (:format
					 ,(rest (assoc :primary
						       (rest (first (find-form-in-spec 'display-params
										       (first branch-specs)))))))
				 :navigation (:format (,(prospec-nav branch-specs)))))
		(meta ,(prospec-adj branch-specs)
		      :if (:type :vista :name :branches-adjunct :breadth :brief
				 :fill :fill-branches-adjunct :enclose :enclose-branches-adjunct)))
	       :if (:type :vista))))))


(defmacro simple-sub-navigation-layout (&key (omit nil))
  "List items for use as menu options for a nav menu displaying the visible branches within a Seed system."
  `(lambda (branch-specs)
     (loop for branch in branch-specs append (let ((branch-name (intern (string-upcase (first branch)) "KEYWORD")))
					       (if (not (find branch-name (list ,@omit)))
						   (list `(meta ,branch-name
								:if (:type :branch-selector
									   :target ,branch-name))))))))

