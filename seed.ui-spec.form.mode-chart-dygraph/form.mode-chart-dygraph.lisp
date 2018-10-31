;;;; seed.ui-spec.form.mode-chart-dygraph.lisp

(in-package #:seed.ui-model.react)

(specify-components
 dygraph-chart-view-mode
 (dygraph-chart-view
  (:get-initial-state
   (lambda ()
     (chain j-query (extend (create point 0
				    data (@ this props data)
				    entities (@ this props data data entities)
				    content-index (create))
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
       (setf (@ state content-index) (create))
       (loop for item in (@ props data data content)
	  do (setf (getprop state "contentIndex" (@ item 0)) (chain item (slice 1))))
       state))
   :chart nil
   :pane-element nil
   :container-element nil
   :ephemera (create interaction "select"
		     draw-entity "line"
		     moving-from nil
		     mousedown false
		     active-entity nil
		     entities-in-flux (list)
		     entities (list))
#|
   Entities list exists in ephemera. When a save event happens, the static list is overwritten with it.
|#
   :modulate-methods
   (lambda (methods)
     (let* ((self this)
	    (to-grow (if (@ self props context parent-system)
	   		 (chain methods (in-context-grow (@ self props context parent-system)))
	   		 (@ methods grow))))
       (chain j-query
   	      (extend methods
   		      (create grow-adding-entity
			      (lambda (entity meta callback)
				(to-grow (@ self state data id)
					 entity meta)))))))
   :commit-entities
   (lambda ()
     (chain self state context methods (grow-adding-entity (@ self ephemera entities) (create save true)))
     (chain self (set-state (create entities (@ self ephemera entities)))))
   :entity-methods
   (let ((draw-line (lambda (ctx ent chart)
		      (if (@ ent in-flux)
			  (setf (@ ctx line-width) 2))
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
			(chain ctx (line-to (@ end 0) (@ end 1)))
			(chain ctx (close-path))
			(chain ctx (stroke))
			(if (@ ent in-flux)
			    (let* ((ratio (- (/ (- (@ start 1) (@ end 1))
						(- (@ end 0) (@ start 0)))))
				   (x-len (- (@ end 0) (@ start 0)))
				   (y-len (- (@ end 1) (@ start 1)))
				   (r2 (acos (/ x-len (sqrt (+ (expt x-len 2)
							       (expt y-len 2)))))))
			      ;; (cl :rr ratio sector
			      ;; 	  (* 0.5 (1- sector))
			      ;; 	  (- (@ end 0) (@ start 0))
			      ;; 	  (- (@ start 1) (@ end 1))
			      ;; 	  (/ (tan ratio) pi))
			      (setf (@ ctx stroke-style) "black"
				    (@ ctx fill-style) "black"
				    (@ ctx line-width) 0.5)
			      (chain ctx (begin-path))
			      (chain ctx (arc (@ start 0) (@ start 1) 1 0 (* pi 2) true))
			      (chain ctx (fill))
			      (chain ctx (begin-path))
			      (chain ctx (arc (@ end 0) (@ end 1) 1 0 (* pi 2) true))
			      (chain ctx (fill))
			      (chain ctx (begin-path))

			      (chain ctx (arc (@ start 0) (@ start 1) 5 0 (* pi 2) true))
			      (chain ctx (stroke))
			      (chain ctx (begin-path))
			      (chain ctx (arc (@ end 0) (@ end 1) 5 0 (* pi 2) true))

			      ;; cos theta = x/sqrt(x2+y2)
			      ;; sin theta = y/sqrt(x2+y2)
			      
			      ;; (chain ctx (arc (@ end 0) (@ end 1) 12 (* 0.65 pi) (* 0.8 pi) true))
			      ;; (chain ctx (arc (@ end 0) (@ end 1) 12 (* pi (+ 0.5 (- (* ratio 0.25)
			      ;; 							     0.1)))
			      ;; 		      (* pi (+ 0.5 (+ (* ratio 0.25)
			      ;; 				      0.1)))
			      ;; 		      true))
			      ;; (cl :rr r2 x-len y-len)
			      ;; (chain ctx (arc (@ end 0) (@ end 1) 12 (+ (- pi) (- r2 (* pi 0.10)))
			      ;; 		      (+ (- pi) (+ r2 (* pi 0.10))) true))
			      (chain ctx (stroke)))))

		      (setf (@ ctx stroke-style) "black"
			    (@ ctx line-width) 1)))
	 (intersect-line (lambda (ent point callback)
			   (let ((line-start (chain self chart (to-dom-coords (@ ent start 0)
									      (@ ent start 1))))
				 (line-end (chain self chart (to-dom-coords (@ ent end 0)
									    (@ ent end 1))))
				 (margin 8))
			     (if (not (or (and (> (@ point 0) (+ (@ line-start 0) margin))
					       (> (@ point 0) (+ (@ line-end 0) margin)))
					  (and (< (@ point 0) (- (@ line-start 0) margin))
					       (< (@ point 0) (- (@ line-end 0) margin)))
					  (and (> (@ point 1) (+ (@ line-start 1) margin))
					       (> (@ point 1) (+ (@ line-end 1) margin)))
					  (and (< (@ point 1) (- (@ line-start 1) margin))
					       (< (@ point 1) (- (@ line-end 1) margin)))))
				 (let* ((ratio (/ (- (@ line-start 1) (@ line-end 1))
						  (- (@ line-end 0) (@ line-start 0))))
					(x-pos (- (@ point 0) (@ line-start 0)))
					(cross-y (abs (- (* x-pos ratio) (@ line-start 1)))))
				   (if (> 8 (abs (- cross-y (@ point 1))))
				       (funcall callback ent))))))))
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
	     (entities-count (@ self ephemera entities length)))
	 (if (= "select" (@ self ephemera interaction))
	     (let ((entity-clicked false))
	       (loop for entix from 0 to (1- entities-count)
		  do (chain self entity-methods line
			    (intersect
			     (getprop (@ self ephemera entities) entix)
			     dom-coords (lambda (ent)
					  (setf entity-clicked true
						(@ ent layer-start) (chain g (to-dom-coords (@ ent start 0)
											    (@ ent start 1)))
						(@ ent layer-end) (chain g (to-dom-coords (@ ent end 0)
											  (@ ent end 1))))
					  (if (@ ent in-flux)
					      (if (and (> 8 (abs (- (@ ent layer-start 0) (@ dom-coords 0))))
						       (> 8 (abs (- (@ ent layer-start 1) (@ dom-coords 1)))))
						  (chain (@ ent points-in-flux) (push "layerStart"))
						  (if (and (> 8 (abs (- (@ ent layer-end 0) (@ dom-coords 0))))
							   (> 8 (abs (- (@ ent layer-end 1) (@ dom-coords 1)))))
						      (chain (@ ent points-in-flux) (push "layerEnd")))))
					  (if (not (@ ent in-flux))
					      ;; only push the entity if it isn't already in flux, else
					      ;; entities can be pushed into the in-flux list multiple times
					      (progn (setf (@ ent in-flux) true)
						     (chain self ephemera entities-in-flux (push ent))))))))
	       (if (not entity-clicked)
		   (progn (setf (@ self ephemera entities-in-flux) (list))
			  (loop for ent in (@ self ephemera entities)
			     do (setf (@ ent in-flux) false))))
	       ;; (cl :flux (@ self ephemera entities-in-flux))
	       (setf (@ self ephemera moving-from) canvas-coords)
	       ;; (cl :mm (@ self ephemera moving-from))
	       (if (= 0 (@ self ephemera entities-in-flux length))
		   (progn (chain context (initialize-mouse-down event g context))
			  (chain window -dygraph (start-pan event g context)))
		   (chain g (draw-graph_))))
	     (if (= "draw" (@ self ephemera interaction))
		 (let* ((time-interval (- (@ g raw-data_ 1 0) (@ g raw-data_ 0 0)))
			(data-pos (chain g (to-data-coords (@ dom-coords 0) (@ dom-coords 1))))
			(remainder (mod (@ data-pos 0) time-interval)))
		   (if (/= 0 remainder)
		       (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
		   (let ((new-entity (create type (@ self ephemera draw-entity)
					     in-flux true
					     start (list (@ data-pos 0) (@ data-pos 1))
					     end (list (@ data-pos 0) (@ data-pos 1))
					     points-in-flux (list))))
		     (chain self ephemera entities (push new-entity))
		     (chain self ephemera entities-in-flux (push new-entity))
		     (setf (@ self ephemera active-entity)
			   new-entity))))))))
   :interact-mouseup
   (lambda (event chart context)
     (let ((self this))
       (setf (@ self ephemera mousedown) false)
       (if (= "select" (@ self ephemera interaction))
	   (if (@ context is-panning)
	       (progn (chain window -dygraph (end-pan event chart context))
		      (chain chart (draw-graph_)))
	       (progn (loop for ent in (@ self ephemera entities)
			 do (if (@ ent in-flux)
				(setf (@ ent start) (chain chart (to-data-coords (@ ent layer-start 0)
									     (@ ent layer-start 1)))
				      (@ ent end) (chain chart (to-data-coords (@ ent layer-end 0)
									   (@ ent layer-end 1)))
				      (@ ent layer-start) nil
				      (@ ent layer-end) nil
				      (@ ent points-in-flux) (list))))
		      (chain self (commit-entities))
		      (chain chart (draw-graph_))))
	   (if (= "draw" (@ self ephemera interaction))
	       (progn (setf (@ self ephemera active-entity) nil
			    (@ self ephemera interaction) "select")
		      (chain self (commit-entities))
		      (chain chart (draw-graph_)))))))
   :interact-mousemove
   (lambda (event chart context)
     (setq self this
	   temp-canvas (@ chart canvas_ctx_))
     (if (@ self ephemera mousedown)
	 (if (= "select" (@ self ephemera interaction))
	     (if (= 0 (@ self ephemera entities-in-flux length))
		 (if (@ context is-panning)
		     (chain window -dygraph (move-pan event chart context))
		     (chain chart (draw-graph_)))
		 (let ((moving-from (@ self ephemera moving-from)))
		   (chain temp-canvas (clear-rect 0 0 (@ chart canvas_ width) (@ chart canvas_ height)))
		   (loop for ent in (@ self ephemera entities-in-flux)
		      do (if (= 0 (@ ent points-in-flux length))
			     (setf (@ ent layer-start) (list (- (@ ent layer-start 0)
								(- (@ moving-from 0) (@ event layer-x)))
							     (- (@ ent layer-start 1)
								(- (@ moving-from 1) (@ event layer-y))))
				   (@ ent layer-end) (list (- (@ ent layer-end 0)
							      (- (@ moving-from 0) (@ event layer-x)))
							   (- (@ ent layer-end 1)
							      (- (@ moving-from 1) (@ event layer-y)))))
			     (let* ((time-interval (- (@ chart raw-data_ 1 0) (@ chart raw-data_ 0 0)))
				    (dom-coords (chain chart (event-to-dom-coords event)))
				    (data-pos (chain chart (to-data-coords (@ dom-coords 0) (@ dom-coords 1))))
				    (remainder (mod (@ data-pos 0) time-interval)))
			       (if (/= 0 remainder)
				   (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
			       (setf column-value (getprop (@ self state content-index) (@ data-pos 0)))
			       ;; (cl :cval data-pos column-value dom-coords)
			       (loop for point in (@ ent points-in-flux)
				  do (setf (getprop ent point) (list (@ event layer-x) (@ event layer-y))
					   time-coord (chain chart (to-dom-y-coord (@ column-value 1))))
				    ;; (cl :tc time-coord (getprop ent point 1))
				    (if (> 8 (abs (- time-coord (getprop ent point 1))))
					(progn (cl "Snapped!")
					       (setf (getprop ent point 1) time-coord))))))
			(setf (@ self ephemera moving-from) (list (@ event layer-x) (@ event layer-y)))
			(funcall (getprop self "entityMethods" (@ ent type) "draw")
				 temp-canvas ent chart))))
	     ;; TODO: add move-ephemera logic
	     (if (= "draw" (@ self ephemera interaction))
		 (let* ((time-interval (- (@ chart raw-data_ 1 0) (@ chart raw-data_ 0 0)))
			(dom-coords (chain chart (event-to-dom-coords event)))
			(data-pos (chain chart (to-data-coords (@ dom-coords 0) (@ dom-coords 1))))
			(remainder (mod (@ data-pos 0) time-interval))
			(ent (@ self ephemera active-entity)))
		   ;; snap to nearest rounded-down time interval
		   (if (/= 0 remainder)
		       (setf (@ data-pos 0) (- (@ data-pos 0) remainder)))
		   ;; (cl :ss remainder (@ data-pos 0))
		   (setf (@ ent end) (list (@ data-pos 0) (@ data-pos 1)))
		   (chain temp-canvas (clear-rect 0 0 (@ chart canvas_ width) (@ chart canvas_ height)))
		   (funcall (getprop self "entityMethods" (@ ent type) "draw")
			    temp-canvas ent chart))))))
   :interact-mousewheel
   (lambda (event chart context)
     ;; (cl :ev event)
     (if (@ event shift-key)
	 (let* ((price-range (chain chart (y-axis-range)))
		(price-interval (- (@ price-range 0) (@ price-range 1)))
		(zoom-interval (* 0.05 price-interval))
		(wheel-delta (if (< 0 (@ event delta-y)) 1 -1)))
	   (chain chart (update-options (create date-window (chain chart (x-axis-range))
						value-range (list (if (= 1 wheel-delta)
								      (- (@ price-range 0) zoom-interval)
								      (+ (@ price-range 0) zoom-interval))
								  (@ price-range 1))))))
	 (let* ((time-range (chain chart (x-axis-range)))
		(time-interval (- (@ time-range 1) (@ time-range 0)))
		(zoom-interval (* 0.05 time-interval))
		(wheel-delta (if (< 0 (@ event delta-y)) 1 -1)))
	   (chain chart (update-options (create date-window (list (if (= 1 wheel-delta)
								      (- (@ time-range 0) zoom-interval)
								      (+ (@ time-range 0) zoom-interval))
								  (@ time-range 1))
						value-range (chain chart (y-axis-range))))))))
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
		 ;; (cl :ents (@ self ephemera entities))
		 (loop for ent in (@ self ephemera entities)
		    do (if (not (and (@ self ephemera mousedown) (@ ent in-flux)))
		 	   (funcall (getprop self "entityMethods" (@ ent type) "draw")
		 		    ctx ent (@ e dygraph))))
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
					   labels (@ self state data data labels)
					   sig-figs 6
					   ;; series (create "EUR/CAD(Open, Ask)" (create axis "y2")
					   ;; 		  "EUR/CAD(High, Ask)" (create axis "y2")
					   ;; 		  "EUR/CAD(Low, Ask)" (create axis "y2")
					   ;; 		  "EUR/CAD(Close, Ask)" (create axis "y2")
					   ;; 		  "EUR/CAD(Open, Bid)*" (create axis "y2")
					   ;; 		  "EUR/CAD(High, Bid)*" (create axis "y2")
					   ;; 		  "EUR/CAD(Low, Bid)*" (create axis "y2")
					   ;; 		  ;; "EUR/CAD(Close, Bid)*" (create axis "y2")
					   ;; 		  )
					   axes (create x (create axis-label-formatter (@ self format-date-string))
							y (create draw-grid true
								  independent-ticks true
								  ;; axis-label-width 0
								  )
							;; y2 (create ;; draw-grid true
							;; 	   axis-label-width 50
							;; 	   labels-k-m-b true
							;; 	   independent-ticks true
							;; 	   )
							)
					   height (- (@ self pane-element client-height) 20)
					   width (- (@ self pane-element client-width) 20)
					   ;; pan-edge-fraction 0.8
					   ;; color-value 0.9
					   ;; hide-overlay-on-mouse-out false
					   interaction-model (create mousedown (@ self interact-mousedown)
					   			     mouseup (@ self interact-mouseup)
					   			     mousemove (@ self interact-mousemove)
								     wheel (@ self interact-mousewheel))
					   ;; draw-callback
					   ;; (lambda (chart is-initial)
					   ;;   (cl :draw (chain chart (to-dom-y-coord 1.51)))
					   ;;   (loop for ent in (@ self ephemera entities)
					   ;; 	do (if (not (@ ent in-flux))
					   ;; 	       (funcall (getprop self "entityMethods" (@ ent type) "draw")
					   ;; 			(@ chart hidden_ctx_) ent chart))))
					   )))))
       (chain self chart (update-options (create value-range (let ((range (chain self chart (y-axis-extremes))))
							       (list (* 0.995 (@ range 0))
								     (* 1.005 (@ range 1)))))))
       (setf (@ window use-chart) (@ self chart))
       )))
  (let ((self this))
    (if (= 0 (@ self ephemera entities length))
	(setf (@ self ephemera entities)
	      (chain j-query (extend (list) (@ self state entities)))))
    (panic:jsl (:div :class-name "dygraph-chart-holder"
		     (:div :class-name "dygraph-chart"
		     	   :ref (lambda (ref) (if (not (@ self container-element))
		     				  (setf (@ self container-element)
		     					ref)))
		     	   :id (+ "dygraph-chart-" (@ this props data id))))))))


     ;; (flet ((offset-to-percentage (ch offset-x offset-y)
     ;; 	      (let* ((x-offset (@ (chain ch (to-dom-coords (@ (chain ch (x-axis-range)) 0) nil)) 0))
     ;; 		     (yar0 (chain ch (y-axis-range 0)))
     ;; 		     (y-offset (@ (chain ch (to-dom-coords nil (@ yar0 1))) 1))
     ;; 		     (x (- offset-x x-offset))
     ;; 		     (y (- offset-y y-offset))
     ;; 		     (width (- (@ (chain ch (to-dom-coords (@ (chain ch (x-axis-range)) 1) null)) 0)
     ;; 			       x-offset))
     ;; 		     (height (- (@ (chain ch (to-dom-coords null (@ yar0 0))) 1)
     ;; 				y-offset))
     ;; 		     (x-pct (if (= 0 width) 0 (/ x width)))
     ;; 		     (y-pct (if (= 0 height) 0 (/ y height))))
     ;; 		(list x-pct (- 1 y-pct))))
     ;; 	    (zoom (ch zoom-in-percentage x-bias y-bias)
     ;; 	      (flet ((adjust-axis (axis zoom-in-percentage bias)
     ;; 		       (let* ((delta (- (@ axis 1) (@ axis 0)))
     ;; 			      (increment (* delta zoom-in-percentage))
     ;; 			      (foo (list (* increment bias) (* increment (- bias 1)))))
     ;; 			 (list (+ (@ axis 0) (@ foo 0))
     ;; 			       (- (@ axis 1) (@ foo 1))))))
     ;; 		(let ((x-bias (if x-bias x-bias 0.5))
     ;; 		      (y-bias (if y-bias y-bias 0.5))
     ;; 		      (y-axes (chain ch (y-axis-ranges)))
     ;; 		      (new-y-axes (list)))
     ;; 		  (loop for i from 0 to (1- (@ y-axes length))
     ;; 		     do (setf (getprop new-y-axes i)
     ;; 			      (adjust-axis (getprop y-axes i) zoom-in-percentage y-bias))
     ;; 		       (cl (chain ch (x-axis-range)))
     ;; 		       (chain ch (update-options (create date-window (adjust-axis (chain ch (x-axis-range))
     ;; 										  zoom-in-percentage x-bias)
     ;; 							 ;; value-range (@ new-y-axes 0)
     ;; 							 ))))))))
     ;; (let* ((normal (if (@ event detail) (* -1 (@ event detail))
     ;; 			(* 2 (@ event delta-y))))
     ;; 	    (percentage (/ normal 50)))
     ;;   (if (not (and (@ event offset-x) (@ event offset-y)))
     ;; 	   (setf (@ event offset-x) (- (@ event layer-x) (@ event target offset-left))
;; 		 (@ event offset-y) (- (@ event layer-y) (@ event target offset-top))))
;;   (let ((percentages (offset-to-percentage chart (@ event offset-x) (@ event offset-y))))
;; 	 (chain event (prevent-default))
;; 	 (chain event (stop-propagation))
;; 	 (zoom chart percentage (@ percentages 0) 0)
;; 	 (cl :percent percentages))))

