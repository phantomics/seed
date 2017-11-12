;;;; seed.reflect.atom.base.asd

(asdf:defsystem #:seed.reflect.atom.base
  :description "Baseline specifications for modulating atoms in Seed."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components
  ((:file "atom.base")
   (:file "extension")))

