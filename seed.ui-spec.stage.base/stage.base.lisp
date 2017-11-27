;;;; seed.ui-spec.stage.base.lisp

(in-package #:seed.ui-spec.stage.base)

(defmacro simple-portal-layout (body &rest params)
  (declare (ignore body))
  `(((meta ((meta ,(intern (package-name *package*) "KEYWORD")
		  :if (:type :portal-name))
	    (meta ,params :if (:type :portal-system-list :index -1)
			  :each (:if (:interaction :select-system)))
	    ;;(meta nil :if (:type :system-branch-list :index 0 :sets (2))
	    ;;:each (:if (:interaction :select-branch-set)))
	    )
	   :if (:type :vista :breadth :short :layout :column :name :portal-specs
		:fill :fill-overview :enclose :enclose-overview)))
    (meta nil :if (:type :vista :fill :fill-main-stage :transparent t))))

(defun simple-branch-layout (branch-specs &key (omit nil) (adjunct nil) (extend nil))
  "A layout for display of major and adjunct branches within a Seed system."
  (labels ((prospec-main (specs &optional output)
	     (let* ((name (intern (string-upcase (caar specs)) "KEYWORD"))
		    (param-checks (mapcar #'cadr (find-form-in-spec 'is-param (first specs))))
		    (stage-params (cdar (find-form-in-spec 'stage-params (first specs))))
		    (secondary-controls (append (if (find :save param-checks)
						    (list `(meta :save :if (:interaction :commit))))
						(if (find :revert param-checks)
						    (list `(meta :revert :if (:interaction :revert)))))))
	       (if specs
		   (if (find name omit)
		       (prospec-main (rest specs)
				     output)
		       (prospec-main
			(rest specs)
			(cons `(meta (:body ,@(if secondary-controls (list :sub-controls)))
				     :if (:type :vista :ct 0 :fill :fill-branch :branch ,name
						:extend-response :respond-branches-main :axis :y
						:secondary-controls (:format (,secondary-controls))
						:contextual-menu
						(:format ,(if (getf extend :menu)
							      (funcall (getf extend :menu)
								       'meta (getf stage-params 
										   :contextual-menu))))))
			      output)))
		   output)))

	   (prospec-nav (specs &optional output)
	     (let ((name (intern (string-upcase (caar specs)) "KEYWORD")))
	       (if specs
		   (if (find name omit)
		       (prospec-nav (rest specs)
				    output)
		       (prospec-nav (rest specs)
				    (cons name output)))
		   output)))

	   (prospec-adj (specs &optional output)
	     (let ((name (intern (string-upcase (caar specs)) "KEYWORD")))
	       (if specs
		   (if (find name adjunct)
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
	    :if (:type :vista)))))

(defun simple-sub-navigation-layout (branch-specs &key (omit nil))
  "List items for use as menu options for a nav menu displaying the visible branches within a Seed system."
  (loop for branch in branch-specs append (let ((branch-name (intern (string-upcase (first branch)) "KEYWORD")))
					    (if (not (find branch-name omit))
						(list branch-name)))))
