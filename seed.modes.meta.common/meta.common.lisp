;;;; meta.common.lisp

(in-package #:seed.modulate)

(specify-meta-modes
 modes-meta-common
 (:spiral-points-expand
  (lambda (items)
    (flet ((fibo-plotter (x y scale iterations)
             (flet ((e-process (value) (exp (* value 0.30635))))
               (loop :for index :from 0 :to (1- iterations)
                  :collect (list (+ x (* (e-process index)
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
                              `((:load :path ,(second (caadr item)))))
                             ((eq :apl type)
                              `((:apl :exp ,(second (caadr item)))))
                             ((eq :output type)
                              `((:output :path ,(second (caadr item))))))))))
      (cons (intern "RASTER-PROCESS-LAYERS" (package-name *package*))
            output))))
 (:chart-entities-expand
  (lambda (items)
    (let ((output (loop :for item :in items :append
                     (let* ((type (getf (getf (getf (cddr item) :mode) :format-properties) :type))
			    (members (second item))
			    (start-time (nth 0 members))
			    (start-price (nth 1 members))
			    (end-time (nth 2 members))
			    (end-price (nth 3 members)))
                       (cond ((eq :off (getf (getf (cddr item) :mode) :toggle))
                              nil)
                             ((eq :line type)
			      members
                              `((list :type "line"
		       		      :points (list (list ,(parse-number (second start-time))
							  ,(parse-number (second start-price)))
						    (list ,(parse-number (second end-time))
							  ,(parse-number (second end-price))))))))
		       ))))
      `(setq ,(intern "CHART-ENTITIES" (package-name *package*))
	     (list ,@output)))))
 (:html-form-components-expand
  (lambda (items)
    (let ((output (loop :for item :in items :append
                     (let ((type (getf (getf (getf (cddr item) :mode) :format-properties) :type)))
                       (cond ((eq :section-title type)
                              `((:h2 ,(second (caadr item)))))
                             ((eq :form-field type)
                              `((:div (:label ,(second (caadr item))) (:br)
                                      (:input)))))))))
      (append (list (intern "GENERATE-HTML-FORM" (package-name *package*))
                    (intern "FORM-OUTPUT" (package-name *package*)))
              output)))))
