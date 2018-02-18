;;;; portal.lisp

(in-package #:portal.demo1)

(reflect :atom (reflect-atom-base)
	 :form (reflect-form-base))

(media media-spec-base)

(glyphs glyphs-base)

(test-core-systems)

(browser-interface :markup ((html-index-header "Seed: Demo Portal")
			    (html-index-body))
		   :script ((key-ui keystroke-maps
				    key-ui-base
				    key-ui-map-apl)
			    (react-ui ((react-portal-core (component-set interface-units interface-units)
							  (component-set view-modes
									 form-view-mode
									 text-view-mode
									 document-view-mode
									 sheet-view-mode)))
				      :url "portal"
				      :component :-portal))
		   :style (css-base
		   	   css-symbol-style-camel-case
		   	   css-animation-silicon-sky)
		   :foundation (:script (seed.foreign.browser-spec.script.base)
				:style (seed.foreign.browser-spec.style.base)))

(portal)

(stage (simple-stage :branches (simple-branch-layout :omit (:stage :clipboard :history)
						     :adjunct (:clipboard :history)
						     :extend (:menu (stage-extension-menu-base)))
		     :sub-nav (simple-sub-navigation-layout :omit (:stage :clipboard :history))))
