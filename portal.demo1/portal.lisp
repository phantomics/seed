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
		   :style ((css-styles (with :palettes
			   		     ((:standard :base03 "#002b36" :base02 "#073642" :base01 "#586e75"
			   				 :base00 "#657b83" :base0 "#839496" :base1 "#93a1a1"
			   				 :base2 "#eee8d5" :base3 "#fdf6e3" :yellow "#b58900"
			   				 :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
			   				 :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
			   				 :green "#859900")
			   		      (:adjunct :BASE03 "#262625" :BASE02 "#2F3033" :BASE01 "#676B71"
			   				:BASE00 "#707784" :BASE0 "#89919E" :BASE1 "#9A9EA5"
			   				:BASE2 "#E6E8EC" :BASE3 "#F7F6F5" :yellow "#B38A39"
			   				:orange "#BD5A34" :red "#C94F42" :magenta "#BE527E"
			   				:violet "#6874AF" :blue "#408ABC" :cyan "#509D95"
			   				:green "#919637")
			   		      (:backdrop :BASE03 "#262625" :BASE02 "#33302D" :BASE01 "#716964"
			   				 :BASE00 "#83746A" :BASE0 "#9E8E83" :BASE1 "#A59C97"
			   				 :BASE2 "#ECE7E4" :BASE3 "#F7F6F5" :yellow "#B38A39"
			   				 :orange "#BD5A34" :red "#C94F42" :magenta "#BE527E"
			   				 :violet "#6874AF" :blue "#408ABC" :cyan "#509D95"
			   				 :green "#919637")))
			   	       css-base css-overview css-adjunct css-column-view
			   	       css-text-view
			   	       css-ivector-standard
				       css-symbol-style-camel-case)
			   (css-styles (with :palettes ((:standard :base03 "#002b36" :base02 "#073642" :base01 "#586e75"
			   				 :base00 "#657b83" :base0 "#839496" :base1 "#93a1a1"
			   				 :base2 "#eee8d5" :base3 "#fdf6e3" :yellow "#b58900"
			   				 :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
			   				 :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
			   				 :green "#859900")
							(:adjunct :BASE03 "#262625" :BASE02 "#2F3033" :BASE01 "#676B71"
								  :BASE00 "#707784" :BASE0 "#89919E" :BASE1 "#9A9EA5"
								  :BASE2 "#E6E8EC" :BASE3 "#F7F6F5" :yellow "#B38A39"
								  :orange "#BD5A34" :red "#C94F42" :magenta "#BE527E"
								  :violet "#6874AF" :blue "#408ABC" :cyan "#509D95"
								  :green "#919637")
							(:backdrop :BASE03 "#262625" :BASE02 "#33302D" :BASE01 "#716964"
								   :BASE00 "#83746A" :BASE0 "#9E8E83" :BASE1 "#A59C97"
								   :BASE2 "#ECE7E4" :BASE3 "#F7F6F5" :yellow "#B38A39"
								   :orange "#BD5A34" :red "#C94F42" :magenta "#BE527E"
								   :violet "#6874AF" :blue "#408ABC" :cyan "#509D95"
								   :green "#919637"))
			   		     :palette-contexts (:holder))
			   	       css-form-view)
			   css-animation-silicon-sky)
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
