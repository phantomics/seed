(defpackage #:seed.modulate
  (:export #:encode #:decode #:display-format-predicate #:modes
           #:glyphs #:specify-glyphs #:preprocess-structure #:symbol-jstring-process #:postprocess-structure)
  (:use #:common-lisp #:cl-utilities #:fare-quasiquote #:cl-ppcre #:parse-number #:symbol-munger))
