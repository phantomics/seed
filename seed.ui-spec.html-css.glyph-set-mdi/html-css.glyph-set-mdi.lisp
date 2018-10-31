;;;; html-css.glyph-set-mdi.lisp

(in-package #:seed.ui-spec.html-css.glyph-set-mdi)

(defmacro simple-icon (name)
  ``(:div :class-name "icon simple" (:i :class-name "material-icons" ,,(string-downcase name))))

(defmacro composite-icon (&key (main nil) (hint nil) (backdrop nil))
  ``(:div :class-name "icon-holder"
	   (:div :class-name "icon composition"
		 ,,(if hint ``(:div :class-name "hint spot"
				      (:i :class-name "material-icons" ,,(string-downcase hint))))
		 (:div :class-name "main"
		       (:i :class-name "material-icons" ,,(string-downcase main)))
		 ,,(if hint ``(:div :class-name "backdrop"
				      (:i :class-name "material-icons" ,,(string-downcase backdrop)))))))

(defmacro specify-icons (properties &rest icons)
  (let* ((properties (rest properties))
	 (params-symbol (second (assoc :params-symbol properties)))
	 (macro-symbol (second (assoc :macro-symbol properties)))
	 (icon-specs (loop for icon in icons collect (list (first icon)
							   params-symbol (macroexpand (second icon))))))
    `(defmacro ,macro-symbol () (quote ,icon-specs))))

(specify-icons (with (:macro-symbol material-design-glyph-set-common)
		     (:params-symbol params))
	       (face (simple-icon face))
	       (cake (simple-icon cake))
	       (chart-editor (composite-icon :main show_chart :hint add :backdrop crop_square)))
