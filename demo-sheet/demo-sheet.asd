;;;; demo-sheet.asd

(asdf:defsystem #:demo-sheet
  :description "This is demoSheet, a package created to demonstrate Seed's spreadsheet module."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial T
  :depends-on (#:april #:seed.model.sheet)
  :components
  ((:file "package")
   (:file "main")))
