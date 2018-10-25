;;;; portal.demo1.asd

(asdf/defsystem:defsystem #:portal.demo1
  :description "This is my portal."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:seed.generate #:seed.media.base #:seed.media.chart.base
	       #:seed.media.graph.garden-path #:seed.modulate
	       #:seed.modes.atom.base #:seed.modes.form.base
	       #:seed.modes.meta.common
	       #:seed.express.glyphs.base #:seed.ui-model.stage
	       #:seed.ui-model.keys #:seed.ui-model.html #:seed.ui-model.css
	       #:seed.ui-model.react #:seed.ui-spec.stage.base
	       #:seed.ui-spec.keys.base #:seed.ui-spec.keys.map-apl
	       #:seed.ui-spec.html.base #:seed.ui-spec.color.base
	       #:seed.ui-spec.display.common #:seed.ui-spec.css.base
	       #:seed.ui-spec.react.base #:seed.ui-spec.css-vector.base
	       #:seed.ui-spec.stage-menu.base  #:seed.ui-spec.stage-controls.graph
	       #:seed.ui-spec.stage-controls.document.base
	       #:seed.ui-spec.stage-controls.chart.base
	       #:seed.ui-spec.unit.base #:seed.ui-spec.form.base
	       #:seed.ui-spec.html-css.glyph-set-mdi
	       #:seed.ui-spec.form.mode-text
	       #:seed.ui-spec.form.mode-document
	       #:seed.ui-spec.form.mode-sheet
	       #:seed.ui-spec.form.mode-block-space
	       #:seed.ui-spec.form.mode-shape-graph
	       #:seed.ui-spec.form.mode-chart-dygraph
	       #:seed.ui-effects.vector.base
	       #:seed.foreign.browser-spec.script.base
	       #:seed.foreign.browser-spec.ss.form-dygraphs
	       #:seed.foreign.browser-spec.style.base
	       #:seed.foreign.browser-spec.style.icons-m-design
	       #:seed.app-model.site.base
	       #:quickproject #:prove #:parenscript #:panic #:lass
	       #:swank) ;; TODO: swank included only for demoSheet, are there other options?
  :components
  ((:file "package")
   (:file "test-core-systems")
   (:file "portal")))
