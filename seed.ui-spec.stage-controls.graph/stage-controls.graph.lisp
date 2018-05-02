;;;; stage-controls.graph.lisp

(in-package #:seed.ui-spec.stage.base)

(defmacro stage-controls-graph-base (meta-symbol spec-symbol params-symbol output-symbol)
  (declare (ignorable spec-symbol))
  `(((eq :add-graph-node (first ,params-symbol))
     (cons `(,',meta-symbol :add-node :if (:interaction :add-graph-node))
	   ,output-symbol))
    ((eq :add-graph-link (first ,params-symbol))
     (cons `(,',meta-symbol :add-link :if (:interaction :add-graph-link))
	   ,output-symbol))
    ((eq :remove-graph-object (first ,params-symbol))
     (cons `(,',meta-symbol :delete-object :if (:interaction :remove-graph-object))
	   ,output-symbol))))
