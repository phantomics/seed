;;;; seed.media.base2.asd

(asdf:defsystem "seed.media.base2"
  :description "Standard I/O media for Seed."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :depends-on ("seed.generate")
  :components ((:file "package")
               (:file "media.base2")))
