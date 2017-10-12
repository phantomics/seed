;;;; package.lisp

(defpackage #:seed.model.sheet
  (:use #:cl #:jonathan	#:parse-number)
  (:import-from :swank-backend :arglist)
  (:export #:in-table #:cell #:cells #:to-cell #:cell-right #:cell-left
	   #:cell-up #:cell-down #:make-cell #:row #:col))

