;;;; demo-image.lisp

(in-package #:demo-image)

(meta (raster-process-layers
       (load :path "sample.jpg")
       (apl :exp "1+input")
       (out :path "sample2.jpg")
       :MODE
       (:MODEL
	(META
	 ((META ((:CIRCLE :R 5 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#87AADE"))
		:MODE
		(:VALUE NIL :MODEL
			((:CIRCLE :R 5 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#87AADE"))
			:VIEW :ITEM :TITLE "Big Blue Circle" :REMOVABLE T))
	  (META ((:CIRCLE :R 5 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#87AADE"))
		:MODE
		(:VALUE NIL :MODEL
			((:CIRCLE :R 5 :STROKE-WIDTH 2 :STROKE "#E3DBDB" :FILL "#87AADE"))
			:VIEW :ITEM :TITLE "Big Blue Circle" :REMOVABLE T)))
	 :MODE
	 (:VALUE NIL :VIEW :LIST :FILL-BY :SELECT :REMOVABLE NIL :OPTIONS
		 ((:TITLE "Load File" :VALUE
			  (META
			   (load :path "sample.jpg")
			   :MODE (:VIEW :TEXTFIELD :VALUE "sample.jpg" :REMOVABLE T)))
		  (:TITLE "APL Mutation" :VALUE
			  (META
			   (apl :exp "255⌊⌈1.3×input")
			   :MODE (:VIEW :TEXTFIELD :VALUE "255⌊⌈1.3×input" :REMOVABLE T)))
		  (:TITLE "Output to File" :VALUE
			  (META
			   (out :path "sample2.jpg")
			   :MODE (:VIEW :TEXTFIELD :VALUE "sample2.jpg" :REMOVABLE T)))))))
       ;;:FORMAT :SPIRAL-POINTS-EXPAND
       :VALUE NIL))
