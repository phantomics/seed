;;;; graph.garden-path.lisp

(in-package #:seed.generate)

(specify-media
 media-spec-graph-garden-path
 (graph-garden-path-content
  (follows reagent graph-id)
  `((cond ((get-param :add-node)
	   (multiple-value-bind (output-data new-node-id)
	       (add-blank-node (branch-image branch)
			       (get-param :object-type)
			       (get-param :object-meta))
	     (set-branch-meta branch :change (list :node-added t :new-id (string-upcase new-node-id)))
	     (setf (branch-image branch) output-data)))
	  ((get-param :add-link)
	   (add-blank-link (branch-image branch)
			   (intern (get-param :node-id) "KEYWORD")
			   (get-param :object-meta))
	   (set-branch-meta branch :change (list :link-added t :node-id (get-param :node-id)))
	   (branch-image branch))
	  (t (set-branch-meta branch :change nil)
	     (branch-image branch))))
  `((let ((to-return nil))
      (loop for item in reagent while (not to-return)
	 do (if (string= (string-upcase ,graph-id)
			 (string-upcase (second item)))
		(setq to-return (cddr item))))
      to-return)))

 (graph-garden-path-display
  (follows reagent)
  `((preprocess-nodes ,(if reagent reagent `(branch-image branch))))))
