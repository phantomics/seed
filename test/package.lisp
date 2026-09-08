;;;; test/package.lisp
;;;;
;;;; Test package for seed.generate.  Uses FiveAM for test definition and
;;;; running.

(defpackage #:seed.generate.test
  (:use #:cl #:seed.generate)
  (:import-from #:fiveam
                #:def-suite #:in-suite #:def-test #:test
                #:is #:is-true #:is-false #:signals #:finishes #:run!)
  (:export #:run-all-tests #:run-suite))
