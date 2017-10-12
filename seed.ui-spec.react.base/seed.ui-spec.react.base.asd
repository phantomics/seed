;;;; seed.ui-spec.react.base.asd

(asdf:defsystem #:seed.ui-spec.react.base
  :description "The standard React components for the Seed interface."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:parenscript #:panic)
  :components ((:file "package")
               (:file "react.base")))

