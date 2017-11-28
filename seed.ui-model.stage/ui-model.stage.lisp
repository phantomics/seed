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
