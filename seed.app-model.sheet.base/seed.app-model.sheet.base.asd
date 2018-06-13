;;;; seed.app-model.sheet.base.asd

(asdf:defsystem #:seed.app-model.sheet.base
  :description "Seed data model for spreadsheet applications."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:jonathan #:parse-number #:swank)
  :components 
  ((:file "package")
   (:file "sheet.base")))

