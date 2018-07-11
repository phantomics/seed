;;;; portal.lisp

(in-package #:portal.demo1)

(defvar *portal*)

(modes :atom (modes-atom-base)
       :form (modes-form-base)
       :meta (modes-meta-common))

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
		   	   css-symbol-style-camel-case
		   	   css-animation-silicon-sky
			   (css-ivector-standard (with :palettes
						       ((:standard :base3 "#fdf6e3" :base2 "#eee8d5"
								   :base1 "#93a1a1" :base0 "#839496"
								   :base00 "#657b83" :base01 "#586e75"
								   :base02 "#073642" :base03 "#002b36"
								   :yellow "#b58900" :orange "#cb4b16"
								   :red "#dc322f" :magenta "#d33682"
								   :violet "#6c71c4" :blue "#268bd2"
								   :cyan "#2aa198" :green "#859900")))))
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
