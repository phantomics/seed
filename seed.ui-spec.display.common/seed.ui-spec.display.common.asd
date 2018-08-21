;;;; seed.ui-spec.display.common.asd

(asdf:defsystem #:seed.ui-spec.display.common
  :description "Display templates for common types of static data within Seed's browser interface."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "extension")
               (:file "display.common")))
