(in-package #:demo-sheet)

(setq abc (macroexpand `
(graph-garden-path main-graph
		   (:ID :CC :TYPE :SWITCH :ITEMS ("Begin")
			:META (:TITLE "First Node" :ABOUT "")
			;; :DO ((setf (getf state :bla)
			;; 	   (1+ (getf state :bla))))
			:LINKS ((:ID :AA :TITLE "Return" :IF (= 1 1))
				(:ID :BB :TITLE "Return" :IF t)))
		   (:ID :AA :TYPE :OPTION :ITEMS ("Hello")
			:META (:TITLE "Second Node" :ABOUT "")
			:LINKS ((:ID :BB :ITEMS "To Next")
				(:ID :AA :ITEMS "To Same")))
		   (:ID :BB :TYPE :OPTION :ITEMS ("Next")
			:META (:TITLE "Third Node" :ABOUT "")
			:LINKS ((:ID :AA :ITEMS "Go Back"))))
))

(graph-garden-path other-graph
		   (:id :ab :type :portal :to main-graph))

