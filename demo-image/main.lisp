(IN-PACKAGE #:DEMO-IMAGE)
(DEFVAR IMAGE-OUTPUT-PATH)
(META
 (RASTER-PROCESS-LAYERS (:LOAD :PATH "sample-image.jpg")
  (:APL :EXP "0⌈255⌊⌈1.2×input") (:APL :EXP "input[;;1]←100 ◊ 0⌈255⌊⌈input")
  (:OUTPUT :PATH "sample-image-out.jpg"))
 :MODE
 (:MODEL
  ((META
    ((META "sample-image.jpg" :MODE
           (:TITLE "File Path" :VIEW :TEXTFIELD :VALUE "sample-image.jpg")))
    :MODE
    (:VIEW :ITEM :TITLE "Load File" :OPEN T :REMOVABLE T :FORMAT-PROPERTIES
     (:TYPE :LOAD) :MODEL
     ((META "sample-image.jpg" :MODE
            (:TITLE "File Path" :VIEW :TEXTFIELD :VALUE "sample-image.jpg")))
     :VALUE NIL))
   (META
    ((META "0⌈255⌊⌈1.2×input" :MODE
           (:TITLE "APL" :VIEW :TEXTFIELD :VALUE "0⌈255⌊⌈1.3×input")))
    :MODE
    (:VIEW :ITEM :TITLE "APL Mutation" :OPEN T :REMOVABLE T :TOGGLE :ON
     :FORMAT-PROPERTIES (:TYPE :APL) :MODEL
     ((META "0⌈255⌊⌈1.2×input" :MODE
            (:TITLE "APL" :VIEW :TEXTFIELD :VALUE "0⌈255⌊⌈1.3×input")))
     :VALUE NIL))
   (META
    ((META "input[;;1]←100 ◊ 0⌈255⌊⌈input" :MODE
           (:TITLE "APL" :VIEW :TEXTFIELD :VALUE "")))
    :MODE
    (:VALUE NIL :MODEL
     ((META "input[;;1]←100 ◊ 0⌈255⌊⌈input" :MODE
            (:TITLE "APL" :VIEW :TEXTFIELD :VALUE "")))
     :FORMAT-PROPERTIES (:TYPE :APL) :OPEN T :REMOVABLE T :TITLE "APL Mutation"
     :TOGGLE :ON :VIEW :ITEM))
   (META
    ((META "sample-image-out.jpg" :MODE
           (:TITLE "File Path" :VIEW :TEXTFIELD :VALUE
            "sample-image-out.jpg")))
    :MODE
    (:VIEW :ITEM :TITLE "Output to File" :OPEN T :REMOVABLE T
     :FORMAT-PROPERTIES (:TYPE :OUTPUT) :MODEL
     ((META "sample-image-out.jpg" :MODE
            (:TITLE "File Path" :VIEW :TEXTFIELD :VALUE
             "sample-image-out.jpg")))
     :VALUE NIL)))
  :VIEW :LIST :FILL-BY :SELECT :REMOVABLE NIL :OPTIONS
  ((:TITLE "Load File" :VALUE
    (META ((META "" :MODE (:TITLE "File Path" :VIEW :TEXTFIELD :VALUE "")))
          :MODE
          (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T :OPEN T
           :FORMAT-PROPERTIES (:TYPE :LOAD))))
   (:TITLE "APL Mutation" :VALUE
    (META ((META "" :MODE (:TITLE "APL" :VIEW :TEXTFIELD :VALUE ""))) :MODE
          (:VIEW :ITEM :TITLE "APL Mutation" :REMOVABLE T :OPEN T
           :FORMAT-PROPERTIES (:TYPE :APL))))
   (:TITLE "Output to File" :VALUE
    (META ((META "" :MODE (:TITLE "File Path" :VIEW :TEXTFIELD :VALUE "")))
          :MODE
          (:VIEW :ITEM :TITLE "Output to File" :REMOVABLE T :OPEN T
           :FORMAT-PROPERTIES (:TYPE :OUTPUT)))))
  :FORMAT :RASTER-PROCESS-LAYERS-EXPAND :VALUE NIL))
(SETQ IMAGE-OUTPUT-PATH "../demo-image/sample-image-out.jpg")
