;;;; seed.model.sheet.asd

(asdf:defsystem #:seed.model.sheet
  :description "Seed data model for spreadsheet applications."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:jonathan #:parse-number #:swank)
  :components 
  ((:file "package")
   (:file "model.sheet")))

