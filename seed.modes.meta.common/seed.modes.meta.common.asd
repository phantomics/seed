;;;; seed.modes.meta.common.asd

(asdf:defsystem #:seed.modes.meta.common
  :description "A set of common meta-formats, used to transform code when it is written according to meta-properties."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components ((:file "extension")
               (:file "meta.common")))

