;;;; demo.access.asd

(asdf:defsystem #:demo.access
  :description "Demonstration of Philo file access with the IS/AS/BY ontology."
  :author "Andrew Sengul"
  :license "Specify license here"
  :version "0.0.1"
  :serial t
  ;; seed.modulate2 transitively loads seed.modulate and seed.generate, and it
  ;; installs the express/generate bridge hooks that let the new-grammar fx
  ;; forms in catalog.lisp render.
  :depends-on ("seed.modulate2")
  :components ((:file "package")
               (:file "setup")
               (:file "sheet")))
