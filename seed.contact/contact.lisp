;;;; contact.lisp

(in-package #:seed.contact)

(defvar *contact-list* nil)

(define-easy-handler (seed-grow :uri "/portal") ()
  (setf (content-type*) "text/plain")
  (let ((request-type (hunchentoot:request-method hunchentoot:*request*)))
    (cond ((eq :get request-type)
	   "Not available.")
	  ((eq :post request-type)
	   (let* ((input (let ((mime-type (first (split-sequence #\; (rest (assoc :content-type (headers-in*)))))))
			   (cond ((string= mime-type "application/json")
				  ; convert JSON Lisp format with jonathan
				  (jonathan:parse (hunchentoot:raw-post-data :force-text t)
						  :keyword-normalizer
						  (lambda (key) (string-upcase (camel-case->lisp-name key)))
						  :normalize-all t))
				 ((string= mime-type "application/x-lisp")
				  ; native Lisp text is passed directly through and read
				  (read-from-string (hunchentoot:raw-post-data :force-text t))))))
		  (package-string (string-upcase (first input)))
		  (function-string (string-upcase (second input))))
	     ;(print (list :iin input (headers-in*)))
	     (jonathan:to-json (if (and (or (find-package package-string)
					    (asdf:load-system (intern package-string)))
					(find-symbol function-string package-string))
				   (multiple-value-bind (function-symbol locality)
				       (intern function-string package-string)
				     (if (eq :external locality)
					 ; only allow the use of functions that are exported in the portal package
					 (apply function-symbol
					        ; the package string is always at the head of the argument list
						(append (list (intern package-string "KEYWORD"))
							(mapcar (lambda (param)
								  (if (stringp param)
								      (intern (string-upcase param) "KEYWORD")
								      param))
								(cddr input)))))))))))))

(defmacro contact-create (name &key (port nil) (root nil))
  `(setf (getf *contact-list* ,(intern (string-upcase name) "KEYWORD"))
	 (list :port ,port
	       :instance (make-instance 'hunchentoot:easy-acceptor
					:port ,port
					:document-root (asdf:system-relative-pathname
							(make-symbol (package-name *package*))
							,root)))))

(defmacro contact-remove (name)
  `(setf (getf *contact-list* ,(intern (string-upcase name) "KEYWORD"))
	 nil))

(defmacro contact-remove-all ()
  `(setq *contact-list* nil))

(defmacro contact-open (&optional name) 
  (let ((contact (gensym)))
    `(let ((,contact ,(if name `(getf *contact-list* ,(intern (string-upcase name) "KEYWORD"))
			  ; if no contact name is given, open the first contact instance in the list
			  `(second *contact-list*))))
       (start (getf ,contact :instance))
       (princ (format nil "~%Seed contact now open and listening at port ~d.~%~%" (getf ,contact :port)))
       nil)))

(defmacro contact-close (&optional name) 
  (let ((contact (gensym)))
    `(let ((,contact ,(if name `(getf *contact-list* ,(intern (string-upcase name) "KEYWORD"))
		          ; if no contact name is given, close the first contact instance in the list
			  `(second *contact-list*))))
     (stop (getf ,contact :instance))
     (princ (format nil "~%Seed contact at port ~d now closed.~%~%" (getf ,contact :port)))
     nil)))
