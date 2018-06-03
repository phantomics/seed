;;;; seed.app-model.document-slate.base.asd

(asdf:defsystem #:seed.app-model.document-slate.base
  :description "Seed application model for documents, reflecting the common data structures of the Slate document editing interface built with React.js."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (:cl-who)
  :components ((:file "package")
               (:file "document-slate.base")))

