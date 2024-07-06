;;;; setup.lisp

(in-package #:seed.generate)

(pushnew "path" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
