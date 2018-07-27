(in-package #:demo-graph)

(graph-garden-path main-graph
		   (:ID :CC :TYPE :SWITCH :ITEMS ("Begin")
			:META (:TITLE "First Node" :ABOUT "")
			:DO ((setf (getf state :bla)
				   (1+ (getf state :bla))))
			:LINKS ((:ID :C1 :TO :AA :META (:TITLE "Return" :ABOUT "")
				     :IF (= 1 1))
				(:ID :C2 :TO :BB :META (:TITLE "Other Node" :ABOUT "")
				     :IF t)))
		   (:ID :AA :TYPE :OPTION :ITEMS ("Hello")
			:META (:TITLE "Second Node" :ABOUT "")
			:LINKS ((:ID :A1 :TO :BB :META (:TITLE "To Next" :ABOUT "")
				     :ITEMS ("To Next"))
				(:ID :A2 :TO :AA :META (:TITLE "To Same" :ABOUT "")
				     :ITEMS ("To Same"))))
		   (:ID :BB :TYPE :OPTION :ITEMS ("Next")
			:META (:TITLE "Third Node" :ABOUT "")
			:DO ((META
			      5
			      :MODE
			      (:MODEL
			       ((META (((META "First Section"
					      :MODE (:VIEW :TEXTFIELD :VALUE "First Section")))) :MODE
					      (:VIEW :ITEM :TITLE "Section Title" :REMOVABLE T :FORMAT-PROPERTIES
						     (:TYPE :SECTION-TITLE))))
			       :VIEW :LIST :FILL-BY :SELECT :REMOVABLE NIL :OPTIONS
			       ((:TITLE "Section Title" :VALUE
					(META (((META "" :MODE (:VIEW :TEXTFIELD :VALUE "")))) :MODE
					      (:VIEW :ITEM :TITLE "Section Title" :REMOVABLE T :FORMAT-PROPERTIES
						     (:TYPE :SECTION-TITLE))))
				(:TITLE "Form Field" :VALUE
					(META (((META "" :MODE (:VIEW :TEXTFIELD :VALUE "")))) :MODE
					      (:VIEW :ITEM :TITLE "Form Field" :REMOVABLE T :FORMAT-PROPERTIES
						     (:TYPE :FORM-FIELD)))))
			       :FORMAT :HTML-FORM-COMPONENTS-EXPAND :VALUE NIL)))
			:LINKS ((:ID :B1 :TO :AA :META (:TITLE "Go Back" :ABOUT "")
				     :ITEMS "Go Back"))))


