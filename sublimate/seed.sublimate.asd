;;;; seed.sublimate.asd

(asdf:defsystem #:seed.sublimate
  :description "By catalyzing the formation of meta-structures beyond standard Common Lisp data structures, seed.sublimate informs and empowers programmers of Seed systems."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:prove)
  :components 
  ((:file "package")
   (:file "sublimate")
   (:file "test")))

