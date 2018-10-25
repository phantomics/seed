;;;; seed.media.chart.base.asd

(asdf:defsystem #:seed.media.chart.base
  :description "A set of media supporting the growth of charts and chart entities."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "extension")
               (:file "chart.base")))
