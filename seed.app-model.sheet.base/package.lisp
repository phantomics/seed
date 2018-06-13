;;;; package.lisp

(defpackage #:seed.app-model.sheet.base
  (:use #:cl #:jonathan	#:parse-number)
  (:import-from :swank-backend :arglist)
  (:export #:interpret-cell #:in-table #:cell #:cells #:to-cell 
	   #:cell-right #:cell-left #:cell-up #:cell-down #:make-cell #:row #:col))

