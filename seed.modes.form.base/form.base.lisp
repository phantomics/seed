;;;; form.base.lisp

(in-package #:seed.modulate)

(specify-form-modes
 modes-form-base
 (:predicate
  (:enclosed-by (meta))
  :to-process (if (and (getf (cddr form) :mode)
		       (getf (getf (cddr form) :mode) :format))
		  (getf (getf (cddr form) :mode) :model)
		  (second form))
  :encode ((if (keywordp (first result-output))
	       (setf (getf result-output :am) (cons "meta" (getf result-output :am))
	   	     (getf result-output :mt)
	   	     (preprocess-structure (cddr form)))
	       (setf (getf (first result-output) :fm)
	   	     (cons "meta" (getf (first result-output) :fm))
	   	     (getf (first result-output) :mt)
		     (let* ((meta-content (cddr form))
			    (processed-meta-content
			     (progn (if (and (getf meta-content :mode)
					     (getf (getf meta-content :mode) :model))
				    	(setf (getf (getf meta-content :mode) :model)
				    	      nil
				    	      (getf (getf meta-content :mode) :value)
				    	      (second form)))
				    (preprocess-structure meta-content))))
		       (if (and (getf (first result-output) :mt)
				(getf (first result-output) :am))
			   ;; if the form macro metadata is being imprinted over existing atom macro metadata
			   ;; i.e. the list is subject to a form macro and the atom at the head of the list is also
			   ;; subject to an atom macro, put the atom macro metadata into an "atom" property
			   ;; prepended to the form metadata
			   (append (list :|atom| (getf (first result-output) :mt))
				   processed-meta-content)
			   processed-meta-content)))))
  :decode ((let ((meta-content (postprocess-structure (getf original-form :mt))))
	     (if (and (getf meta-content :mode)
	     	      (not (getf (getf meta-content :mode) :model)))
	     	 (setf (getf (getf meta-content :mode) :model)
	     	       form
	     	       (getf (getf meta-content :mode) :value)
	     	       nil))
	     (cons (intern "META")
		   (cons (if (getf (getf meta-content :mode) :format)
			     (meta-format (getf (getf meta-content :mode) :format)
					  (getf (getf meta-content :mode) :model))
			     form)
			 meta-content)))))
 (:predicate
  (:enclosed-by (quote quasiquote unquote unquote-splicing))))
#|
 (:predicate
  (:enclosed-by (meta))
  :to-process (if (and (getf (cddr form) :mode)
		       (getf (getf (cddr form) :mode) :format))
		  (getf (getf (cddr form) :mode) :model)
		  (second form))
  :encode ((if (keywordp (first result-output))
	       (setf (getf result-output :am) (cons "meta" (getf result-output :am))
	   	     (getf result-output :mt)
		     (let ((meta-content (cddr form)))
		       (if (getf meta-content :mode)
			   (setf (getf (getf meta-content :mode) :model)
				 nil
				 (getf (getf meta-content :mode) :content)
				 (second form)))
		       (preprocess-structure meta-content)))
	       (setf (getf (first result-output) :fm)
	   	     (cons "meta" (getf (first result-output) :fm))
	   	     (getf (first result-output) :mt)
		     (let* ((meta-content (cddr form))
			    (processed-meta-content
			     (progn (if (getf meta-content :mode)
					(setf ;;(getf (getf meta-content :mode) :model)
					      ;;nil
					      (getf (getf meta-content :mode) :content)
					      (second form)))
				    (print (list :sc (second form)))
				    (preprocess-structure meta-content))))
		       (print (list :sc (second form)))
		       (if (getf (first result-output) :mt)
			 ;; if the form macro metadata is being imprinted over existing atom macro metadata
			 ;; i.e. the list is subject to a form macro and the atom at the head of the list is also
			 ;; subject to an atom macro, put the atom macro metadata into an "atom" property
			 ;; prepended to the form metadata
			 
			   (if (getf (first result-output) :am)
			       (append (list :|atom| (getf (first result-output) :mt))
				       processed-meta-content)
			       processed-meta-content)
			   processed-meta-content)))))
  :decode ((let ((meta-content (postprocess-structure (getf original-form :mt))))
	     (print (list :mmt form meta-content))
	     (cons (intern "META")
		   (cons (if (getf (getf meta-content :mode) :format)
			     (meta-format (getf (getf meta-content :mode) :format)
					  (getf (getf meta-content :mode) :model))
			     form)
			 meta-content)))))
|#
