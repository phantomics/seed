;;;; demo-drawing.asd

(asdf:defsystem #:demo-drawing
  :description "Describe test-drawing here"
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:cl-who #:seed.sublimate)
  :components 
  ((:file "package")
   (:file "format")
   (:file "main")))

