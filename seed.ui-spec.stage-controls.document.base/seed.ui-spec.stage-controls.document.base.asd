;;;; seed.ui-spec.stage-controls.document.base.asd

(asdf:defsystem #:seed.ui-spec.stage-controls.document.base
  :description "A set of standard control interface specs for rich text documents."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components ((:file "extension")
               (:file "document.base")))
