;;;; portal.demo1.asd

(asdf/defsystem:defsystem #:portal.demo1
  :description "This is my portal."
  :author "Andrew Sengul"
  :license "GPL-3.0"
  :serial t
  :depends-on (#:seed.generate #:seed.media.base #:seed.modulate 
	       #:seed.reflect.atom.base #:seed.reflect.form.base
	       #:seed.express.glyphs.base #:seed.ui-model.stage
	       #:seed.ui-model.keys #:seed.ui-model.html
	       #:seed.ui-model.react #:seed.ui-spec.stage.base
	       #:seed.ui-spec.keys.base #:seed.ui-spec.html.base
	       #:seed.ui-spec.react.base #:seed.ui-spec.css.base
	       #:seed.ui-spec.stage-menu.base
	       #:seed.ui-spec.unit.base #:seed.ui-spec.form.base
	       #:seed.ui-spec.form.mode-sheet
	       #:seed.foreign.browser-spec.script.base
	       #:seed.foreign.browser-spec.style.base
	       #:quickproject #:prove #:parenscript #:panic #:lass
	       #:swank) ;; TODO: swank included only for demoSheet, are there other options?
  :components
  ((:file "package")
   (:file "test-core-systems")
   (:file "portal")))
