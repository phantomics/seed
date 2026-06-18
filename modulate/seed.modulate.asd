;;;; seed.modulate.asd

(asdf:defsystem #:seed.modulate
  :description "Describe seed.modulate here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("symbol-munger" "spinneret" "parenscript" "com.inuoe.jzon"
                               "seed.generate" ;; "seed.modulate2"
                               )
  :components ((:file "package")
               (:file "modulate")))
