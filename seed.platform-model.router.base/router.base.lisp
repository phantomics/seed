;;;; router.base.lisp

(in-package #:seed.platform-model.router.base)

(defmacro router (portal-suffix &rest routes)
  "Create a portal that serves as a router for requests to local and/or remote systems. Creates contacted systems within the portal as per the routes passed as arguments."
  (let ((portal-name (format nil "ROUTES.~a" (string-upcase portal-suffix))))
    `(progn (defpackage ,(make-symbol portal-name)
	      (:export)
	      (:use #:cl #:seed.generate))
	    (in-package ,(make-symbol portal-name))
	    
	    (macrolet ((defvar-portal () `(defvar ,(intern "*PORTAL*" ,portal-name)))
		       (ispr (&rest args) (cons (intern "SPROUT" ,portal-name)
						args)))
	      (defvar-portal)
	      (media media-spec-base)
	      (ispr ,(intern portal-name "KEYWORD")
	      	    :system (:description "This is a router."
	      		     :license "GPL-3.0")
	      	    :package ((:use :common-lisp))
	      	    :branches ((systems (in (put-image))
	      				(out (set-type :router))))
	      	    :contacts ,(mapcar (lambda (route)
	      				 (let ((route-name (first route))
	      				       (props (rest route)))
	      				   `(ispr ,(intern (format nil "ROUTE.~a" (string-upcase route-name))
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
	      			       routes)))

	    (in-package ,(make-symbol (package-name *package*))))))

