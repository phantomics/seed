;;;; seed.ui-spec.color.base.asd

(asdf:defsystem #:seed.ui-spec.color.base
  :description "Common color palettes and specifications for Seed user interfaces."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "color.base")))