;; function zoom(g, zoomInPercentage, xBias, yBias) {
;; xBias = xBias || 0.5;
;; yBias = yBias || 0.5;
;; function adjustAxis(axis, zoomInPercentage, bias) {
   ;; var delta = axis[1] - axis[0];
   ;; var increment = delta * zoomInPercentage;
   ;; var foo = [increment * bias, increment * (1-bias)];
   ;; return [ axis[0] + foo[0], axis[1] - foo[1] ];
   ;; }
   ;; var yAxes = g.yAxisRanges();
   ;; var newYAxes = [];
   ;; for (var i = 0; i < yAxes.length; i++) {
   ;; 	    newYAxes[i] = adjustAxis(yAxes[i], zoomInPercentage, yBias);
   ;; 	    }
   ;; 	    g.updateOptions({
   ;; 			    dateWindow: adjustAxis(g.xAxisRange(), zoomInPercentage, xBias),
   ;; 			    valueRange: newYAxes[0]
   ;; 			    });
   ;;          }
   ;; function offsetToPercentage(g, offsetX, offsetY) {
   ;; // This is calculating the pixel offset of the leftmost date.
   ;; var xOffset = g.toDomCoords(g.xAxisRange()[0], null)[0];
   ;; var yar0 = g.yAxisRange(0);

   ;; // This is calculating the pixel of the higest value. (Top pixel)
   ;; var yOffset = g.toDomCoords(null, yar0[1])[1];

   ;; // x y w and h are relative to the corner of the drawing area,
   ;; // so that the upper corner of the drawing area is (0, 0).
   ;; var x = offsetX - xOffset;
   ;; var y = offsetY - yOffset;

   ;; // This is computing the rightmost pixel, effectively defining the
   ;; // width.
   ;; var w = g.toDomCoords(g.xAxisRange()[1], null)[0] - xOffset;

   ;; // This is computing the lowest pixel, effectively defining the height.
   ;; var h = g.toDomCoords(null, yar0[0])[1] - yOffset;

   ;; // Percentage from the left.
   ;; var xPct = w == 0 ? 0 : (x / w);
   ;; // Percentage from the top.
   ;; var yPct = h == 0 ? 0 : (y / h);

   ;; // The (1-) part below changes it from "% distance down from the top"
   ;; // to "% distance up from the bottom".
   ;; return [xPct, (1-yPct)];
   ;; }


   ;; function scrollV3(event, g, context) {
   ;; var today = new Date();
   ;; milliseconds = today.getMilliseconds();

   ;; var normal = event.detail ? event.detail * -1 : event.deltaY * 2;
   ;; // For me the normalized value shows 0.075 for one click. If I took
   ;; // that verbatim, it would be a 7.5%.
   ;; var percentage = normal / 50;

   ;; if (!(event.offsetX && event.offsetY)){
   ;; event.offsetX = event.layerX - event.target.offsetLeft;
   ;; event.offsetY = event.layerY - event.target.offsetTop;
   ;; }

   ;; var percentages = offsetToPercentage(g, event.offsetX, event.offsetY);
   ;; var xPct = percentages[0];
   ;; var yPct = percentages[1];

   ;; zoom(g, percentage, xPct, yPct);
   ;; event.preventDefault();
   ;; event.stopPropagation();
   ;; }   
