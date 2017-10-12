;;;; seed.reflect.atom.base.asd

(asdf:defsystem #:seed.reflect.atom.base
  :description "Baseline specifications for modulating atoms in Seed."
  :author "Andrew Sengul"
  :license "GPL"
  :serial t
  :components
  ((:file "atom.base")
   (:file "extension")))

