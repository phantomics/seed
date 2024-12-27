;;;; portal.demo1.asd

(asdf:defsystem #:portal.demo1
  :description "Describe portal.demo1 here"
  :author "Your Name <your.name@example.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (;; "seed" ;; "clarion" ;; "spinneret"
               "symbol-munger"
               ;; "panic"
               "arrow-macros"
               "cl-who" ;; "trivia"
               "parenscript" "paren6" "lass"
               ;; "seed.admit"
               "seed.admit"
               "seed.generate"
               "seed.modulate"
               "seed.contact.http"
               "pla.browser.maple"
               )
  :components ((:file "package")
               (:file "setup")
               (:file "demo1")
               (:file "seed")))
