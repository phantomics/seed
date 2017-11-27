;;;; test-core-systems.lisp

(in-package #:portal.demo1)

;; tests of the seed.generate and seed.modulate systems are run in the portal, 
;; because these systems are extended as part of the portal's build process.

(defvar test-sprout)

(defmacro test-core-systems ()
  `(progn
     (princ (format nil "~%Tests for seed.generate:~%"))

     (portal.demo1::sprout
      :test-system :system (:description "This is a test system." :author "Somebody" :license "GPL-3.0")
      :meta (:symbol test-sprout)
      :package ((:use :common-lisp) (:export))
      :branches ((branch1 (in (set-time)
			      (if-condition (is-display-format) (:then (codec)))
			      (fork-to :history) (put-image))
			  (out (set-type :form)
			       (if-condition (is-image :not)
					     (:then (put-image (get-file :-self)) (code-package)
						    (set-time) (fork-to :history) (put-image) (codec)))
			       (set-data (get-image)) (codec)))
		 (branch2 (out (set-type :html-element :svg)
			       (if-condition (is-image :not)
					     (:then (get-value :svg-content)))))))

     (princ (format nil "~%  Fetching basic system data:~%"))
     (is (seed.generate::sprout-name test-sprout)
	 :test-system)

     (is (seed.generate::sprout-system test-sprout)
	 '(:description "This is a test system." :author "Somebody" :license "GPL-3.0"))

     (princ (format nil "~%  Describing systems:~%"))
     (is (write-to-string (seed.generate::describe-as-package test-sprout))
	 (write-to-string '(defpackage #:test-system (:use :common-lisp) (:export))))

     (is (write-to-string (seed.generate::describe-as-asdf-system test-sprout))
	 (write-to-string '(asdf/defsystem:defsystem #:test-system
			    (:description "This is a test system." :author "Somebody" :license "GPL-3.0"
			     :components nil))))

     (let ((branches (seed.generate::sprout-branches test-sprout)))
       (princ (format nil "~%  System branch data:~%"))
       (is (seed.generate::branch-name (first branches)) :branch1)
       (is (seed.generate::branch-name (second branches)) :branch2)
       (ok (getf (seed.generate::branch-meta (first branches)) :stable))
       (is (seed.generate::branch-spec (second branches))
	   '(branch2 (out (set-type :html-element :svg)
		      (if-condition (is-image :not)
		       (:then (get-value :svg-content)))))))

     (princ (format nil "~%Tests for seed.modulate:~%"))

     (princ (format nil "~%  Encode and decode:~%"))

     (let ((test-list '((+ 1 2) (* 3 4)))
	   (encoded (seed.modulate::atom-to-jsform 'a nil)))
       (is test-list (seed.modulate::decode-expr (seed.modulate::encode-expr test-list)))
       (is encoded '(:vl "a" :ti (("a")) :ty ("symbol") :ix 1))

       (princ (format nil "~%  Format predicate:~%"))
       (ok (seed.modulate::display-format-predicate (list encoded)))
       ;; atom must be within a list to pass the displayFormatPredicate

       (princ (format nil "~%  Structural transformation:~%"))
       (is (seed.modulate::downcase-jsform encoded)
	   '(:|ix| 1 :|ty| ("symbol") :|ti| (("a")) :|vl| "a"))
       (is (seed.modulate::preprocess-structure '(:ab-cd 1 :ef "test" :gh :ij :k l))
	   '(:|k| "_l" :|gh| "__ij" :|ef| "test" :|abCd| 1)))
     
     (princ #\Newline)))
