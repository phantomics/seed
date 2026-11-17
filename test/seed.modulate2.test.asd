;;;; seed.modulate2.test.asd
;;;;
;;;; Test suite for seed.modulate2 (IS/AS/BY ontology, manifestation pipeline),
;;;; using FiveAM.

(asdf:defsystem #:seed.modulate2.test
  :description "Test suite for seed.modulate2: expression, construction, rendering."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on ("seed.modulate2" "fiveam")
  :components ((:file "package-m2")
               (:file "helpers-m2")
               (:file "test-modulate2"))
  :perform (test-op (o s)
             (uiop:symbol-call :seed.modulate2.test :run-all-tests)))
