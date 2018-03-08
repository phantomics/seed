;;;; vector.base.lisp

(in-package #:seed.ui-model.react)

(defvar st-ef)
(setq st-ef (list :text
		  `(lambda (params)
		     (chain params node-enter (append "text")
			    (attr "class" "text")
			    (text (lambda (d) (@ d data name)))))))

(defmacro standard-vector-effects ()
  `(lambda (params)
     (chain params node-enter (append "text")
	    (attr "class" "text")
	    (text (lambda (d) (@ d data name))))))
