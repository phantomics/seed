;;;; seed.ui-spec.web.base.asd

(asdf:defsystem #:seed.ui-spec.web.base
  :description "Describe seed.ui-spec.web.base here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("clarion")
  :components ((:file "package")
               (:file "seed.ui-spec.web.base")))
