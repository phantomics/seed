;;;; setup.lisp

(in-package #:portal.demo1)

(pushnew "x-" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
(pushnew "hx-" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
(pushnew "path" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
