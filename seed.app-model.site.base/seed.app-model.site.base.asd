;;;; seed.app-model.site.base.asd

(asdf:defsystem #:seed.app-model.site.base
  :description "Seed application model with basic facilities for creating HTML pages."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "site.base")))
