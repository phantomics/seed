;;;; style.base.lisp

(in-package #:seed.foreign.browser-spec.style.base)

(defparameter *local-package* (package-name *package*))

(defun file-to-string (path)
  (with-open-file (stream path)
    (let ((data (make-string (file-length stream))))
      (read-sequence data stream)
      data)))

(defmacro cornerstone ()
  "Generate the content for the root style source file. This is currently just two lines of less code."
  (concatenate 'string
	       (file-to-string (asdf:system-relative-pathname
				(intern *local-package* "KEYWORD")
				"./bower_components/bootstrap/dist/css/bootstrap.min.css"))
	       (file-to-string (asdf:system-relative-pathname
				(intern *local-package* "KEYWORD")
				"./node_modules/react-select/dist/react-select.css"))))
