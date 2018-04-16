;;;; graph.garden-path.lisp

(in-package #:seed.generate)

(specify-media
 media-spec-graph-garden-path
 (graph-garden-path-content
  (follows reagent graph-id)
  `((let ((to-return nil))
      (loop for item in reagent while (not to-return)
	 do (if (string= (string-upcase ,graph-id)
			 (string-upcase (second item)))
		(setq to-return (cddr item))))
      to-return))
  ;; `((funcall (lambda (in)
  ;; 	       (labels ((process (i)
  ;; 			  (if i (let ((point (first i)))
  ;; 				  (if (string= "IN-TABLE" (string-upcase (first point)))
  ;; 				      (cddr point)
  ;; 				      (process (rest i)))))))
  ;; 		 (process in)))
  ;; 	     reagent))
  ))
