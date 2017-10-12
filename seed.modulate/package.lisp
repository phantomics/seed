(defpackage #:seed.modulate
  (:export #:encode #:decode #:display-format-predicate #:reflect
           #:glyphs #:specify-glyphs #:preprocess-structure #:postprocess-structure)
  (:use #:common-lisp #:cl-utilities #:fare-quasiquote #:cl-ppcre #:parse-number #:symbol-munger))
