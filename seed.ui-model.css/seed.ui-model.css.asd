;;;; seed.ui-model.css.asd

(asdf:defsystem #:seed.ui-model.css
  :description "Models by which the CSS for Seed's Web interface are generated."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:dufy :optima)
  :components ((:file "package")
               (:file "ui-model.css")))

