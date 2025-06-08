;;;; package.lisp

(defpackage #:seed.contact.http
  (:use #:cl)
  (:shadowing-import-from #:http-body.util #:slurp-stream #:detect-charset)
  (:export #:http-contact-service-start))
