;;;; html.base.lisp

(in-package #:seed.ui-spec.html.base)

(defmacro html-index-header (title)
  "Generates HTML header using given page title."
  `(cl-who:htm (:head (:meta :charset "utf-8")
		      (:title ,title)
		      (:link :rel "stylesheet" :href "./main.css")
		      (:link :rel "stylesheet" :href "./portal.css"))))

(defmacro html-index-body ()
  "Generates HTML body."
  `(cl-who:htm (:body (:div :id "main")
		      (:script :type "text/javascript" :src "./main.js")
		      (:script :type "text/javascript" ,(concatenate 'string
								     "window.portalId = '"
								     (string-downcase (package-name *package*))
								     "'; window.portalTitle = '"
								     (lisp->camel-case (package-name *package*))
								     "';"))
		      (:script :type "text/javascript" :src "./portal.js"))))
