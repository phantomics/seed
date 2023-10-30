;;;; seed.generate.asd

(asdf:defsystem #:seed.generate
  :description "Describe seed.generate here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("arrow-macros" "clack" "woo" "ningle" "symbol-munger" "parse-number"
                              "spinneret"
                              "cl-who"
                              "trivia"
                              "parenscript" "paren6"
                              "seed.sublimate"
                              "com.inuoe.jzon" "trivial-package-local-nicknames")
  :components ((:file "package")
               (:file "generate")))
