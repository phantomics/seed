;;;; package.lisp

(defpackage #:seed.contact
  (:export #:contact-create #:contact-remove #:contact-remove-all #:contact-open #:contact-close)
  (:use #:cl #:cl-utilities #:jonathan #:symbol-munger #:hunchentoot #:seed.modulate))
