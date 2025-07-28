;;;; (#| TMPL_VAR name |#).asd(#| TMPL_IF copyright |#)
;; 
;;;; (#| TMPL_VAR copyright |#)(#| /TMPL_IF |#)

;;; Seed template: template.charts
;;; a template for charts

(asdf:defsystem #:(#| TMPL_VAR name |#)
  :description "Describe (#| TMPL_VAR name |#) here"
  :author "(#| TMPL_VAR author |#)"
  :license "(#| TMPL_VAR license |#)"
  :version "0.0.1"
  :serial t
  :depends-on ("april" "app.chart")
  :components ((:file "package")
               (:file "setup")
               (:file "sheet")))

