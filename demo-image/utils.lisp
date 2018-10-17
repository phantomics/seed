;;;; utils.lisp

(in-package #:demo-image)

(defun raster-process-layers-expand (items)
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
	  output)))
