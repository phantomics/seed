;;;; seed.media.standard.asd

(asdf:defsystem #:seed.media.base
  :description "Standard I/O media for Seed."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:seed.app-model.sheet.base #:drakma #:seed.app-model.document-slate.base)
  :components ((:file "extension")
               (:file "media.base")))

