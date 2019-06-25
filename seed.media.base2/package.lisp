;;;; package.lisp

(defpackage #:seed.media.base2
  (:export #:codec #:get-file #:get-file-text #:put-image #:get-image #:set-type #:set-param #:is-param
	   #:is-image #:nullify-image #:get-value #:form #:code-package #:fork-to #:set-stable
	   #:table-specs #:sheet #:set-time #:set-data #:clipboard #:history)
  (:import-from :seed.generate #:sprout-name #:set-branch-meta)
  (:use #:cl #:array-operations #:seed.generate #:seed.generate.special-access))
