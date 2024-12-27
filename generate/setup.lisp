;;;; setup.lisp

(in-package #:seed.generate)

(pushnew "x-" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
(pushnew "hx-" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
(pushnew "path" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
