;;;; seed.ui-spec.form.mode-chart-dygraph.asd

(asdf:defsystem #:seed.ui-spec.form.mode-chart-dygraph
  :description "A template for the display of interactive charts using the dygraphs library."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "extension")
               (:file "form.mode-chart-dygraph")))
