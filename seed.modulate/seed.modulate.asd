(asdf:defsystem #:seed.modulate
  :description "The seed.modulate system mediates the external and internal representations of data used by Seed."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:fare-quasiquote #:cl-ppcre #:cl-utilities #:parse-number #:symbol-munger)
  :components 
  ((:file "package")
   (:file "modulate")))
