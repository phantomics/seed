;;;; ui-model.stage.lisp

(in-package #:seed.ui-model.stage)

(defmacro stage (&key (systems nil) (arch nil) (thrust nil))
  (labels ((nest (media-list &optional output)
	     (if media-list
		 (nest (rest media-list)
		       (macroexpand (if (not output)
					(cons (first media-list)
					      (cons nil systems))
					(list (first media-list)
					      output))))
		 output)))
    `(progn (defvar ,(intern "*STAGE-ARCH*" (package-name *package*)))
	    (defvar ,(intern "*STAGE-THRUST*" (package-name *package*)))
	    (setq ,(intern "*STAGE-ARCH*" (package-name *package*))
		  (quote ,(macroexpand (nest arch)))
		  ,(intern "*STAGE-THRUST*" (package-name *package*))
		  (lambda (,(intern "BRANCHES" (package-name *package*)))
		    ,(macroexpand (append (list (first thrust)
						(intern "BRANCHES" (package-name *package*)))
					  (rest thrust))))))))
