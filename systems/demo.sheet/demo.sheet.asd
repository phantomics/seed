;;;; demo.sheet.asd

(asdf:defsystem #:demo.sheet
  :description "Describe demo.sheet here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("april")
  :components ((:file "package")
               (:file "setup")
               (:file "lib")
               (:file "sheet")))
