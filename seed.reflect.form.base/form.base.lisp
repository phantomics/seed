;;;; form.base.lisp

(in-package #:seed.modulate)

(specify-form-reflection
 reflect-form-base
 (:predicate
  (:enclosed-by (meta))
  :encode ((if (keywordp (first result-output))
	       (setf (getf result-output :am) (cons "meta" (getf result-output :am))
	   	     (getf result-output :mt) 
	   	     (preprocess-structure (cddr form)))
	       (setf (getf (first result-output) :fm)
	   	     (cons "meta" (getf (first result-output) :fm))
	   	     (getf (first result-output) :mt)
	   	     (if (getf (first result-output) :mt)
			 ; if the form macro metadata is being imprinted over existing atom macro metadata
			 ; i.e. the list is subject to a form macro and the atom at the head of the list is also
			 ; subject to an atom macro, put the atom macro metadata into an "atom" property
			 ; prepended to the form metadata
			 (if (getf (first result-output) :am)
			     (append (list :|atom| (getf (first result-output) :mt))
				     (preprocess-structure (cddr form)))
			     (preprocess-structure (cddr form)))
			 (preprocess-structure (cddr form))))))
  :decode ((cons (intern "META")
	   	 (cons form (postprocess-structure (getf original-form :mt))))))
 (:predicate
  (:enclosed-by (quote quasiquote unquote unquote-splicing))))
