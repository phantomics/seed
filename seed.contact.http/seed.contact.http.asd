;;;; seed.contact.http.asd

(asdf:defsystem #:seed.contact.http
  :description "Describe seed.contact.http here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("woo" "clack" "ningle")
  :components ((:file "package")
               (:file "contact.http")))
