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
					     ;; :interaction :select-system
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
     (labels ((prospec-main (specs &optional output)
		(let* ((name (intern (string-upcase (caar specs)) "KEYWORD"))
		       (param-checks (mapcar #'cadr (find-form-in-spec 'is-param (first specs))))
		       (stage-params (cdar (find-form-in-spec 'stage-params (first specs))))
		       (secondary-controls (append (if (find :save param-checks)
						       (list `(meta :save :if (:interaction :commit))))
						   (if (find :revert param-checks)
						       (list `(meta :revert :if (:interaction :revert)))))))
		  (if specs
		      (if (find name (list ,@omit))
			  (prospec-main (rest specs)
					output)
			  (prospec-main
			   (rest specs)
			   (cons `(meta (:body ,@(if secondary-controls (list :sub-controls)))
					:if (:type :vista :ct 0 :fill :fill-branch :branch ,name
						   :extend-response :respond-branches-main :axis :y
						   :secondary-controls (:format (,secondary-controls))
						   :contextual-menu
						   (:format ,,@(if (< 0 (length (getf extend :menu)))
								   (list `(funcall ,(macroexpand
										     (append (getf extend :menu)
											     (list 'meta)))
										   (getf stage-params
											 :contextual-menu)))))))
				 output)))
		      output)))

	      (prospec-nav (specs &optional output)
		(let ((name (intern (string-upcase (caar specs)) "KEYWORD")))
		  (if specs
		      (if (find name (list ,@omit))
			  (prospec-nav (rest specs)
				       output)
			  (prospec-nav (rest specs)
				       (cons name output)))
		      output)))

	      (prospec-adj (specs &optional output)
		(let ((name (intern (string-upcase (caar specs)) "KEYWORD")))
		  (if specs
		      (if (find name (list ,@adjunct))
			  (prospec-adj (rest specs)
				       (cons name output))
			  (prospec-adj (rest specs)
				       output))
		      output))))

       `((meta ((meta ,(reverse (prospec-main branch-specs))
		      :if (:type :vista :name :branches :enclose :enclose-branches-main
				 :navigation (:format (,(reverse (prospec-nav branch-specs))))))
		(meta ,(reverse (prospec-adj branch-specs))
		      :if (:type :vista :name :branches-adjunct :breadth :brief
				 :fill :fill-branches-adjunct :enclose :enclose-branches-adjunct)))
	       :if (:type :vista))))))


(defmacro simple-sub-navigation-layout (&key (omit nil))
  "List items for use as menu options for a nav menu displaying the visible branches within a Seed system."
  `(lambda (branch-specs)
     (loop for branch in branch-specs append (let ((branch-name (intern (string-upcase (first branch)) "KEYWORD")))
					       (if (not (find branch-name (list ,@omit)))
						   (list `(meta ,branch-name
								:if (:type 
								     :branch-selector
								     :target ,branch-name))))))))
