;;;; seed.media.graph.garden-path.asd

(asdf:defsystem #:seed.media.graph.garden-path
  :description "A set of media supporting the growth of garden path graph structures."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:uuid #:seed.model.graph.garden-path)
  :components ((:file "extension")
               (:file "graph.garden-path")))

