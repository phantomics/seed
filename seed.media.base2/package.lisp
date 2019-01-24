;;;; package.lisp

(defpackage #:seed.media.base2
  (:export #:codec #:get-file #:get-file-text #:put-image #:get-image #:set-type #:set-param)
  (:import-from :seed.generate #:sprout-name #:set-branch-meta)
  (:use #:cl #:seed.generate #:seed.generate.special-access))
