;;;; meta.common.lisp

(in-package #:seed.modulate)

(specify-meta-modes
 modes-meta-common
 (:spiral-points-expand
  (lambda (items)
    (flet ((fibo-plotter (x y scale iterations)
	     (flet ((e-process (value) (exp (* value 0.30635))))
	       (loop for index from 0 to (1- iterations)
		  collect (list (+ x (* (e-process index)
					scale (cos index)))
				(+ y (* (e-process index)
					scale (sin index))))))))
      (let ((center-x (second items)) (center-y (third items)))
	`(:g :id "group2" ,@(mapcar (lambda (point spiral-coordinates)
				      (append point (list :cx (first spiral-coordinates)
							  :cy (second spiral-coordinates))))
				    (mapcar #'caadr (second (fourth items)))
				    (fibo-plotter center-x center-y 3 (length (second (fourth items)))))))))))
