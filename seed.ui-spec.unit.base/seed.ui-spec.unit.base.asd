;;;; seed.ui-spec.unit.base.asd

(asdf:defsystem #:seed.ui-spec.unit.base
  :description "Standard templates for the display of data units in the Seed interface."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components ((:file "extension")
               (:file "unit.base")))

