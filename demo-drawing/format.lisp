;;;; format.lisp

(in-package #:demo-drawing)

(defmacro define-stream (symbol)
  `(defvar ,symbol (make-string-output-stream)))

(defmacro gen-svg (&rest form)
  (let ((stream-symbol (gensym)))
    `(let ((,stream-symbol (make-string-output-stream)))
       (defvar svg-content)
       (cl-who:with-html-output (,stream-symbol)
	 (:svg ,@form))
       (setq svg-content (get-output-stream-string ,stream-symbol)))))

;; (defmacro gen-svg (&rest form)
;;   (let ((stream-symbol (gensym)))
;;     (fare-quasiquote:quasiquote
;;      (progn (defvar svg-content)
;; 	    (defvar (fare-quasiquote:unquote stream-symbol)
;; 	      (make-string-output-stream))
;; 	    (cl-who:with-html-output ((fare-quasiquote:unquote stream-symbol))
;; 	      (:svg (fare-quasiquote:unquote-splicing form)))
;; 	    (setq svg-content (get-output-stream-string (fare-quasiquote:unquote stream-symbol)))))))

(defmacro rgb-hex-string (color-string) color-string)

(defun fibo-plotter (x y scale iterations)
  (let ((e 2.7182818284))
    (flet ((e-process (value) (expt e (* value 0.30635))))
      (loop for index from 0 to (1- iterations)
	 collect (list (+ x (* (e-process index)
			       scale (cos index)))
		       (+ y (* (e-process index)
			       scale (sin index))))))))

(defmacro spiral-points-expand (items)
  (let ((center-x (second items)) (center-y (third items)))
    `(:g :id "group2" ,@(mapcar (lambda (point spiral-coordinate)
				  (append point (list :cx (first spiral-coordinate)
						      :cy (second spiral-coordinate))))
				(mapcar #'first (fourth items))
				(fibo-plotter center-x center-y 3 (length (fourth items)))))))
