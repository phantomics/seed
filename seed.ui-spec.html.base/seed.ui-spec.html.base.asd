;;;; seed-ui-spec.html.base.asd

(asdf:defsystem #:seed.ui-spec.html.base
  :description "The standard HTML container elements used to display the Seed interface."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:symbol-munger)
  :components ((:file "package")
	       (:file "html.base")))

