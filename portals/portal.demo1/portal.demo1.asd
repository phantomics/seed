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
               "quickproject"
               "seed.access"
               "seed.generate"
               "seed.modulate"
               "seed.sublimate"
               "seed.contact.http"
               "pla.browser.maple"
               "app.chart"
               )
  :components ((:file "package")
               (:file "setup")
               (:file "demo1")
               (:file "seed")))
