;;;; seed.ui-spec.stage-controls.document.base.lisp

(in-package #:seed.ui-spec.stage.base)

(defmacro stage-controls-document-base (meta-symbol spec-symbol params-symbol output-symbol)
  (declare (ignorable spec-symbol))
  `(((eq :doc-mark-bold (first ,params-symbol))
     (cons `(,',meta-symbol :bold :if (:interaction :doc-mark-bold))
	   ,output-symbol))
    ((eq :doc-mark-italic (first ,params-symbol))
     (cons `(,',meta-symbol :italic :if (:interaction :doc-mark-italic))
	   ,output-symbol))
    ((eq :doc-node-quote (first ,params-symbol))
     (cons `(,',meta-symbol :quote :if (:interaction :doc-node-quote))
	   ,output-symbol))
    ((eq :doc-node-pgraph (first ,params-symbol))
     (cons `(,',meta-symbol :paragraph :if (:interaction :doc-node-pgraph))
	   ,output-symbol))))
