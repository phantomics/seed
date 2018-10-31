;;;; portal.lisp

(in-package #:portal.demo1)

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
				       css-glyph-display css-symbol-style-camel-case)
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
