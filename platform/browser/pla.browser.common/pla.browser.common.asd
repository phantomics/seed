;;;; pla.browser.common.asd

(asdf:defsystem #:pla.browser.common
  :description "Describe pla.browser.common here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on ("cl-ppcre" "dexador" "symbol-munger" "spinneret" "lass" "parenscript" "paren6")
  :components ((:file "package")
               (:file "common")))
