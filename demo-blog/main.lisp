(IN-PACKAGE #:DEMO-BLOG)
(META
 5
 :MODE
 (:MODEL
  ((META
    (((META "First Post" :MODE
	    (:VIEW :TEXTFIELD :VALUE "First Post"))))
    :MODE
    (:VIEW :ITEM :TITLE "Load File" :REMOVABLE T :FORMAT-PROPERTIES
     (:TYPE :LOAD) :MODEL
     (((META "First Post" :MODE
	     (:VIEW :TEXTFIELD :VALUE "First Post"))))
     :VALUE NIL)))
  :VIEW :LIST :FILL-BY :SELECT :REMOVABLE NIL :OPTIONS
  ((:TITLE "New Blog Post" :VALUE
    (META (((META "" :MODE (:VIEW :TEXTFIELD :VALUE "" :TITLE "Post Title")))) :MODE
     (:VIEW :ITEM :TITLE "Post" :REMOVABLE T :FORMAT-PROPERTIES
      (:TYPE :OUTPUT)))))
  :FORMAT :BLOG-POST-LIST-EXPAND :VALUE NIL))
