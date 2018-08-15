;;;; seed.modes.form.base.asd

(asdf:defsystem #:seed.modes.form.base
  :description "Baseline specifications for modulating forms in Seed."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :components ((:file "form.base")
	       (:file "extension")))

