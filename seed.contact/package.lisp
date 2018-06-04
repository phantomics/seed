;;;; package.lisp

(defpackage #:seed.contact
  (:export #:contact-create-in #:contact-remove-in #:contact-remove-all-in #:contact-open-in #:contact-close-in)
  (:use #:cl #:cl-utilities #:jonathan #:symbol-munger #:hunchentoot #:seed.modulate))
