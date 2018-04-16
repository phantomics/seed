;;;; ui-model.stage.lisp

(in-package #:seed.ui-model.stage)

(defmacro stage (spec)
  "Generate an interface model, or stage, based on parameters specifying stage components."
  (let ((portal-symbol (intern "*PORTAL*" (package-name *package*)))
	(function-symbol (intern "BUILD-STAGE" (package-name *package*))))
    `(progn (if (not (fboundp (quote ,function-symbol)))
		(defun ,function-symbol ()))
	    ;; declare the function if it doesn't exist, this prevents warnings of an undefined function
	    (setf (symbol-function (quote ,function-symbol))
		  ,(macroexpand (cons (first spec)
				      (cons portal-symbol (rest spec))))))))

(defmacro stage-control-set (&key (by-spec nil) (by-parameters nil))
  "Generate stage control specifications from sub-macros that provide specifications for classes of stage controls. The sub-macros may provide for definition of specifications according to parameters passed to the control bank generation function or according to parameters present in the system I/O spec."
  `(labels ((process-params (spec params &optional output)
	      (if (not params)
		  (funcall (lambda (output)
			     ,@(loop for element in by-spec
				  append (macroexpand (if (listp element)
							  (cons (first element)
								(append (list 'meta 'spec 'params 'output)
									(rest element)))
							  (list element 'meta 'spec 'params 'output)))))
			   output)
		  (process-params spec (rest params)
				  (cond ,@(loop for element in by-parameters
					     append (macroexpand (if (listp element)
								     (cons (first element)
									   (append (list 'meta 'spec
											 'params 'output)
										   (rest element)))
								     (list element 'meta 'spec
									   'params 'output))))
					(t output))))))
     #'process-params))
