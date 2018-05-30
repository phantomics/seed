;;;; seed.model.graph.garden-path.asd

(asdf:defsystem #:seed.app-model.graph.garden-path
  :description "Seed application model for 'garden path' graphs modeling environments traversed by user interaction."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:uuid)
  :components ((:file "package")
               (:file "graph.garden-path")))

