;;;; utilities.lisp

(defmacro generate-html-form (variable &rest items)
  (let ((stream-symbol (gensym)))
    `(let ((,stream-symbol (make-string-output-stream)))
       (cl-who:with-html-output (,stream-symbol)
	 (:div ,@items)
	 (setq ,variable (get-output-stream-string ,stream-symbol))))))
