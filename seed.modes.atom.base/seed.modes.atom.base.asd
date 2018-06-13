;;;; seed.modes.atom.base.asd

(asdf:defsystem #:seed.modes.atom.base
  :description "Baseline specifications for modulating atoms in Seed."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components
  ((:file "atom.base")
   (:file "extension")))

