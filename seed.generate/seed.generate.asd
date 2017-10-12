;;;; seed.generate.asd

(asdf:defsystem #:seed.generate
  :description "The heart of Seed, seed.generate encompasses the means by which Seed systems grow and change."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:asdf #:jonathan #:fare-quasiquote
	       #:quickproject #:symbol-munger #:seed.sublimate)
  :components
  ((:file "package")
   (:file "generate")))
