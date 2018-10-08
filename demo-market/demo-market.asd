;;;; demo-market.asd

(asdf:defsystem #:demo-market
  :description "Sample Seed system implementing a market data visualizer."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:local-time :cl-date-time-parser)
  :components ((:file "package")
	       (:file "utils")
               (:file "main")))

