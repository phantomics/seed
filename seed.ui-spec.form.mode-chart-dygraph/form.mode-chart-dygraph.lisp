;;;; seed.ui-spec.form.mode-chart-dygraph.lisp

(in-package #:seed.ui-model.react)

(specify-components
 dygraph-chart-view-mode
 (dygraph-chart-view
  (:get-initial-state
   (lambda () 
     (cl :dd (@ this props))
     (create point 0
	     space (@ this props data data content)
	     data (@ this props data)))
   :chart nil
   :pane-element nil
   :container-element nil
   :demodulate-time
   (lambda (time mods)
     (loop for modix from (1- (@ mods length)) to 0
	do (let ((dividend (floor (/ (- time (getprop mods modix "offset"))
				     (- (getprop mods modix "period")
					(getprop mods modix "gap")))))
		 (remainder (mod (- time (getprop mods modix "offset"))
				 (- (getprop mods modix "period")
				    (getprop mods modix "gap")))))
	     (setq time (+ remainder (getprop mods modix "offset")
			   (* dividend (getprop mods modix "period"))
			   (* (if (/= 0 remainder) 1 0)
			      (getprop mods modix "gap"))))))
     time)
   :format-date-string
   (lambda (date-string)
     (let* ((self this)
	    (dval (parse-int (+ (chain self (demodulate-time date-string (@ self props data data mods)))
				"000")))
	    (d (new (-date dval))))
       (+ (chain d (get-month))
	  "/" (chain d (get-date))
	  "/" (chain d (get-full-year)))))
   :interact-mousedown
   (lambda (event g context)
     (cl :gg g)
     (let* ((self this))
       (cl :ev event)
       (if (@ self state)
	   (let ((new-data (j-query (extend t (@ self state data))))
		 (graph-pos (chain self chart (find-pos (@ g graph-div))))
		 (canvas-x (- (chain self chart (page-x event))
			      (@ graph-pos x)))
		 (canvas-y (- (chain self chart (page-y event))
			      (@ graph-pos y))))
	     (cl :canv canvas-x canvas-y)
	     (chain (@ new-data data entities (push (create type "line"
						      end ))))))
     ))
   :interact-mouseup
   (lambda (event g context))
   :interact-move
   (lambda (event g context)
     )
   :candle-plotter
   (lambda (e)
     (if (/= 0 (@ e series-index))
	 (let ((self this)
	       (set-count (@ e series-count)))
	   (if (/= 8 set-count)
	       (cl "Error: Exactly 4 prices each point must be provided for the candle chart.")
	       (let* ((prices #())
		      (sets (@ e all-series-points))
		      (area (@ e plot-area))
		      (ctx (@ e drawing-context))
		      (candle-max-spacing 3)
		      (bar-count (let ((range (chain e dygraph (x-axis-range)))
				       (counting false)
				       (length 0))
				   (loop for point in (@ sets 0)
				      do (if (and (not counting)
						  (> (@ point xval) (@ range 0)))
					     (setf counting true))
					(if (and counting (> (@ point xval) (floor (@ range 1))))
					    (setf counting false))
					(if counting (setq length (1+ length))))
				   length))
		      (view-width (@ (chain e dygraph (get-area)) w))
		      (bar-width (max 1 (* 0.7 (/ view-width bar-count)))))
		 (setf (@ ctx line-width) 0.6)
		 (loop for p from 0 to (1- (@ sets 0 length))
		    do (let* ((price (create open (getprop sets 0 p "yval")
					     close (getprop sets 1 p "yval")
					     high (getprop sets 2 p "yval")
					     low (getprop sets 3 p "yval")
					     open-y (getprop sets 0 p "y")
					     close-y (getprop sets 1 p "y")
					     high-y (getprop sets 2 p "y")
					     low-y (getprop sets 3 p "y")))
			      (top-y (+ (@ area y) (* (@ area h) (@ price high-y))))
			      (bottom-y (+ (@ area y) (* (@ area h) (@ price low-y))))
			      (center-x (+ (@ area x) (* (@ area w) (getprop sets 0 p "x"))))
			      (body-y nil)
			      (body-height nil))
			 (chain prices (push price))
			 (chain ctx (begin-path))
			 (chain ctx (move-to center-x top-y))
			 (chain ctx (line-to center-x bottom-y))
			 (chain ctx (close-path))
			 (if (> (@ price open) (@ price close))
			     (setf (@ ctx fill-style) "rgba(220,50,47,1.0)"
				   (@ ctx stroke-style) (if (< 2 bar-width)
							    "rgba(220,50,47,1.0)" "rgba(220,50,47,0.6)")
				   body-y (+ (@ area y) (* (@ area h) (@ price open-y))))
			     (setf (@ ctx fill-style) "rgba(38,139,210,1.0)"
				   (@ ctx stroke-style) (if (< 2 bar-width)
							    "rgba(38,139,210,1.0)" "rgba(38,139,210,0.6)")
				   body-y (+ (@ area y) (* (@ area h) (@ price close-y)))))
			 (chain ctx (stroke))
			 (setq body-height (* (@ area h) (abs (- (@ price open-y) (@ price close-y)))))
			 (chain ctx (fill-rect (- center-x (/ bar-width 2))
					       body-y bar-width body-height))))
		 (setf (@ ctx stroke-style) "black"
		       (@ ctx line-width) 1.5)
		 (loop for ent in (@ self state data data entities)
		    do (chain ctx (begin-path))
		      (let ((start (chain e dygraph (to-dom-coords (@ ent start 0) (@ ent start 1))))
			    (end (chain e dygraph (to-dom-coords (@ ent end 0) (@ ent end 1)))))
			;; (cl :start start end)
			(chain ctx (move-to (@ start 0) (@ start 1)))
			(chain ctx (line-to (@ end 0) (@ end 1))))
		      (chain ctx (close-path))
		      (chain ctx (stroke)))
		 )))))
   :graph nil
   :component-did-mount
   (lambda ()
     (let* ((self this))
       (setf (@ self pane-element)
	     (@ (j-query (+ "#branch-" (@ self props context index)
			    "-" (@ self props data id)))
		0)
	     (@ self chart)
       	     (new (chain window
			 (-dygraph (@ self container-element)
				   (@ self state space)
				   (create plotter (@ self candle-plotter)
					   sig-figs 6
					   axes (create x (create axis-label-formatter (@ self format-date-string))
							y (create axis-label-width 70))
					   height (- (@ self pane-element client-height) 20)
					   width (- (@ self pane-element client-width) 20)
					   interaction-model (create mousedown (@ self interact-mousedown)
								     mouseup (@ self interact-mouseup)
								     mousemove (@ self interact-mousemove)))))))
       (setf (@ window use-chart) (@ self chart))
       (cl :chart (@ self chart) (chain self chart (x-axis-range)))
       )))
  (let ((self this))
    (panic:jsl (:div :class-name "dygraph-chart-holder"
		     (:div :class-name "dygraph-chart"
		     	   :ref (lambda (ref) (if (not (@ self container-element))
		     				  (setf (@ self container-element)
		     					ref)))
		     	   :id (+ "dygraph-chart-" (@ this props data id))))))))

;; (setf (@ ctx stroke-style) "black"
;;       (@ ctx line-width) 3)
;; (loop for ent in (@ self props data data entities)
;;    do (chain ctx (begin-path))
;;    ;; (chain ctx (move-to (+ 50 (@ area x)) (- 100 (@ area y))))
;;    ;; (chain ctx (line-to (+ 3000 (@ area x)) 500))
;;      (let ((start (chain self chart (to-dom-coords (@ ent start 0)
;; 						   (@ ent start 1))))
;; 	   (end (chain self chart (to-dom-coords (@ ent end 0)
;; 						 (@ ent end 1)))))
;;        (cl :start start end)
;;        (chain ctx (move-to (@ start 0) (@ start 1)))
;;        (chain ctx (line-to (@ end 0) (@ end 1))))
;;      (chain ctx (close-path))
;;      (chain ctx (stroke)))

;; (defun demodulate-time (time &rest mods)
;;   (loop for mod in (reverse mods)
;;      do (multiple-value-bind (dividend remainder)
;; 	    (floor (- time (getf mod :offset))
;; 		   (- (getf mod :period)
;; 		      (getf mod :gap)))
;; 	  (setq time (+ remainder (getf mod :offset)
;; 			(* dividend (getf mod :period))
;; 			(* (signum remainder)
;; 			   (getf mod :gap))))))
;;   time)

;;   "Date,Open,Close,High,Low
;;   2011-12-06,392.54,390.95,394.63,389.38
;;   2011-12-07,389.93,389.09,390.94,386.76
;;   2011-12-08,391.45,390.66,395.50,390.23 
;;   2011-12-09,392.85,393.62,394.04,391.03
;;   2011-12-12,391.68,391.84,393.90,389.45
;;   2011-12-13,393.00,388.81,395.40,387.10 
;;   2011-12-14,386.70,380.19,387.38,377.68
;;   2011-12-15,383.33,378.94,383.74,378.31
;;   2011-12-16,380.36,381.02,384.15,379.57
;;   2011-12-19,382.47,382.21,384.85,380.48
;;   2011-12-20,387.76,395.95,396.10,387.26
;;   2011-12-21,396.69,396.45,397.30,392.01
;;   2011-12-22,397.00,398.55,399.13,396.10
;;   2011-12-23,399.69,403.33,403.59,399.49
;;   2011-12-27,403.10,406.53,409.09,403.02
;;   2011-12-28,406.89,402.64,408.25,401.34
;;   2011-12-29,403.40,405.12,405.65,400.51
;;   2011-12-30,403.51,405.00,406.28,403.49
;;   2012-01-03,409.50,411.23,412.50,409.00
;;   2012-01-04,410.21,413.44,414.68,409.28
;;   2012-01-05,414.95,418.03,418.55,412.67
;;   2012-01-06,419.77,422.40,422.75,419.22
;;   2012-01-09,425.52,421.73,427.75,421.35
;;   2012-01-10,425.91,423.24,426.00,421.50
;;   2012-01-11,422.59,422.55,422.85,419.31
;;   2012-01-12,422.41,421.39,422.90,418.75
;;   2012-01-13,419.53,419.81,420.45,418.66
;;   2012-01-17,424.20,424.70,425.99,422.96
;; "
