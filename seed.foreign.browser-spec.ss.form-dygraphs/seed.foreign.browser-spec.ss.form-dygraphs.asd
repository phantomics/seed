;;;; seed.foreign.browser-spec.ss.form-dygraphs.asd

(asdf:defsystem #:seed.foreign.browser-spec.ss.form-dygraphs
  :description "Specifies the Javascript packages to include to build the dygraphs display modules."
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :components ((:file "package")
               (:file "ss.form-dygraphs")))
