;;;; sublimate.lisp

(in-package #:seed.sublimate)

(defmacro expand-1 (form &environment env)
  "Expand a macro by a single step."
  (multiple-value-bind (expansion expanded-p)
      (macroexpand-1 form env)
    `(values ',expansion ',expanded-p)))

(defparameter *opening-parenthesis-handler* (get-macro-character #\())

(defun priority-macro-reader-extension (stream character)
  "Extend a character reader macro, typically for the left/opening parenthesis '(', to check for the presence of certain macro names so that those macros may be expanded in the read phase, before any other macros are expanded."
  (let ((open t)
	(string (make-array 5 :element-type 'character :initial-element #\ )))
    (loop for index from 0 to 4 while open for char = (read-char stream nil) while char
       do (if (char= #\) char) (setq open nil))
	 (setf (aref string index) char))
    (if (and (or (char= #\  (aref string 4))
		 (char= #\Tab (aref string 4))
		 (char= #\Newline (aref string 4))
		 (char= #\Return (aref string 4)))
	     (string= "META" (subseq string 0 4)))
	(macroexpand (read (make-concatenated-stream (make-string-input-stream "(SEED.SUBLIMATE::EXPAND-META ")
						     stream)
			   nil nil t))
	(funcall *opening-parenthesis-handler*
	         (make-concatenated-stream (make-string-input-stream string)
		                           stream)
	         character))))

(defmacro instantiate-priority-macro-reader (&body body)
  "Instantiate the priority macro reader for the opening parenthesis and evaluate the body of code."
  `(let ((*readtable* (copy-readtable *readtable* nil)))
     (set-macro-character #\( #'priority-macro-reader-extension)
     ,@body))

(defmacro expand-meta (form &rest params)
  "Expand a meta form according to a given format."
  (let ((expander (getf params :format))
	(format (gensym))
	(to-format (gensym)))
    (if expander
	(if (symbolp expander)
	    (list expander form)
	    `(macrolet ((,format ,(list to-format)
			  (funcall ,expander ,to-format)))
	       (expand-1 (,format ,form))))
	form)))

(defmacro meta (form &rest params)
  (declare (ignore params))
  "The macro used in evaluation of meta forms. It simply strips the meta information away, leaving the first member of the form to be evaluated."
  form)

(defun fetch-meta (form &optional operation output)
  "Given a form containing meta forms, perform an operation on the meta forms within and return the results in a hierarchical format."
  (if (or (not form)
	  (not (listp form)))
      output
      (fetch-meta (rest form)
		  operation
		  (append (let ((point (first form)))
			    (if (listp point)
				(list (if (and (symbolp (first point))
					       (equal "META" (string-upcase (first point))))
					  (append (funcall (if operation operation (lambda (input) input))
							   (cddr point)) ;(print (cddr point)))
						  (let ((sub-meta (fetch-meta (second point) operation)))
						    (if sub-meta (cons :meta sub-meta))))
					  (fetch-meta point operation)))))
			  output))))
