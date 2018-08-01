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
				    (fibo-plotter center-x center-y 3 (length (second (fourth items))))))))))
 (:raster-process-layers-expand
  (lambda (items)
    (let ((output (loop :for item :in items :append
		     (let ((type (getf (getf (getf (cddr item) :mode) :format-properties) :type)))
		       (cond ((eq :off (getf (getf (cddr item) :mode) :toggle))
			      nil)
			     ((eq :load type)
			      `((:load :path ,(second (caaadr item)))))
			     ((eq :apl type)
			      `((:apl :exp ,(second (caaadr item)))))
			     ((eq :output type)
			      `((:output :path ,(second (caaadr item))))))))))
      (cons (intern "RASTER-PROCESS-LAYERS" (package-name *package*))
	    output))))
 (:html-form-components-expand
  (lambda (items)
    (let ((output (loop :for item :in items :append
		     (let ((type (getf (getf (getf (cddr item) :mode) :format-properties) :type)))
		       (cond ((eq :section-title type)
			      `((:h2 ,(second (caaadr item)))))
			     ((eq :form-field type)
			      `((:div (:label ,(second (caaadr item))) (:br)
				      (:input)))))))))
      (append (list (intern "GENERATE-HTML-FORM" (package-name *package*))
		    (intern "FORM-OUTPUT" (package-name *package*)))
	      output)))))
