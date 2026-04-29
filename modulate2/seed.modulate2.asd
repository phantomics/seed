;;;; seed.modulate2.asd

(asdf:defsystem #:seed.modulate2
  :description "Seed interface manifestation system using the IS/AS/BY taxonomy."
  :author "Andrew Sengul"
  :license "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("symbol-munger" "spinneret" "parenscript"
               "seed.modulate")
  :components ((:file "package")
               (:file "modulate2")))
