(IN-PACKAGE #:DEMO-IMAGE)
(DEFVAR IMAGE-OUTPUT-PATH)
(META
 (RASTER-PROCESS-LAYERS (:LOAD :PATH "sample-image.jpg")
  (:APL :EXP "0⌈255⌊⌈1.2×input") (:OUTPUT :PATH "sample-image-out.jpg"))
 :MODE
 (:VALUE NIL :FORMAT :RASTER-PROCESS-LAYERS-EXPAND :OPTIONS
  ((:VALUE
    (META ((META "" :MODE (:VALUE "" :VIEW :TEXTFIELD :TITLE "File Path")))
          :MODE
          (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T :OPEN T
           :FORMAT-PROPERTIES (:TYPE :LOAD)))
    :TITLE "Load File")
   (:VALUE
    (META ((META "" :MODE (:VALUE "" :VIEW :TEXTFIELD :TITLE "APL"))) :MODE
          (:VIEW :ITEM :TITLE "APL Mutation" :REMOVABLE T :OPEN T
           :FORMAT-PROPERTIES (:TYPE :APL)))
    :TITLE "APL Mutation")
   (:VALUE
    (META ((META "" :MODE (:VALUE "" :VIEW :TEXTFIELD :TITLE "File Path")))
          :MODE
          (:VIEW :ITEM :TITLE "Output to File" :REMOVABLE T :OPEN T
           :FORMAT-PROPERTIES (:TYPE :OUTPUT)))
    :TITLE "Output to File"))
  :REMOVABLE NIL :FILL-BY :SELECT :VIEW :LIST :MODEL
  ((META
    ((META "sample-image.jpg" :MODE
           (:VALUE "sample-image.jpg" :VIEW :TEXTFIELD :TITLE "File Path")))
    :MODE
    (:VALUE NIL :MODEL
     ((META "sample-image.jpg" :MODE
            (:VALUE "sample-image.jpg" :VIEW :TEXTFIELD :TITLE "File Path")))
     :FORMAT-PROPERTIES (:TYPE :LOAD) :REMOVABLE T :OPEN T :TITLE "Load File"
     :VIEW :ITEM))
   (META
    ((META "0⌈255⌊⌈1.2×input" :MODE
           (:VALUE "0⌈255⌊⌈1.3×input" :VIEW :TEXTFIELD :TITLE "APL")))
    :MODE
    (:VALUE NIL :MODEL
     ((META "0⌈255⌊⌈1.2×input" :MODE
            (:VALUE "0⌈255⌊⌈1.3×input" :VIEW :TEXTFIELD :TITLE "APL")))
     :FORMAT-PROPERTIES (:TYPE :APL) :TOGGLE :ON :REMOVABLE T :OPEN T :TITLE
     "APL Mutation" :VIEW :ITEM))
   (META
    ((META "input[;;1]←100 ◊ 0⌈255⌊⌈input" :MODE
           (:VALUE "" :VIEW :TEXTFIELD :TITLE "APL")))
    :MODE
    (:VIEW :ITEM :TOGGLE :OFF :TITLE "APL Mutation" :REMOVABLE T :OPEN T
     :FORMAT-PROPERTIES (:TYPE :APL) :MODEL
     ((META "input[;;1]←100 ◊ 0⌈255⌊⌈input" :MODE
            (:VALUE "" :VIEW :TEXTFIELD :TITLE "APL")))
     :VALUE NIL))
   (META
    ((META "sample-image-out.jpg" :MODE
           (:VALUE "sample-image-out.jpg" :VIEW :TEXTFIELD :TITLE
            "File Path")))
    :MODE
    (:VALUE NIL :MODEL
     ((META "sample-image-out.jpg" :MODE
            (:VALUE "sample-image-out.jpg" :VIEW :TEXTFIELD :TITLE
             "File Path")))
     :FORMAT-PROPERTIES (:TYPE :OUTPUT) :REMOVABLE T :OPEN T :TITLE
     "Output to File" :VIEW :ITEM)))))
(SETQ IMAGE-OUTPUT-PATH "../demo-image/sample-image-out.jpg")
