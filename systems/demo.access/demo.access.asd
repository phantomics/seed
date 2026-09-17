;;;; demo.access.asd

(asdf:defsystem #:demo.access
  :description "Demonstration of Philo file access with the IS/AS/BY ontology,
and a simple Classic CMS integration for blog article management."
  :author "Andrew Sengul"
  :license "Specify license here"
  :version "0.0.2"
  :serial t
  ;; seed.modulate2 transitively loads seed.modulate and seed.generate, and it
  ;; installs the express/generate bridge hooks that let the new-grammar fx
  ;; forms in catalog.lisp render.
  ;;
  ;; classic.models.common provides the blog preset and article management API.
  ;; It transitively loads classic, classic.schema.alpha, and classic.engine.ref.
  :depends-on ("seed.modulate2" "classic.models.common")
  :components ((:file "package")
               (:file "setup")
               (:file "sheet")))
