;;;; portal.demo1.lisp

(in-package #:portal.demo1)

(defvar *contact-interfaces* nil)

(defun of-contacts (key)
  (getf *contact-interfaces* key))

(defun add-contact (key value)
  (setf (getf *contact-interfaces* key) value))

(implement-start-controls grow contact-start contact-restart contact-stop)

(quote
 (list
  (build-static-page *package* :portal.demo1 "ui-browser")
        
  (build-styles *package* "ui-browser")

  (build-script-cmirror *package*)

  (build-script-misc *package* "ui-browser")

  ))

(provide-browser-script
 :portal.demo1
 (:concat-static
  (:paths "./ui-browser/static/htmx.min.js"
          "./ui-browser/node_modules/canvas-datagrid/dist/canvas-datagrid.js"
          "./ui-browser/static/alpine.js")
  (:output-to . "./ui-browser/build/vendor.js"))
 (:concat-static
  (:paths "./ui-browser/node_modules/bulma/css/bulma.css")
  (:output-to . "./ui-browser/build/vendor.css")))

(defun build-all ()
  (build-static-page :portal.demo1 "ui-browser")
  (build-script-cmirror)
  (build-script-misc "ui-browser"))

;; (build-all)

#|

(defvar *portal*)

(modes (:atom modes-atom-base)
       (:form modes-form-base)
       (:meta modes-meta-common))

(media media-spec-base media-spec-chart-base media-spec-graph-garden-path)

(glyphs glyphs-base)

(test-core-systems)

(browser-interface (:markup (html-index-header "Seed: Demo Portal")
			    (html-index-body))
		   (:script (key-ui keystroke-maps key-ui-base
				    key-ui-map-apl-meta-specialized)
			    (react-ui (with (:url "portal")
					    (:component :-portal)
					    (:glyph-sets material-design-glyph-set-common))
				      (react-portal-core (component-set interface-units interface-units)
							 (component-set view-modes
									form-view-mode
									text-view-mode
									(html-view-mode :script-effects
											standard-form-effects)
									document-view-mode
									sheet-view-mode
									block-space-view-mode
									dygraph-chart-view-mode
									(graph-shape-view-mode
									 :effects standard-vector-effects)))))
		   (:style (css-styles (with (:palettes (:standard palette-hicontrast-solarized)
							(:adjunct palette-medcontrast-adjunct)
							(:backdrop palette-medcontrast-dropcloth)))
			   	       css-base css-overview css-adjunct css-column-view
				       (css-form-view (with (:palette-contexts :holder)))
				       (css-form-view-interface-elements (with (:palette-contexts :element)))
			   	       css-text-view css-ivector-standard css-font-spec-ddin
				       (css-glyph-display (with (:palette-contexts :element)))
				       css-symbol-style-camel-case)
			   css-animation-silicon-sky)
		   (:foundation (:scripts foundational-browser-script-base
					  foundational-browser-script-dygraphs)
				(:styles foundational-browser-style-base
					 foundational-browser-style-material-design-icons
					 foundational-browser-style-dygraphs)))

(portal)

(stage (simple-stage :branches
		     (simple-branch-layout :menu (stage-extension-menu-base)
					   :controls (stage-control-set :by-spec (stage-controls-base-contextual)
									:by-parameters
									(stage-controls-graph-base
									 stage-controls-document-base
									 stage-controls-chart-base)))
		     :sub-nav (simple-sub-navigation-layout :omit (:stage :clipboard :history))))

(defun grow (system key &optional session input)
  (let ((system (if (eq t system) :portal.demo1
                    (or system :all))))
    (if (eq system :portal.demo1)
        (funcall (getf views key) session input)
        (funcall (gethash *portal-interfaces* system)
                 key session input))))


|#

