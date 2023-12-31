;;;; package.lisp

(defpackage #:portal.demo1
  (:use #:cl #:seed #:clarion ;; #:spinneret
        #:cl-who
        #:parenscript #:paren6 #:lass #:symbol-munger)
  ;; (:shadowing-import-from #:trivia #:match #:guard)
  ;; (:shadowing-import-from #:seed.admit #:auth-setup #:authorize)
  (:shadowing-import-from #:seed.contact.http #:http-contact-service-start)
  (:shadowing-import-from #:seed.generate #:json-convert-to #:json-convert-from #:portal-endpoint)
  ;; (:shadowing-import-from #:spinneret #:with-html #:with-html-string #:interpret-html-tree)
  )
