;;;; seed.asd

(asdf:defsystem #:seed
  :description "This is the root system for Seed, an interactive software environment. It instantiates the portals and contact points associated with this instance of Seed."
  :author "Andrew Sengul"
  :license "GPL"
  :serial t
  :depends-on (#:seed.contact #:portal.demo1)
  :components 
  ((:file "package")
   (:file "seed")))
