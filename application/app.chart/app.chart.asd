;;;; app.chart.asd

(asdf:defsystem #:app.chart
  :description "Application package of charting tools."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "chart")))
