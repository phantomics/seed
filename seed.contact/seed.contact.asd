;;;; seed.contact.asd

(asdf:defsystem #:seed.contact
  :description "This system is the point of contact between Seed systems and the larger network, routing HTTP requests to the appropriate handler functions and returning output."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:jonathan #:symbol-munger #:hunchentoot #:seed.modulate)
  :components 
  ((:file "package")
   (:file "contact")))
