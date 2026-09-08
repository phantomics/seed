;;;; seed.generate.test.asd
;;;;
;;;; Test suite for seed.generate, using FiveAM.

(asdf:defsystem #:seed.generate.test
  :description "Test suite for seed.generate (starting with philo)."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on ("seed.generate" "fiveam")
  :components ((:file "package")
               (:file "helpers")
               (:file "test-philo"))
  :perform (test-op (o s)
             (uiop:symbol-call :seed.generate.test :run-all-tests)))
