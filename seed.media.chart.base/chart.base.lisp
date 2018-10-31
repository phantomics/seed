;;;; chart.base.lisp

(in-package #:seed.generate)

(specify-media
 media-spec-chart-base
 (chart-entity
  (follows reagent symbol-name)
  `((let* ((other-branch (find-branch-by-name reagent sprout))
	   (other-branch-image (branch-image other-branch))
	   (generated-data (loop for item in data collect
				(cond ((string= "line" (getf item :type))
				       `(meta
					 ((meta ,(write-to-string (first (getf item :start)))
						:mode (:value ,(write-to-string (first (getf item :start)))
							      :view :textfield :title "Start Time"))
					  (meta ,(write-to-string (coerce (second (getf item :start))
									  'short-float))
						:mode (:value ,(write-to-string (coerce (second (getf item :start))
											'short-float))
							      :view :textfield :title "Start Price"))
					  (meta ,(write-to-string (first (getf item :end)))
						:mode (:value ,(write-to-string (first (getf item :end)))
							      :view :textfield :title "End Time"))
					  (meta ,(write-to-string (coerce (second (getf item :end))
									  'short-float))
						:mode (:value ,(write-to-string (coerce (second (getf item :end))
											'short-float))
							      :view :textfield :title "End Price")))
					 :mode
					 (:view :item :title "Line" :removable t :open t :toggle :on
						:format-properties (:type :load))))
				      ((string= "retraceX" (getf item :type))
				       `(meta
					 ((meta ,(write-to-string (first (getf item :start)))
						:mode (:value ,(write-to-string (first (getf item :start)))
							      :view :textfield :title "Start Time"))
					  (meta ,(write-to-string (coerce (second (getf item :start))
									  'short-float))
						:mode (:value ,(write-to-string (coerce (second (getf item :start))
											'short-float))
							      :view :textfield :title "Start Price"))
					  (meta ,(write-to-string (first (getf item :end)))
						:mode (:value ,(write-to-string (first (getf item :end)))
							      :view :textfield :title "End Time"))
					  (meta ,(write-to-string (coerce (second (getf item :end))
									  'short-float))
						:mode (:value ,(write-to-string (coerce (second (getf item :end))
											'short-float))
							      :view :textfield :title "End Price")))
					 :mode
					 (:view :item :title "Time Retracement" :removable t :open t :toggle :on
						:format-properties (:type :load))))
				      ((string= "retraceY" (getf item :type))
				       `(meta
					 ((meta ,(write-to-string (first (getf item :start)))
						:mode (:value ,(write-to-string (first (getf item :start)))
							      :view :textfield :title "Start Time"))
					  (meta ,(write-to-string (coerce (second (getf item :start))
									  'short-float))
						:mode (:value ,(write-to-string (coerce (second (getf item :start))
											'short-float))
							      :view :textfield :title "Start Price"))
					  (meta ,(write-to-string (first (getf item :end)))
						:mode (:value ,(write-to-string (first (getf item :end)))
							      :view :textfield :title "End Time"))
					  (meta ,(write-to-string (coerce (second (getf item :end))
									  'short-float))
						:mode (:value ,(write-to-string (coerce (second (getf item :end))
											'short-float))
							      :view :textfield :title "End Price")))
					 :mode
					 (:view :item :title "Price Retracement" :removable t :open t :toggle :on
						:format-properties (:type :load))))))))
      ;; (print (list :gg data generated-data))
      (setf (branch-image other-branch) ;; other-branch-image
	    (loop for form in other-branch-image collect
		 (if (and (string= "META" (string-upcase (first form)))
			  (cadadr form)
			  (string= (string-upcase (cadadr form))
				   (string-upcase ,symbol-name)))
		     (let ((new-meta (cddr form)))
		       (setf (getf (getf new-meta :mode) :model)
			     generated-data)
		       (append (list (first form)
				     (second form))
			       new-meta))
		     form)))
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
