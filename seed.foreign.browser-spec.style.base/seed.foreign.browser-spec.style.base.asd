;;;; seed.foreign.browser-spec.style.base.asd

(asdf:defsystem #:seed.foreign.browser-spec.style.base
  :description "Defines the system through which CSS modules are compiled and built to create the base library supporting Seed interface functions in the browser."
  :author "Andrew Sengul"
  :license "GPL"
  :serial t
  :depends-on (#:parenscript)
  :components ((:file "package")
               (:file "style.base")))

