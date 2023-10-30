;;;; test.lisp

;; (in-package #:seed.sublimate)

;; (princ (format nil "~%Tests for seed.sublimate:~%"))

;; (defmacro format-add (items) (cons '+ items))

;; (defmacro format-increment-numbers (items) (mapcar (lambda (item)
;; 						     (if (numberp item)
;; 							 (1+ item)
;; 							 item))
;; 						   items))

;; (instantiate-priority-macro-reader
;;   (load (asdf:system-relative-pathname (make-symbol (package-name *package*))
;; 				       "./test-load.lisp")))

;; (princ #\Newline)
