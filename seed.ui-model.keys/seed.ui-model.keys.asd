;;;; seed.ui-model.keys.asd

(asdf:defsystem #:seed.ui-model.keys
  :description "The model for the key/action associations that enable keyboard input in the Seed interface."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:parenscript #:symbol-munger)
  :components 
  ((:file "package")
   (:file "ui-model.keys")))

