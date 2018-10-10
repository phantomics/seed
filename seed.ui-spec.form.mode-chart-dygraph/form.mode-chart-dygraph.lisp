;;;; seed.ui-spec.form.mode-chart-dygraph.lisp

(in-package #:seed.ui-model.react)

(specify-components
 dygraph-chart-view-mode
 (dygraph-chart-view
  (:get-initial-state
   (lambda ()
     (chain j-query (extend (create point 0
				    space (@ this props data data content)
				    data (@ this props data))
			    (chain this (initialize (@ this props))))))
   :initialize
   (lambda (props)
     (let* ((self this)
	    (state (funcall inherit self props
			    (lambda (d) (@ props data))
			    (lambda (pd) (@ pd data data content)))))
       (if (@ self props context set-interaction)
	   (progn (chain self props context
			 (set-interaction "chartSelect"
					  (lambda () (setf (@ self ephemera interaction) "select"))))
		  (chain self props context
			 (set-interaction "chartDrawLine"
					  (lambda () (setf (@ self ephemera interaction) "draw"
							   (@ self ephemera draw-entity) "line"))))
		  (chain self props context
			 (set-interaction "chartRetraceX"
					  (lambda () (setf (@ self ephemera interaction) "draw"
							   (@ self ephemera draw-entity) "retraceX"))))
		  (chain self props context
			 (set-interaction "chartRetraceY"
					  (lambda () (setf (@ self ephemera interaction) "draw"
							   (@ self ephemera draw-entity) "retraceY"))))
		  (chain self props context
			 (set-interaction "chartZoomRealSize"
					  (lambda () (chain self chart (reset-zoom)))))))
       state))
   :chart nil
   :pane-element nil
   :container-element nil
   :ephemera (create interaction "select"
		     draw-entity "line"
		     moving-from nil
		     mousedown false
		     active-entity nil
		     entities-in-flux (list))
   :entity-methods
   (let ((draw-line (lambda (ctx ent chart)
		      (chain ctx (begin-path))
		      (let ((start (if (or (not (@ ent layer-start))
					   (= "undefined" (typeof (@ ent layer-start))))
				       (chain chart (to-dom-coords (@ ent start 0) (@ ent start 1)))
				       (@ ent layer-start)))
			    (end (if (or (not (@ ent layer-end))
					 (= "undefined" (typeof (@ ent layer-end))))
				     (chain chart (to-dom-coords (@ ent end 0) (@ ent end 1)))
				     (@ ent layer-end))))
			(chain ctx (move-to (@ start 0) (@ start 1)))
			(chain ctx (line-to (@ end 0) (@ end 1))))
		      (chain ctx (close-path))
		      (chain ctx (stroke))))
	 (intersect-line (lambda (ent point callback)
			   (let ((line-start (chain self chart (to-dom-coords (@ ent start 0)
									      (@ ent start 1))))
				 (line-end (chain self chart (to-dom-coords (@ ent end 0)
									    (@ ent end 1)))))
			     (if (not (or (and (> (@ point 0) (@ line-start 0))
					       (> (@ point 0) (@ line-end 0)))
					  (and (< (@ point 0) (@ line-start 0))
					       (< (@ point 0) (@ line-end 0)))
					  (and (> (@ point 1) (@ line-start 1))
					       (> (@ point 1) (@ line-end 1)))
					  (and (< (@ point 1) (@ line-start 1))
					       (< (@ point 1) (@ line-end 1)))))
				 (let* ((ratio (/ (- (@ line-start 1) (@ line-end 1))
						  (- (@ line-end 0) (@ line-start 0))))
					(x-pos (- (@ point 0) (@ line-start 0)))
					(cross-y (abs (- (* x-pos ratio) (@ line-start 1)))))
				   (cl :cross (@ point 1) cross-y ratio
				       line-start line-end (abs (- cross-y (@ point 1))))
				   (if (> 8 (abs (- cross-y (@ point 1))))
				       (funcall callback ent)
				       ;;(cl "Hit!")
				       )))))))
     (create line (create draw draw-line
			  intersect intersect-line)
	     retrace-x (create draw (lambda (ctx ent chart)
				      (funcall draw-line ctx ent chart)
				      (setf (@ ctx stroke-style) "blue"
					    (@ ctx line-width) 1)
				      (let ((x-origin (chain self chart (to-dom-x-coord (if (< (@ ent start 0)
											       (@ ent end 0))
											    (@ ent start 0)
											    (@ ent end 0)))))
					    (x-interval (- (chain self chart (to-dom-x-coord (@ ent start 0)))
							   (chain self chart (to-dom-x-coord (@ ent end 0))))))
					(loop for ratio in (list 0 0.382 0.618 1)
					   do (let ((x-level (if (< (@ ent start 0) (@ ent end 0))
								 (- x-origin (* ratio x-interval))
								 (+ x-origin (* ratio x-interval)))))
						(chain ctx (begin-path))
						(chain ctx (move-to x-level 0))
						(chain ctx (line-to x-level (@ ctx canvas height)))
						(chain ctx (close-path))
						(chain ctx (stroke)))))
				      (setf (@ ctx stroke-style) "black"
					    (@ ctx line-width) 1.5))
			       intersect intersect-line)
	     retrace-y (create draw (lambda (ctx ent chart)
				      (funcall draw-line ctx ent chart)
				      (setf (@ ctx stroke-style) "red"
					    (@ ctx line-width) 1)
				      (let ((x-origin (chain self chart (to-dom-x-coord (if (< (@ ent start 0)
											      (@ ent end 0))
											   (@ ent start 0)
											   (@ ent end 0)))))
					    (y-origin (chain self chart (to-dom-y-coord (if (< (@ ent start 1)
											       (@ ent end 1))
											    (@ ent start 1)
											    (@ ent end 1)))))
					    (y-interval (- (chain self chart (to-dom-y-coord (@ ent start 1)))
							   (chain self chart (to-dom-y-coord (@ ent end 1))))))
					(loop for ratio in (list 0 0.236 0.382 0.500 0.618 0.764 1.0)
					   do (let ((y-level (if (< (@ ent start 1) (@ ent end 1))
								 (- y-origin (* ratio y-interval))
								 (+ y-origin (* ratio y-interval)))))
						(chain ctx (begin-path))
						(chain ctx (move-to x-origin y-level))
						(chain ctx (line-to (@ ctx canvas width) y-level))
						(chain ctx (close-path))
						(chain ctx (stroke)))))
				      (setf (@ ctx stroke-style) "black"
					    (@ ctx line-width) 1.5))
			       intersect intersect-line)))
   :demodulate-time
   (lambda (time mods)
     (loop for modix from (1- (@ mods length)) to 0
	do (let ((dividend (floor (/ (- time (getprop mods modix "offset"))
				     (- (getprop mods modix "period") (getprop mods modix "gap")))))
		 (remainder (mod (- time (getprop mods modix "offset"))
				 (- (getprop mods modix "period") (getprop mods modix "gap")))))
	     (setq time (+ remainder (getprop mods modix "offset")
			   (* dividend (getprop mods modix "period"))
			   (* (getprop mods modix "gap") (if (/= 0 remainder) 1 0))))))
     time)
   :format-date-string
   (lambda (date-string)
     (let* ((self this)
	    (dval (parse-int (+ (chain self (demodulate-time date-string (@ self props data data mods)))
				"000")))
	    (d (new (-date dval))))
       (+ (1+ (chain d (get-month)))
	  "/" (1+ (chain d (get-date)))
	  "/" (chain d (get-full-year)))))
   :render-entity
   (lambda (context entity))
   :interact-mousedown
   (lambda (event g context)
     (let* ((self this))
       (setf (@ self ephemera mousedown) t)
       (let ((canvas-coords (list (@ event layer-x) (@ event layer-y)))
	     (dom-coords (chain g (event-to-dom-coords event)))
	     (entities-count (@ self state data data entities length)))
	 (if (= "select" (@ self ephemera interaction))
	     (progn (loop for entix from 0 to (1- entities-count)
		       do (chain self entity-methods line
				 (intersect
				  (getprop (@ self state data data entities) entix)
				  dom-coords (lambda (ent)
					       (if (and ;; (= entix (1- entities-count))
						    (not (@ ent in-flux)))
						   (let ((extend-from (create layer-start
									      (chain g (to-dom-coords
											(@ ent start 0)
											(@ ent start 1)))
									      layer-end
									      (chain g (to-dom-coords
											(@ ent end 0)
											(@ ent end 1))))))
						     (chain self ephemera entities-in-flux
							    (push (chain j-query (extend extend-from ent))))
						     (setf (@ ent in-flux) true)))))))
		    (cl :flux (@ self ephemera entities-in-flux))
		    (setf (@ self ephemera moving-from) canvas-coords)
		    (cl :mm (@ self ephemera moving-from))
		    (if (= 0 (@ self ephemera entities-in-flux length))
			(progn (chain context (initialize-mouse-down event g context))
			       ;;(chain window -dygraph (start-pan event g context))
			       )
			(chain g (set-annotations (list)))))
	     (if (= "draw" (@ self ephemera interaction))
		 (let* ((time-interval (- (@ g raw-data_ 1 0) (@ g raw-data_ 0 0)))
			(data-pos (chain g (to-data-coords (@ dom-coords 0) (@ dom-coords 1))))
			(remainder (mod (@ data-pos 0) time-interval)))
		   (if (/= 0 remainder)
		       (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
		   (setf (@ self ephemera active-entity)
			 (create type (@ self ephemera draw-entity)
				 in-flux false
				 start (list (@ data-pos 0) (@ data-pos 1))
				 end (list (@ data-pos 0) (@ data-pos 1))))))))))
   :interact-mouseup
   (lambda (event g context)
     (let ((self this))
       (setf (@ self ephemera mousedown) false)
       ;; (cl :eee (@ self ephemera))
       (if (= "select" (@ self ephemera interaction))
	   (if (@ context is-panning)
	       ;;(chain window -dygraph (end-pan event g context))
	       (cl :pan)
	       (let* ((updated-entity (@ self ephemera entities-in-flux 0))
		      (new-coords (create start (chain g (to-data-coords (@ updated-entity layer-start 0)
									 (@ updated-entity layer-start 1)))
					  end (chain g (to-data-coords (@ updated-entity layer-end 0)
								       (@ updated-entity layer-end 1))))))
		 (cl :change (@ self state data data entities) new-coords)
		 (setf (@ self ephemera entities-in-flux) (list))
		 (loop for ent in (@ self state data data entities)
		    do (if (@ ent in-flux)
			   (setf (@ ent in-flux) false
				 (@ ent start) (@ new-coords start)
				 (@ ent end) (@ new-coords end))))
		 (chain g (set-annotations (list)))))
	   (if (= "draw" (@ self ephemera interaction))
	       (let* ((new-data (chain j-query (extend t (@ self state data)))))
		 (chain (@ new-data data entities) (push (@ self ephemera active-entity)))
		 (setf (@ self ephemera active-entity) nil
		       (@ self ephemera interaction) "select")
		 (chain self (set-state (create data new-data)))
		 (chain g (set-annotations (list))))))))
   :interact-mousemove
   (lambda (event g context)
     (setq self this
	   temp-canvas (@ g canvas_ctx_))
     (if (@ self ephemera mousedown)
	 (if (= "select" (@ self ephemera interaction))
	     (if (= 0 (@ self ephemera entities-in-flux length))
		 (if (@ context is-panning)
		     (chain window -dygraph (move-pan event g context)))
		 (let ((moving-from (@ self ephemera moving-from)))
		   (chain temp-canvas (clear-rect 0 0 (@ g canvas_ width) (@ g canvas_ height)))
		   (loop for ent in (@ self ephemera entities-in-flux)
		      do (setf (@ ent layer-start) (list (- (@ ent layer-start 0)
							    (- (@ moving-from 0) (@ event layer-x)))
							 (- (@ ent layer-start 1)
							    (- (@ moving-from 1) (@ event layer-y))))
			       (@ ent layer-end) (list (- (@ ent layer-end 0)
							  (- (@ moving-from 0) (@ event layer-x)))
						       (- (@ ent layer-end 1)
							  (- (@ moving-from 1) (@ event layer-y))))
			       (@ self ephemera moving-from) (list (@ event layer-x) (@ event layer-y)))
			;; (cl :mv (@ ent layer-start) (@ ent layer-end))
			;; (cl :mm2 (@ self ephemera moving-from))
			(funcall (getprop self "entityMethods" (@ ent type) "draw")
				 temp-canvas ent g))))
	     ;; TODO: add move-ephemera logic
	     (if (= "draw" (@ self ephemera interaction))
		 (let* ((time-interval (- (@ g raw-data_ 1 0) (@ g raw-data_ 0 0)))
			(dom-coords (chain g (event-to-dom-coords event)))
			(data-pos (chain g (to-data-coords (@ dom-coords 0) (@ dom-coords 1))))
			(remainder (mod (@ data-pos 0) time-interval)))
		   ;; snap to nearest rounded-down time interval
		   (if (/= 0 remainder)
		       (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
		   ;; (cl :ss remainder (@ data-pos 0))
		   (setf (@ self ephemera active-entity end) (list (@ data-pos 0) (@ data-pos 1)))
		   (let ((ent (@ self ephemera active-entity)))
		     (chain temp-canvas (clear-rect 0 0 (@ g canvas_ width) (@ g canvas_ height)))
		     (funcall (getprop self "entityMethods" (@ ent type) "draw")
			      temp-canvas ent g))
		   ;;(chain g (set-annotations (list)))
		   )))))
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
		      (bar-width (max 1 (* 0.7 (/ view-width bar-count))))
		      (up-fill-style "rgba(38,139,210,1.0)")
		      (up-stroke-style (if (< 2 bar-width) "rgba(38,139,210,1.0)" "rgba(38,139,210,0.6)"))
		      (down-fill-style "rgba(220,50,47,1.0)")
		      (down-stroke-style (if (< 2 bar-width) "rgba(220,50,47,1.0)" "rgba(220,50,47,0.6)")))
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
			     (setf (@ ctx fill-style) down-fill-style
				   (@ ctx stroke-style) down-stroke-style
				   body-y (+ (@ area y) (* (@ area h) (@ price open-y))))
			     (setf (@ ctx fill-style) up-fill-style
				   (@ ctx stroke-style) up-stroke-style
				   body-y (+ (@ area y) (* (@ area h) (@ price close-y)))))
			 (chain ctx (stroke))
			 (setq body-height (* (@ area h) (abs (- (@ price open-y) (@ price close-y)))))
			 (chain ctx (fill-rect (- center-x (/ bar-width 2))
					       body-y bar-width body-height))))
		 (setf (@ ctx stroke-style) "black"
		       (@ ctx line-width) 1.5)
		 ;; (cl :ents (@ self state data data entities))
		 (loop for ent in (@ self state data data entities)
		    do (if (not (@ ent in-flux))
			   (funcall (getprop self "entityMethods" (@ ent type) "draw")
				    ctx ent (@ e dygraph)))))))))
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
					   labels (@ self state data data labels)
					   sig-figs 6
					   series (create "EUR/CAD(Open, Ask)" (create axis "y2")
							  "EUR/CAD(High, Ask)" (create axis "y2")
							  "EUR/CAD(Low, Ask)" (create axis "y2")
							  "EUR/CAD(Close, Ask)" (create axis "y2")
							  "EUR/CAD(Open, Bid)*" (create axis "y2")
							  "EUR/CAD(High, Bid)*" (create axis "y2")
							  "EUR/CAD(Low, Bid)*" (create axis "y2")
							  "EUR/CAD(Close, Bid)*" (create axis "y2"))
					   axes (create x (create axis-label-formatter (@ self format-date-string))
							y (create draw-grid true
								  independent-ticks false
								  axis-label-width 0)
							y2 (create draw-grid true
								   axis-label-width 50
								   labels-k-m-b true
								   independent-ticks true))
					   height (- (@ self pane-element client-height) 20)
					   width (- (@ self pane-element client-width) 20)
					   pan-edge-fraction 0.8
					   value-range (list 1.475 1.54)
					   ;; color-value 0.9
					   ;; hide-overlay-on-mouse-out false
					   interaction-model (create mousedown (@ self interact-mousedown)
					   			     mouseup (@ self interact-mouseup)
					   			     mousemove (@ self interact-mousemove))
					   )))))
       (setf (@ window use-chart) (@ self chart))
       (cl :chart (@ self chart) (chain self chart (x-axis-range)))
       ;; (cl :dem (chain self (demodulate-time 1089835200000 (@ self props data data mods))))
       )))
  (let ((self this))
    (panic:jsl (:div :class-name "dygraph-chart-holder"
		     (:div :class-name "dygraph-chart"
		     	   :ref (lambda (ref) (if (not (@ self container-element))
		     				  (setf (@ self container-element)
		     					ref)))
		     	   :id (+ "dygraph-chart-" (@ this props data id))))))))
