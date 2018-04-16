;;;; package.lisp

(defpackage #:seed.model.graph.garden-path
  (:export #:graph-garden-path #:generate-blank-node #:generate-blank-link #:add-blank-node #:add-blank-link)
  (:use #:cl #:cl-utilities #:uuid))
