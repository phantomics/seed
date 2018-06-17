;;;;raster-layers.base.lisp

(in-package #:seed.app-model.raster-layers.base)

(defun do-test ()
  (let* ((img-src-path (namestring (asdf:system-relative-pathname (intern (package-name *package*)
									  "KEYWORD")
								  "sample.jpg")))
	 (img-out-path (namestring (asdf:system-relative-pathname (intern (package-name *package*)
									  "KEYWORD")
								  "sample-out.jpg")))
	 (img (read-jpeg-file img-src-path)))
    (print (list :ii img-src-path img-out-path))
    (typecase img
      (8-bit-rgb-image
       (locally (declare (type 8-bit-rgb-image img))
	 (with-image-bounds (height width)
	     img
	   (time (loop for i below height
		    do (loop for j below width 
			  do (multiple-value-bind (r g b)
				 (pixel img i j)
			       (declare (type (unsigned-byte 8) r g b))
			       (setf (pixel img i j)
				     (values (- 255 r) g b))))))))))
    (write-jpeg-file img-out-path img)))

(defun type-array (img)
  (with-image-bounds (height width)
      img
    (let ((new-img (make-8-bit-rgb-image height width)))
      (loop for i below height
	 do (loop for j below width 
	       do (multiple-value-bind (r g b)
		      (pixel img i j)
		    (declare (type (unsigned-byte 8) r g b))
		    (setf (pixel new-img i j)
			  (values r g b)))))
      new-img)))

(defmacro raster-process-layers (&rest layers)
  (labels ((process (layers &optional output)
	     (if layers
		 (let* ((layer (first layers))
			(layer-type (intern (string-upcase (first layer))
					    "KEYWORD"))
			(layer-data (rest layer))
			(path-string (namestring (asdf:system-relative-pathname
						  (intern (package-name *package*)
							  "KEYWORD")
						  "")))
			(input (gensym)))
		   (process (rest layers)
			    (cond ((eq layer-type :load)
				   `(read-jpeg-file ,(concatenate 'string path-string
								  (getf layer-data :path))))
				  ((eq layer-type :apl)
				   `(funcall (lambda (,input)
					       (type-array
						,(eval (macroexpand `(april (set (:compile-only)
										 (:state :in ((input ,input))))
									    ,(getf layer-data :exp))))))
					     ,output))
				  ((eq layer-type :output)
				   `(funcall (lambda (,input)
					       (print (type-of ,input))
					       (write-jpeg-file ,(concatenate 'string path-string
									      (getf layer-data :path))
								,input))
				     ,output)))))
		 output)))
    (process layers)))

#|
(raster-process-layers
 (load :path "sample.jpg")
 (apl :exp "255⌊⌈1.3×input")
 (output :path "sample2.jpg"))
|#
