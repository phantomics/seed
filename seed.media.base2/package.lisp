;;;; package.lisp

(defpackage #:seed.media.base2
  (:export #:codec #:get-file #:get-file-text #:put-image #:get-image #:set-type #:set-param #:is-image
	   #:get-value #:form #:code-package #:fork-to #:clipboard #:history
	   )
  (:import-from :seed.generate #:sprout-name #:set-branch-meta)
  (:use #:cl #:seed.generate #:seed.generate.special-access))
