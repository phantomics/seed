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

#|
(((SEED.UI-SPEC.STAGE.BASE::META
   ((SEED.UI-SPEC.STAGE.BASE::META :PORTAL.DEMO1 :IF (:TYPE :PORTAL-NAME))
    (SEED.UI-SPEC.STAGE.BASE::META "demo-sheet" :IF
     (:OPTIONS
      ((:TITLE "demoSheet" :VALUE "demo-sheet")
       (:TITLE "demoDrawing" :VALUE "demo-drawing"))
      :TYPE :SELECT))
    (SEED.UI-SPEC.STAGE.BASE::META
     ((SEED.UI-SPEC.STAGE.BASE::META :MAIN :IF
       (:TYPE :BRANCH-SELECTOR :TARGET :MAIN))
      (SEED.UI-SPEC.STAGE.BASE::META :CELLS :IF
       (:TYPE :BRANCH-SELECTOR :TARGET :CELLS))
      (SEED.UI-SPEC.STAGE.BASE::META :DRAWING :IF
       (:TYPE :BRANCH-SELECTOR :TARGET :DRAWING)))
     :IF (:TYPE :SYSTEM-BRANCH-LIST :INDEX 0 :SETS (2)) :EACH
     (:IF (:INTERACTION :SELECT-BRANCH))))
   :IF
   (:TYPE :VISTA :BREADTH :SHORT :LAYOUT :COLUMN :NAME :PORTAL-SPECS :FILL
    :FILL-OVERVIEW :ENCLOSE :ENCLOSE-OVERVIEW)))
 (SEED.UI-SPEC.STAGE.BASE::META
  ((SEED.UI-SPEC.STAGE.BASE::META
    ((SEED.UI-SPEC.STAGE.BASE::META
      (((SEED.UI-SPEC.STAGE.BASE::META (:BODY :SUB-CONTROLS) :IF
         (:TYPE :VISTA :CT 0 :FILL :FILL-BRANCH :BRANCH :MAIN :EXTEND-RESPONSE
          :RESPOND-BRANCHES-MAIN :AXIS :Y :SECONDARY-CONTROLS
          (:FORMAT
           (((SEED.UI-SPEC.STAGE.BASE::META :SAVE :IF (:INTERACTION :COMMIT))
             (SEED.UI-SPEC.STAGE.BASE::META :REVERT :IF
              (:INTERACTION :REVERT)))))
          :CONTEXTUAL-MENU
          (:FORMAT
           (((SEED.UI-SPEC.STAGE.BASE::META :INSERT-ADD-OP :IF
              (:INTERACTION :INSERT) :FORMAT (+ 1 2))
             (SEED.UI-SPEC.STAGE.BASE::META :INSERT-MULT-OP :IF
              (:INTERACTION :INSERT) :FORMAT (* 3 4)))))))
        (SEED.UI-SPEC.STAGE.BASE::META (:BODY :SUB-CONTROLS) :IF
         (:TYPE :VISTA :CT 0 :FILL :FILL-BRANCH :BRANCH :CELLS :EXTEND-RESPONSE
          :RESPOND-BRANCHES-MAIN :AXIS :Y :SECONDARY-CONTROLS
          (:FORMAT
           (((SEED.UI-SPEC.STAGE.BASE::META :SAVE :IF
              (:INTERACTION :COMMIT)))))
          :CONTEXTUAL-MENU (:FORMAT (NIL))))))
      :IF
      (:TYPE :VISTA :NAME :BRANCHES :ENCLOSE :ENCLOSE-BRANCHES-MAIN :NAVIGATION
       (:FORMAT (((:MAIN :CELLS))))))
     (SEED.UI-SPEC.STAGE.BASE::META (:CLIPBOARD :HISTORY) :IF
      (:TYPE :VISTA :NAME :BRANCHES-ADJUNCT :BREADTH :BRIEF :FILL
       :FILL-BRANCHES-ADJUNCT :ENCLOSE :ENCLOSE-BRANCHES-ADJUNCT)))
    :IF (:TYPE :VISTA)))
  :IF (:TYPE :VISTA :TRANSPARENT T)))
|#
