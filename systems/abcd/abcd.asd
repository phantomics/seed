;;;; abcd.asd

;;; Seed template: template.charts
;;; a template for charts

(asdf:defsystem #:abcd
  :description "Describe abcd here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("april" "app.chart")
  :components ((:file "package")
               (:file "setup")
               (:file "sheet")))

