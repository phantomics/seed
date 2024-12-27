;;;; pla.browser.maple.asd

(asdf:defsystem #:pla.browser.maple
  :description "Describe pla.browser.maple here"
  :author "Andrew Sengul"
  :license  "GPL-3.0"
  :version "0.0.1"
  :serial t
  :depends-on ("symbol-munger" "spinneret" "parenscript" "paren6" "lass"
                               "seed.generate" "seed.contact.http")
  :components ((:file "package")
               (:file "maple")))
