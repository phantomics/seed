;;;; ss.form-dygraphs.lisp

(in-package #:seed.foreign.browser-spec.ss.form-dygraphs)

(defparameter *local-package-name* (package-name *package*))

(defmacro foundational-browser-script-dygraphs ()
  "Generate the content for the root script source file."
  `(parenscript:ps (setf (@ window -dygraph) (require "dygraphs"))
		   t))

(defmacro foundational-browser-style-dygraphs ()
  "Generate the paths for the style source files."
  (mapcar (lambda (item) (asdf:system-relative-pathname (intern *local-package-name* "KEYWORD") item))
	  (list "./node_modules/dygraphs/dist/dygraph.min.css")))
