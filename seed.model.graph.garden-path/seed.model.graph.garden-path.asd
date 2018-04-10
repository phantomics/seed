;;;; seed.model.graph.garden-path.asd

(asdf:defsystem #:seed.model.graph.garden-path
  :description "Seed data model for 'garden path' graphs modeling environments traversed by user interaction."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:uuid)
  :components ((:file "package")
               (:file "graph.garden-path")))

