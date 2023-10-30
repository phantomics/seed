;;;; seed.asd

(asdf:defsystem #:seed
  :description "Seed system - MORE DESCRIPTION LATER"
  :author "Andrew Sengul"
  :license ""
  :version "0.0.1"
  :serial t
  :depends-on ("arrow-macros" "seed.generate" "seed.sublimate") ;  "seed.modulate")
  :components ((:file "package")
               (:file "seed")))
