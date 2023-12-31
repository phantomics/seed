;;;; seed.admit.asd

(asdf:defsystem #:seed.admit
  :description "Describe seed.admit here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("hermetic" "uuid")
  :components ((:file "package")
               (:file "seed.admit")))
