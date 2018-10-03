;;;; seed.ui-model.html.asd

(asdf:defsystem #:seed.ui-model.html
  :description "The model used to construct the foundation of Seed's HTML-based interface."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:cl-who #:cl-ppcre #:parenscript #:lass #:symbol-munger #:seed.modulate)
  :components 
  ((:file "package")
   (:file "qualify-build")
   (:file "ui-model.html")))

