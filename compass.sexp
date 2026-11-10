;;; compass.sexp — Compass project manifest
;;;
;;; Written by compass init. Read with a restricted reader: strings, integers,
;;; keywords, and lists only. Other keys, such as :commands, may be added by
;;; hand (Compass §5, §22).

(:namespaces ("SEED")
 :doc-directory "doc/"
 :federation ((:namespace "VOX" :path "../vox")
              (:namespace "ORIGIN" :path "../origin")
              (:namespace "SPECOPS" :path "../specops"))
 :stewards ((:namespace "SEED" :steward "Andrew Sengul" :approval :solo)))
