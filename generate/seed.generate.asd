;;;; seed.generate.asd

(asdf:defsystem #:seed.generate
  :description "Describe seed.generate here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("cl-csv" "arrow-macros" "clack" "woo" "ningle" "symbol-munger" "parse-number"
                        "quickproject" "spinneret" "cl-who" "trivia"
                        "parenscript" "paren6" "jonathan"
                        "seed.sublimate" "symbol-munger"
                        "com.inuoe.jzon" "trivial-package-local-nicknames"
                        ;; "pla.browser.common"
                        )
  :components ((:file "package")
               (:file "setup")
               (:file "generate")))
