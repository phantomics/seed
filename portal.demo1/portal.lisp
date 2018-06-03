;;;; portal.lisp

(in-package #:portal.demo1)

(reflect :atom (reflect-atom-base)
	 :form (reflect-form-base))

(media media-spec-base media-spec-graph-garden-path)

(glyphs glyphs-base)

(test-core-systems)

(browser-interface :markup ((html-index-header "Seed: Demo Portal")
			    (html-index-body))
		   :script ((key-ui keystroke-maps
				    key-ui-base
				    key-ui-map-apl-meta-specialized)
			    (react-ui ((react-portal-core (component-set interface-units interface-units)
							  (component-set view-modes
									 form-view-mode
									 text-view-mode
									 document-view-mode
									 sheet-view-mode
									 block-space-view-mode
									 (graph-shape-view-mode
									  :effects standard-vector-effects))))
				      :url "portal"
				      :component :-portal))
		   :style (css-base
		   	   css-symbol-style-dash-separated
		   	   css-animation-silicon-sky
			   css-ivector-standard)
		   :foundation (:script (seed.foreign.browser-spec.script.base)
				:style (seed.foreign.browser-spec.style.base)))

(portal)

(stage (simple-stage :branches
		     (simple-branch-layout :menu (stage-extension-menu-base)
					   :controls (stage-control-set :by-spec (stage-controls-base-contextual)
									:by-parameters
									(stage-controls-graph-base
									 stage-controls-document-base)))
		     :sub-nav (simple-sub-navigation-layout :omit (:stage :clipboard :history))))
