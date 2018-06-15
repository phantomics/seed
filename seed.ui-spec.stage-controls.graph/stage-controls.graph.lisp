;;;; stage-controls.graph.lisp

(in-package #:seed.ui-spec.stage.base)

(defmacro stage-controls-graph-base (meta-symbol spec-symbol params-symbol output-symbol)
  (declare (ignorable spec-symbol))
  `(((eq :add-graph-node (first ,params-symbol))
     (cons `(,',meta-symbol :add-node :mode (:interaction :add-graph-node))
	   ,output-symbol))
    ((eq :add-graph-link (first ,params-symbol))
     (cons `(,',meta-symbol :add-link :mode (:interaction :add-graph-link))
	   ,output-symbol))
    ((eq :remove-graph-object (first ,params-symbol))
     (cons `(,',meta-symbol :delete-object :mode (:interaction :remove-graph-object))
	   ,output-symbol))))
