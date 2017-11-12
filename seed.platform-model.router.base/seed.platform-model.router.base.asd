;;;; seed.platform-model.router.base.asd

(asdf:defsystem #:seed.platform-model.router.base
  :description "The model for Seed's standard router: a set of portal and contacts that route communication with systems in a standard namespace to specific remote or local destinations."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:seed.generate #:seed.media.base)
  :components ((:file "package")
               (:file "router.base")))

