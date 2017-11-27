;;;; ui-model.stage.lisp

(in-package #:seed.ui-model.stage)

(defun process-specs (items &optional input output)
  "Generate a list of runtime-loadable symbols, function outputs and other data based on input to the stage macro."
  (if (not items)
      output
      (process-specs (rest items)
		     input (if output
			       (append output (list (if (listp (first items))
							(process-specs (first items))
							(if (symbolp (first items))
							    (if (keywordp (first items))
								(first items)
								(list 'quote (first items)))
							    (first items)))))
			       (if (symbolp (first items))
				   (if (not (keywordp (first items)))
				       `(funcall (function ,(first items))
						 ,@(if input (list input)))
				       `(list ,(first items))))))))

(defmacro stage (&key (branches nil) (sub-nav nil))
  "Generate an interface model, or stage, based on parameters specifying stage components."
  (let ((portal (intern "*PORTAL*" (package-name *package*))))
    `(setf (symbol-function (quote ,(intern "BUILD-STAGE" (package-name *package*))))
	   (lambda ()
	     (let ((branch-specs (if (of-sprout-meta ,portal :active-system)
				     (get-portal-contact-branch-specs ,portal (intern (string-upcase 
										       (of-sprout-meta 
											,portal :active-system))
										      "KEYWORD")))))
	       `(((meta ((meta ,,(intern (package-name *package*) "KEYWORD")
			       :if (:type :portal-name))
			 (meta ,(get-portal-contacts ,portal)
			       :if (:type :portal-system-list :index -1)
			       :each (:if (:interaction :select-system)))
			 ,@(if branch-specs `((meta ,,(process-specs sub-nav 'branch-specs)
						    :if (:type :system-branch-list :index 0 :sets (2))
						    :each (:if (:interaction :select-branch))))))
			:if (:type :vista :breadth :short :layout :column :name :portal-specs
				   :fill :fill-overview :enclose :enclose-overview)))
		 (meta ,(if branch-specs ,(process-specs branches 'branch-specs))
		       :if (:type :vista :transparent t))))))))
