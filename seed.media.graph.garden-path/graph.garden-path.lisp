;;;; graph.garden-path.lisp

(in-package #:seed.generate)

(specify-media
 media-spec-graph-garden-path
 (graph-garden-path-content
  (follows reagent graph-id)
  `((if (get-param :add-node)
	(setf (branch-image branch) (add-blank-node (branch-image branch)
						    (get-param :object-type)
						    (get-param :object-meta)))))
  `((let ((to-return nil))
      (loop for item in reagent while (not to-return)
	 do (if (string= (string-upcase ,graph-id)
			 (string-upcase (second item)))
		(setq to-return (cddr item))))
      to-return))))
