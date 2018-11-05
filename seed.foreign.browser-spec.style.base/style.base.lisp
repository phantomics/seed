;;;; style.base.lisp

(in-package #:seed.foreign.browser-spec.style.base)

(defparameter *local-package-name* (package-name *package*))

(defmacro foundational-browser-style-base ()
  "Generate the paths for the style source files."
  (mapcar (lambda (item) (asdf:system-relative-pathname (intern *local-package-name* "KEYWORD") item))
	  (list "./node_modules/bootstrap/dist/css/bootstrap.min.css"
		;; "./node_modules/react-select/dist/react-select.css"
		"./node_modules/codemirror/lib/codemirror.css"
		"./node_modules/codemirror/theme/solarized.css")))
