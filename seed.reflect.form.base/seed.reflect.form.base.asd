;;;; seed.reflect.form.base.asd

(asdf:defsystem #:seed.reflect.form.base
  :description "Baseline specifications for modulating forms in Seed."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components ((:file "form.base") (:file "extension")))

