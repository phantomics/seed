;;;; package.lisp

(defpackage #:portal.demo1
  (:use #:cl ;; #:seed ;; #:clarion ;; #:spinneret
        #:seed.admit
        #:cl-who
        #:arrow-macros 
        #:parenscript #:paren6 #:lass #:symbol-munger)
  ;; (:shadowing-import-from #:trivia #:match #:guard)
  ;; (:shadowing-import-from #:seed.admit #:auth-setup #:authorize)
  (:shadowing-import-from #:seed.contact.http #:http-contact-service-start)
  (:shadowing-import-from #:seed.generate #:json-convert-to #:json-convert-from #:portal-endpoint
                          #:htrender #:uic #:in-system-context #:render-html-interface
                          #:seed2 #:uispec #:encode #:render-web #:interface-format-form
                          #:load-seed-system)
  (:shadowing-import-from #:seed.admit #:authorize)
  ;; (:shadowing-import-from #:spinneret #:with-html #:with-html-string #:interpret-html-tree)
  )
