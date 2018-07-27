;;;; seed.app-model.feed.base.asd

(asdf:defsystem #:seed.app-model.feed.base
  :description "Seed application model for content feeds, such as blogs, publishing systems and more."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "feed.base")))
