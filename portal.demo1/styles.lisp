(in-package #:my-portal)

(defvar css-string nil)

(setq css-string
      (concatenate 'string 
		   "/* Portal styles */"
      (lass:compile-and-write
       '(|#main|
	 (.container
	  :background "#fff"

	  (.portal-column
	   :padding-right 8px
	   :padding-left 8px))
	 (.portal

	  (.overview
	   :position absolute
	   :top 0
	   :left 0
	   :height 100%
	   :width 16em
	   :background "#ddd")

	  (.view

	   (.main
	    :padding 0 0 0 16em

	    (.status
	     :margin 0 0 6px
	     :padding 4px 14px
	     :width 100%
	     :background "#eee"

	     (span
	      :font-size 14px
	      :font-weight bold))

	    (.branches

	     (.container
	      :max-width 100%)

	     (div.pane
	      :background "#fdf6e3"
	      :margin 0 0 0 1px
	      :padding-left 6px
	      :padding-right 6px
	      :height 100%

	      (td
	       :background transparent
	       :padding 0 0 0 9px)

	      (td.form-heading
	       :border none
	       :border-bottom 1px solid "#eee8d5")

	      (td.form-value
	       :border none
	       :border-bottom 1px solid "#eee8d5")

	      (.handsontable
	       ((:and tr :first-child)
		((:or th td)
		 :border-top none))
	       ((:or 
		 (:and th :first-child)
		 (:and th :first-of-type))
		:border-left none)))
	     
	     (svg.dendroglyphs
	      :position absolute
	      :top 0
	      :left 15px
	      :height 100%
	      :width 100%
	      :pointer-events none
	      (path
	       :fill none
	       :stroke "#93a1a1"
	       :stroke-width 2.5)))))))

       '(.form-value.type-form
	 :color "#073642"
	 :font-family monospace
	 :font-weight bold)

       '(.form-value.type-name
	 :color "#888"
	 :font-family monospace
	 :font-weight bold)

       '(.form-value.type-string
	 :color "#0000cd"
	 :font-family monospace
	 :font-weight bold)

       '((:and .form-value.type-string :before)
	 :content "\"\\\"\""
	 :padding-right 0.3em)

       '(.form-value.type-keyword
	 :color "#008800"
	 :font-family monospace
	 :font-weight bold)

       '((:and .form-value.type-keyword :before)
	 :content "\":\""
	 :padding-right 0.3em))))

;.handsontable th:first-child, .handsontable td:first-of-type, .handsontable .htNoFrame + th, .handsontable .htNoFrame + td {
;    border-left: none;
;}
