;;;; setup.lisp

(in-package #:portal.demo1)

(defparameter *system* :portal.demo1)

;; (seed :portal.demo1
;;   (:contacts :demo.sheet :abcd)
;;   (:access :to-join join :to-grow grow :to-branch branch :of-system of-system))

(pushnew "x-"   spinneret:*unvalidated-attribute-prefixes* :test #'equal)
(pushnew "hx-"  spinneret:*unvalidated-attribute-prefixes* :test #'equal)
(pushnew "path" spinneret:*unvalidated-attribute-prefixes* :test #'equal)
