(IN-PACKAGE #:DEMO-IMAGE)
(DEFVAR IMAGE-OUTPUT-PATH)
(PROGN
 (META
  (SEED.APP-MODEL.RASTER-LAYERS.BASE:RASTER-PROCESS-LAYERS
   (:LOAD :PATH "sample-image.jpg") (:APL :EXP "0⌈255⌊⌈1.2×input")
   (:APL :EXP "0⌈255⌊20+input") (:OUTPUT :PATH "sample-image-out.jpg"))
  :MODE
  (:MODEL
   ((META
     (((META "sample-image.jpg" :MODE
        (:VIEW :TEXTFIELD :VALUE "sample-image.jpg"))))
     :MODE
     (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T :FORMAT-PROPERTIES
      (:TYPE :LOAD) :MODEL
      (((META "sample-image.jpg" :MODE
         (:VIEW :TEXTFIELD :VALUE "sample-image.jpg"))))
      :VALUE NIL))
    (META
     (((META "0⌈255⌊⌈1.2×input" :MODE
        (:VIEW :TEXTFIELD :VALUE "0⌈255⌊⌈1.3×input"))))
     :MODE
     (:VIEW :ITEM :TITLE "APL Mutation" :REMOVABLE T :FORMAT-PROPERTIES
      (:TYPE :APL) :MODEL
      (((META "0⌈255⌊⌈1.2×input" :MODE
         (:VIEW :TEXTFIELD :VALUE "0⌈255⌊⌈1.3×input"))))
      :VALUE NIL))
    (META (((META "0⌈255⌊20+input" :MODE (:VIEW :TEXTFIELD :VALUE "")))) :MODE
     (:VALUE NIL :MODEL
      (((META "0⌈255⌊20+input" :MODE (:VIEW :TEXTFIELD :VALUE ""))))
      :FORMAT-PROPERTIES (:TYPE :APL) :REMOVABLE T :TITLE "APL Mutation" :VIEW
      :ITEM))
    (META
     (((META "sample-image-out.jpg" :MODE
        (:VIEW :TEXTFIELD :VALUE "sample-image-out.jpg"))))
     :MODE
     (:VIEW :ITEM :TITLE "Output to File" :REMOVABLE T :FORMAT-PROPERTIES
      (:TYPE :OUTPUT) :MODEL
      (((META "sample-image-out.jpg" :MODE
         (:VIEW :TEXTFIELD :VALUE "sample-image-out.jpg"))))
      :VALUE NIL)))
   :VIEW :LIST :FILL-BY :SELECT :REMOVABLE NIL :OPTIONS
   ((:TITLE "Load File" :VALUE
     (META (((META "" :MODE (:VIEW :TEXTFIELD :VALUE "")))) :MODE
      (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T :FORMAT-PROPERTIES
       (:TYPE :LOAD))))
    (:TITLE "APL Mutation" :VALUE
     (META (((META "" :MODE (:VIEW :TEXTFIELD :VALUE "")))) :MODE
      (:VIEW :ITEM :TITLE "APL Mutation" :REMOVABLE T :FORMAT-PROPERTIES
       (:TYPE :APL))))
    (:TITLE "Output to File" :VALUE
     (META (((META "" :MODE (:VIEW :TEXTFIELD :VALUE "")))) :MODE
      (:VIEW :ITEM :TITLE "Output to File" :REMOVABLE T :FORMAT-PROPERTIES
       (:TYPE :OUTPUT)))))
   :FORMAT :RASTER-PROCESS-LAYERS-EXPAND :VALUE NIL)))
(SETQ IMAGE-OUTPUT-PATH "../demo-image/sample-image-out.jpg")
