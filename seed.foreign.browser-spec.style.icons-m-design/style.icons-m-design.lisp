;;;; style.icons-m-design.lisp

(in-package #:seed.foreign.browser-spec.style.icons-m-design)

(defparameter *local-package-name* (package-name *package*))

(defmacro foundational-browser-style-material-design-icons ()
  "Generate the paths for the style source files."
  (mapcar (lambda (item) (asdf:system-relative-pathname (intern *local-package-name* "KEYWORD") item))
	  (list "./material-icons.css")))
