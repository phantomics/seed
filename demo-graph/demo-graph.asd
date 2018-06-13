;;;; demo-sheet.asd

(asdf:defsystem #:demo-graph
  :description "This is demoGraph, a package created to demonstrate Seed's graph explorer module."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:seed.model.graph.garden-path)
  :components
  ((:file "package")
   (:file "graph")))
