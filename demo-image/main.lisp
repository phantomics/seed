;;;; demo-image.lisp

(in-package #:demo-image)

(1+ (META ;; (raster-process-layers
      ;;  (load :path "sample.jpg")
      ;;  (apl :exp "0⌈255⌊⌈1.3×input")
      ;;  (out :path "sample2.jpg"))
      (+ 3 5)
      :MODE
      (:MODEL
       ((META ((:load (META "sampleX1.jpg"
			    :MODE (:VIEW :TEXTFIELD :VALUE "sampleX1.jpg"))))
	      :MODE (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T))
					;(META "sample.jpg"
					;     :MODE (:VIEW :TEXTFIELD :VALUE "sample.jpg"))
	
	(META ((:apl (META ""
			   :MODE (:VIEW :TEXTFIELD :VALUE ""))))
	      :MODE (:VIEW :ITEM :TITLE "APL Mutation" :REMOVABLE T))
	(META ((:out (META "sample2.jpg"
			   :MODE (:VIEW :TEXTFIELD :VALUE "sample2.jpg"))))
	      :MODE (:VIEW :ITEM :TITLE "Output to File" :REMOVABLE T)))
       :VALUE NIL :VIEW :LIST :FILL-BY :SELECT :REMOVABLE NIL :OPTIONS
       ((:TITLE "Load File" :VALUE
		((META
		  ((:load (META "sampleXX.jpg"
				:MODE (:VIEW :TEXTFIELD :VALUE "sampleXX.jpg"))))
		  :MODE (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T))))
	;; (:TITLE "Load File" :VALUE
	;; 	((META
	;; 	  (:load)
	;; 	  :MODE (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T))
	;; 	 (META
	;; 	  "sample.jpg"
	;; 	  :MODE (:VIEW :TEXTFIELD :VALUE "sample.jpg"))))
	(:TITLE "APL Mutation" :VALUE
		((META
		  (:apl)
		  :MODE (:VIEW :ITEM :TITLE "APL Mutation" :REMOVABLE T))
		 (META
		  ""
		  :MODE (:VIEW :TEXTFIELD :VALUE ""))))
	(:TITLE "Output to File" :VALUE
		((META
		  (:outx)
		  :MODE (:VIEW :ITEM :TITLE "Output to File" :REMOVABLE T))
		 (META
		  "sample2.jpg"
		  :MODE (:VIEW :TEXTFIELD :VALUE "sample2.jpg" :REMOVABLE T)))))
       :FORMAT :RASTER-PROCESS-LAYERS-EXPAND :VALUE NIL)))

