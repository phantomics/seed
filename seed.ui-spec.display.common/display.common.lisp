;;;; display.common.lisp

(in-package #:seed.ui-model.react)

(specify-components
 html-view-mode
 (html-display
  (:get-initial-state
   (lambda () (create content-string (@ this props data)))
   :component-did-mount
   (lambda () (chain subcomponents (script-effects (@ this props))))
   ;; run specified script effects for the contained HTML
   :component-will-receive-props
   (lambda (next-props) (chain this (set-state (create content-string (@ next-props data))))))
  (panic:jsl (:div :class-name "element-view"
		   (seed-icon :face)
		   (:div :style (create font-size "400%")
			 (seed-icon :chart-editor))
		   (:div :class-name "html-display"
			 :dangerously-set-inner-h-t-m-l
			 (create __html (@ this state content-string))))))
 (bitmap-display
  (:get-initial-state
   (lambda () (create image-uri (@ this props data)))
   :component-will-receive-props
   (lambda (next-props)
     (let ((this-date (new (-date))))
       (chain this (set-state (create image-uri (+ (@ this props data) "?"
						   (chain this-date (get-time)))))))))
  (panic:jsl
   (:div :class-name "element-view"
	 (:img :src (@ this state image-uri))))))
