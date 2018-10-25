;;;; chart.base.lisp

(in-package #:seed.generate)

(specify-media
 media-spec-chart-base
 (chart-entity
  (follows reagent symbol-name)
  `(;; (set-branch-meta branch :change nil)
    (let* ((other-branch (find-branch-by-name reagent sprout))
	   (other-branch-image (branch-image other-branch))
	   (generated-data (loop for item in data collect
				`(:value
				  (meta
				   ((meta ,(write-to-string (first (getf item :start)))
					  :mode (:value ,(write-to-string (first (getf item :start)))
							:view :textfield :title "Start Time"))
				    (meta ,(write-to-string (second (getf item :start)))
					  :mode (:value ,(write-to-string (second (getf item :start)))
							:view :textfield :title "Start Price"))
				    (meta ,(write-to-string (first (getf item :end)))
					  :mode (:value ,(write-to-string (first (getf item :end)))
							:view :textfield :title "End Time"))
				    (meta ,(write-to-string (second (getf item :end)))
					  :mode (:value ,(write-to-string (second (getf item :end)))
							:view :textfield :title "End Price")))
				   :mode
				   (:view :item :title "line" :removable t :open t :format-properties
					  (:type :load)))
				  :title "line"))))
      (print (list :gg generated-data))
      (setf other-branch-image
	    (loop for form in other-branch-image collect
		 (if (and (string= "META" (string-upcase (first form)))
			  (cadadr form)
			  (string= (string-upcase (cadadr form))
				   (string-upcase ,symbol-name)))
		     ;;`(aaaa ,form)
		     (let ((new-meta (cddr form)))
		       (setf (getf new-meta :model)
			     generated-data)
		       (print (list :new-meta new-meta))
		       (print (list :gend generated-data))
		       (append (list (first form)
				     (second form))
			       new-meta))
		     form)))
      (print (list :obo other-branch-image))
      data
    ))
  ;; `((let ((to-return nil))
  ;;     (loop for item in ,reagent while (not to-return)
  ;; 	 do (if (string= (string-upcase ,graph-id)
  ;; 			 (string-upcase (second item)))
  ;; 		(setq to-return (cddr item))))
  ;;     to-return))
  )
 )
