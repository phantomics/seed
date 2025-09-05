;;;; seed.access.asd

(asdf:defsystem #:seed.access
  :description "Describe seed.access here"
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :depends-on ("hermetic" "uuid")
  :components ((:file "package")
               (:file "seed.access")))
