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
				    key-ui-base)
			    (react-ui (extend-rcomps-base)
				      :url "portal"
				      :component :-portal))
		   ;; :style (css-base
		   ;; 	   css-symbol-style-camel-case
		   ;; 	   css-animation-silicon-sky)
		   :foundation (:script (seed.foreign.browser-spec.script.base)
				:style (seed.foreign.browser-spec.style.base)))

(stage :systems (:demo-sheet :demo-drawing)
       :arch (simple-portal-layout)
       :thrust (simple-branch-layout))

(portal)
