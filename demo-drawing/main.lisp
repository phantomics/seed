(IN-PACKAGE #:DEMO-DRAWING)
;(DEFVAR SVG-CONTENT)
(defmacro gen-svg (&rest form)
  (let ((stream-symbol (gensym)))
    (fare-quasiquote:quasiquote 
     (progn (defvar svg-content)
	    (defvar (fare-quasiquote:unquote stream-symbol)
	      (make-string-output-stream))
	    (cl-who:with-html-output ((fare-quasiquote:unquote stream-symbol))
	      (:svg (fare-quasiquote:unquote-splicing form)))
	    (setq svg-content (get-output-stream-string (fare-quasiquote:unquote stream-symbol)))))))

(GEN-SVG
 (:G :ID "group1"
  (:RECT :X 228 :Y 82 :HEIGHT 100 :WIDTH 40 :FILL
   (META "#67b468" :IF (:TYPE :COLOR-PICKER :OUTPUT :HTML-RGB-STRING)))
  (:ELLIPSE :CX 245 :FILL
   (META "#CC4B4B" :IF
    (:TYPE :SELECT :OPTIONS
     ((:VALUE "#CC4B4B" :TITLE "Faded Red")
      (:VALUE "#C80000" :TITLE "Dark Red"))))
   :CY 320 :RX 100 :RY 100))
 (META
  (SPIRAL-POINTS 450 300
   (META
    ((META ((:CIRCLE :R 3 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#88AA00"))
      :IF (:REMOVABLE T :TITLE "Small Green Circle" :TYPE :ITEM))
     (META ((:CIRCLE :R 3 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#88AA00"))
      :IF (:TYPE :ITEM :TITLE "Small Green Circle" :REMOVABLE T))
     (META ((:CIRCLE :R 3 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#88AA00"))
      :IF (:REMOVABLE T :TITLE "Small Green Circle" :TYPE :ITEM))
     (META ((:CIRCLE :R 3 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#88AA00"))
      :IF (:TYPE :ITEM :TITLE "Small Green Circle" :REMOVABLE T))
     (META ((:CIRCLE :R 5 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#87AADE"))
      :IF (:REMOVABLE T :TITLE "Big Blue Circle" :TYPE :ITEM))
     (META ((:CIRCLE :R 3 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#88AA00"))
      :IF (:REMOVABLE T :TITLE "Small Green Circle" :TYPE :ITEM))
     (META ((:CIRCLE :R 3 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#88AA00"))
      :IF (:TYPE :ITEM :TITLE "Small Green Circle" :REMOVABLE T))
     (META ((:CIRCLE :R 5 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#87AADE"))
      :IF (:REMOVABLE T :TITLE "Big Blue Circle" :TYPE :ITEM)))
    :IF
    (:OPTIONS
     ((:VALUE
       (META ((:CIRCLE :R 3 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#88AA00"))
        :IF (:TYPE :ITEM :TITLE "Small Green Circle" :REMOVABLE T))
       :TITLE "Small Green Circle")
      (:VALUE
       (META ((:CIRCLE :R 5 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#87AADE"))
        :IF (:TYPE :ITEM :TITLE "Big Blue Circle" :REMOVABLE T))
       :TITLE "Big Blue Circle"))
     :REMOVABLE NIL :FILL-BY :SELECT :TYPE :LIST)))
  :FORMAT SPIRAL-POINTS-EXPAND)
 )
(LET ((A 1) (B 2))
  (+ (* A 3) (+ B 1)))
(LIST #\a t NIL (CAR (CDR (LIST 1 2))))
