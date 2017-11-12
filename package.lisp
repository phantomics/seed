;;;; package.lisp

(defpackage #:seed
  (:export #:contact-open #:contact-close)
  (:use #:cl #:seed.contact #:seed.generate #:seed.platform-model.router.base))
