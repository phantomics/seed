;;;; contact.lisp

(in-package #:seed.contact)

(defparameter *my-acceptor*
  (make-instance 'hunchentoot:easy-acceptor 
		 ;:address
		 ;"localhost"
		 :port 8085
		 :document-root
		 (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
						"../")))

;(setq *dispatch-table*
;      (cons (hunchentoot:create-static-file-dispatcher-and-handler "/bla"
;								   #P"/tmp/bla/hi.txt")
;	    (list 'dispatch-easy-handlers)))

(define-easy-handler (seed-grow :uri "/portal") ()
  (setf (hunchentoot:content-type*) "text/plain")
  (let ((request-type (hunchentoot:request-method hunchentoot:*request*)))
    (cond ((eq :get request-type)
	   "Not available.")
	  ((eq :post request-type)
	   (let* ((input (jonathan:parse (hunchentoot:raw-post-data :force-text t)
					 :keyword-normalizer (lambda (key)
							       (string-upcase (camel-case->lisp-name key)))
					 :normalize-all t))
		  (package-string (string-upcase (first input)))
		  (function-string (string-upcase (second input)))
		  (system-string (if (third input) (string-upcase (third input)))))
	     (print (list :in input))
	     (jonathan:to-json
	       ;(print 
		;(coder system-string
		      (if (and (or (find-package package-string)
				   (asdf:load-system (intern package-string)))
			       (find-symbol function-string package-string))
			  (multiple-value-bind (func-sym locality)
			      (intern function-string package-string)
			    (if (eq :external locality)
				(apply func-sym
				       ; the package string is always at
				       ; the head of the argument list
				       (append (list (intern package-string "KEYWORD"))
					       (mapcar (lambda (param)
							 (if (stringp param)
							     (intern (string-upcase param) "KEYWORD")
							     (if (listp (first param))
								 (decoder param)
								 param)))
						       (cddr input)))))))
		      ;))
	       ;:key-normalizer #'lisp->camel-case
	       ))))))

;symbols above from packages jsown, seed-codec and seed-server

;(jonathan:to-json '(:a 1 :b 2 :c-test 3) :key-normalizer #'lisp->camel-case)

(defun so () (start *my-acceptor*))

(defun sc () (stop *my-acceptor*))


; (asdf:load-system 'seed-interface)(asdf:load-system 'my-portal)(seed-interface::so)(in-package :my-portal)(grow)
; (progn (asdf:load-system 'seed-lib-table) (asdf:load-system 'imago) (load "~/src/lisp/seed-app/test-table2/package.lisp") (load "~/src/lisp/seed-app/test-image/package.lisp"))
; (load "~/src/lisp/seed-app/test-table/package.lisp")
; (encoder '(cons 4 (list 3 4 (list nil 8 "abc" (cons 4 (list 9 9))))))
; (gethash :merged (multiple-value-bind (data breadth depth) (encoder '((+ 1 2 2 3 5))) (encode-meta data (list breadth depth) process-list)))

; (seed.generate::branch-image (seed.generate::find-branch-by-name :main (seed.generate::contact-to (seed.generate::find-contact-by-sprout-name *portal* :test-table2))))

; (main (:form) (in (express :file :-self) (process :eval) (media :table-specs) (contingency :main))
; (main (in (model (table-specs)) (realize (file :-self :eval)) (contingency :main))
;       (out (model (table-specs)) (express (file :-self) (form))))
; three actions - express, model, realize
