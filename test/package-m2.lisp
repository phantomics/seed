;;;; test/package-m2.lisp
;;;;
;;;; Test package for seed.modulate2.

(defpackage #:seed.modulate2.test
  (:use #:cl #:seed.modulate2)
  (:import-from #:fiveam
                #:def-suite #:in-suite #:def-test #:test
                #:is #:is-true #:is-false #:signals #:finishes #:run!)
  (:export #:run-all-tests #:run-suite))
