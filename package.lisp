;;;; package.lisp

(defpackage #:seed
  (:use #:cl #:arrow-macros #:seed.generate #:seed.sublimate #:parenscript)
  (:export #:interface-interact #:json-convert-to #:json-convert-from))

