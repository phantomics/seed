;;;; seed.platform-model.router.base.lisp

(in-package #:seed.platform-model.router.base)

(defmacro router (portal-suffix &rest routes)
  (let ((portal-name (format nil "ROUTES.~a" (string-upcase portal-suffix))))
    `(progn (defpackage ,(make-symbol portal-name)
	      (:export)
	      (:use #:cl #:seed.generate))
	    (in-package ,(make-symbol portal-name))
	    (media media-spec-base)
	    (sprout ,(intern portal-name "KEYWORD")
		    :system (:description "This is a route to a grammar-checking service."
			     :license "GPL-3.0")
		    :package ((:use :common-lisp))
		    :branches ((systems (in (put-image))
					(out (set-type :router))))
		    :contacts ,(mapcar (lambda (route)
					 (let ((route-name (first route))
					       (props (rest route)))
					   `(sprout ,(intern (format nil "ROUTE.~a" (string-upcase route-name))
							     "KEYWORD")
						    :package ((:user :common-lisp :cl-who))
						    :branches 
						    ((main (in (put-image)
							       ,@(if (getf props :host)
								     `((remote (:host ,(getf props :host)
										:name ,(if (getf props :system)
											   (getf props :system)
											   (intern route-name 
												   "KEYWORD"))
										:branch ,(if (getf props :branch)
											     (getf props :branch)
											     :main))))))
							   (out (set-type :route)))))))
				       routes))
	    (in-package ,(make-symbol (package-name *package*))))))

