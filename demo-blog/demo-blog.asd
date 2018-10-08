;;;; demo-blog.asd

(asdf:defsystem #:demo-blog
  :description "Sample Seed system implementing a web publishing environemnt."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components ((:file "package")
               (:file "main")))

