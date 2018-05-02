(in-package #:demo-sheet)

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
			:LINKS ((:ID :B1 :TO :AA :META (:TITLE "Go Back" :ABOUT "")
				     :ITEMS "Go Back"))))

(graph-garden-path other-graph
		   (:id :ab :type :portal :to main-graph))

