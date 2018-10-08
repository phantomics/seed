;;;; seed.ui-model.color.asd

(asdf:defsystem #:seed.ui-model.color
  :description "Models for defining and modulating color palettes for use in Seed's user interface."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :version "0.0.1"
  :serial t
  :depends-on (:dufy)
  :components ((:file "package")
               (:file "ui-model.color")))
