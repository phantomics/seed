;;;; stage-menu.base.lisp

(in-package #:seed.ui-spec.stage-menu.base)

(defmacro stage-extension-menu-base (meta-symbol)
  "A set of menu items for use with Seed interfaces."
  `(lambda (menu-params)
     (list (mapcar (lambda (item)
		     (cond ((eq :insert-fibo-points item)
			    ;; `(,',meta-symbol :insert-fibo-points
			    ;; 		   :mode (:interaction :insert)
			    ;; 		   :format (,',meta-symbol
			    ;; 			    (spiral-points 100 100
			    ;; 					   (,',meta-symbol
			    ;; 					    ((,',meta-symbol
			    ;; 					      ((:circle :stroke-width 2 :r 3
			    ;; 							:fill "#88aa00" :stroke "#e3dbdb"))
			    ;; 					      :mode (:view :item :removable t
			    ;; 							 :title "Small Green Circle")))
			    ;; 					    :mode (:options
			    ;; 						 ((:value
			    ;; 						   (,',meta-symbol
			    ;; 						    ((:circle :stroke-width 2 :r 3
			    ;; 							      :fill "#88aa00"
			    ;; 							      :stroke "#e3dbdb"))
			    ;; 						    :mode (:view :item :removable t
			    ;; 							       :title "Small Green Circle"))
			    ;; 						   :title "Small Green Circle")
			    ;; 						  (:value
			    ;; 						   (,',meta-symbol
			    ;; 						    ((:circle :stroke-width 2 :r 5
			    ;; 							      :fill "#87aade"
			    ;; 							      :stroke "#e3dbdb"))
			    ;; 						    :mode (:view :item :removable t
			    ;; 							       :title "Big Blue Circle"))
			    ;; 						   :title "Big Blue Circle"))
			    ;; 						 :removable nil :fill-by :select
			    ;; 						 :view :list)))
			    ;; 			    :format spiral-points-expand))
			    nil)
			   ((eq :insert-circle item)
			    `(,',meta-symbol :insert-circle
					   :mode (:interaction :insert)
					   :format (:circle :cx 100
							    :cy 100
							    :r 25)))
			   ((eq :insert-rect item)
			    `(,',meta-symbol :insert-rectangle
					   :mode (:interaction :insert)
					   :format (:rect :x 100
							  :y 100
							  :height 35
							  :width 35)))
			   ((eq :insert-add-op item)
			    `(,',meta-symbol :insert-add-op
					   :mode (:interaction :insert)
					   :format (+ 1 2)))
			   ((eq :insert-mult-op item)
			    `(,',meta-symbol :insert-mult-op
					   :mode (:interaction :insert)
					   :format (* 3 4)))))
		   menu-params))))

(defmacro stage-controls-marginal-base (meta-symbol spec-symbol params-symbol output-symbol)
  (declare (ignorable spec-symbol))
  `(((eq :save (first ,params-symbol))
     (cons `(,',meta-symbol :save :mode (:interaction :commit))
	   ,output-symbol))
    ((eq :revert (first ,params-symbol))
     (cons `(,',meta-symbol :revert :mode (:interaction :revert))
	   ,output-symbol))))

(defmacro stage-controls-base-contextual (meta-symbol spec-symbol params-symbol output-symbol)
  (declare (ignorable params-symbol))
  `((let ((param-checks (mapcar #'second (find-form-in-spec 'is-param ,spec-symbol))))
      (append (if (find :save param-checks)
		  (list `(,',meta-symbol :save :mode (:interaction :commit))))
	      (if (find :revert param-checks)
		  (list `(,',meta-symbol :revert :mode (:interaction :revert)))
		  ,output-symbol)))))

;; (defmacro stage-controls-marginal-base (meta-symbol)
;;   `(labels ((process-params (params &optional output)
;; 	      (if (not params)
;; 		  output (process-params (rest params)
;; 					 (cond ((eq :save (first params))
;; 						(cons `(,',meta-symbol :save :mode (:interaction :commit))
;; 						      output))
;; 					       ((eq :revert (first params))
;; 						(cons `(,',meta-symbol :revert :mode (:interaction :revert))
;; 						      output))
;; 					       (t output))))))
;;      #'process-params))
