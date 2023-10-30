;;;; seed.modulate.asd

(asdf:defsystem #:seed.modulate
  :description "Describe seed.modulate here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("com.inuoe.jzon")
  :components ((:file "package")
               (:file "modulate")))
