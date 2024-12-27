;;;; portal.model.minimal.asd

(asdf:defsystem #:portal.model.moss
  :description "This is an example of a minimum viable portal for use in Seed."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "moss")
               (:file "seed")))
