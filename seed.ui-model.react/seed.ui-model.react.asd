;;;; seed.ui-model.react.asd

(asdf:defsystem #:seed.ui-model.react
  :description "The model for React component templats used in the Seed interface."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:parenscript #:panic)
  :components 
  ((:file "package")
   (:file "ui-model.react")))

