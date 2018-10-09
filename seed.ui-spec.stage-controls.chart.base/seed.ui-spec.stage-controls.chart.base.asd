;;;; seed.ui-spec.stage-controls.chart.base.asd

(asdf:defsystem #:seed.ui-spec.stage-controls.chart.base
  :description "Common control interface specs for charts, currently with a focus on financial charting."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "extension")
               (:file "chart.base")))
