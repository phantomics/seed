;;;; css.base.lisp

(in-package #:seed.ui-model.css)

;; Main CSS styles for Seed's interface.
(specify-css-styles
 css-base
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :basic
 (``("/* Portal styles */
  @keyframes animatedBackground {
    from { background-position: 0 50px; }
    to { background-position: 0 0; }}"
    (body :overflow hidden
	  :height 100%
	  :width 100%
	  (.breaker :clear both))

    (|#main|
     :height 100%
     :width 100%

     ;; high-level portal styles
     (.portal
      :height 100%
      :width 100%
      :padding 0
      :position relative

      (.row :margin 0)
      
      (|.row > .vista|
       :padding 0)

      (.vista.full (.row :height 100%)
		   (.col :padding 0
			 :height 100%))
      (.vista.brief.col-1 :flex 0 0 5.55555%
			  :max-width 5.55555%)

      ;; universal form styles go here
      ((:or ul.form-view.short ul.form-view.brief)
       :list-style-type none
       :padding 0
       (ul.form-view.in
    	:list-style-type none))
      
      (ul.form-view.short
       (ul.form-view.in
    	:padding 0 0 0 8px))

      (|ul.form-view.short > li > ul.form-view.in|
       :margin 0 
       :padding 0)

      (|ul.form-view.short > li > ul.form-view.in > li|
       :border none)

      (.horizontal-view
       ((:or ul.form-view.short ul.form-view.brief)
    	;:display inline
    	(li :display inline
    	    :margin-left 4px
    	    (div :display inline)
    	    ;; don't display editor divs in the footer view, 
    	    ;; since items there are meant as interface elements
    	    ;; TODO: this logic should be less tightly coupled
    	    (div.editor :display none))
    	(.breaker :display none
    		  :clear none))
       ((:or |ul.form-view.short > li| |ul.form-view.brief > li|)
    	:display block))

      ;; styles for common form and atom types
      (.form-view
       :padding 0
       ;(.editor :display none)
       (table.form 
    	:margin 0 0 0 8px
    	(.atom
    	 (.content.type-symbol
    	  (.title :color "#839496"))

    	 (.content.type-keyword
    	  :padding-left 2px
    	  (.title :color "#859900"))

    	 (.content.type-name
    	  (.text :color "#073642"))

    	 (.content.type-number
    	  (.text :color "#dc322f"))

    	 (.content.type-boolean
    	  (.text :color "#268bd2"
    		 :text-transform uppercase))

    	 (.content.type-character
    	  (.text :color "#d33682"))

    	 (.content.type-string
    	  (.text :color "#2aa198")
    	  ((:and .text :before)
    	   :content "\""))))))

     (|.portal > .row|
      :height 100%)))))

(specify-css-styles
 css-font-spec-ddin
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :basic
 (``("/* D-DIN font specification */
@font-face {
    font-family: 'DDIN';
    src: url('./style-assets/d-din-complete-v1.0/D-DIN.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0/D-DIN.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0/D-DIN.ttf') format('truetype');
    font-weight: normal;
    font-style: normal;}

@font-face {
    font-family: 'DDINBold';
    src: url('./style-assets/d-din-complete-v1.0/D-DIN-Bold.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0/D-DIN-Bold.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0/D-DIN-Bold.ttf') format('truetype');
    font-weight: bold;
    font-style: normal;}

@font-face {
    font-family: 'DDINItalic';
    src: url('./style-assets/d-din-complete-v1.0/D-DIN-Italic.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0/D-DIN-Italic.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0/D-DIN-Italic.ttf') format('truetype');
    font-weight: normal;
    font-style: italic;}

@font-face {
    font-family: 'DDINCondensed';
    src: url('./style-assets/d-din-complete-v1.0/D-DINCondensed.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0/D-DINCondensed.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0/D-DINCondensed.ttf') format('truetype');
    font-weight: normal;
    font-style: normal;}

@font-face {
    font-family: 'DDINCondensedBold';
    src: url('./style-assets/d-din-complete-v1.0//D-DINCondensed-Bold.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0//D-DINCondensed-Bold.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0//D-DINCondensed-Bold.ttf') format('truetype');
    font-weight: bold;
    font-style: normal;}

@font-face {
    font-family: 'DDINExp';
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp.ttf') format('truetype');
    font-weight: normal;
    font-style: normal;}

@font-face {
    font-family: 'DDINExpBold';
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp-Bold.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp-Bold.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp-Bold.ttf') format('truetype');
    font-weight: bold;
    font-style: normal;}

@font-face {
    font-family: 'DDINExpItalic';
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp-Italic.woff') format('woff');
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp-Italic.woff2') format('woff2');
    src: url('./style-assets/d-din-complete-v1.0/D-DINExp-Italic.ttf') format('truetype');
    font-weight: normal;
    font-style: italic;}
"
     (body :font-family "'DDIN', Fallback, sans-serif"))))

(specify-css-styles 
 css-overview
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :by-palette (``((.overview
		  :background ,base3
		  :border-right 2px solid ,base2
		  :color ,base0
		  (.overview-headspacer :background ,base1)
		  (.portal-name :color ,blue
				;; :background ,base02
				:border-bottom 2px solid ,base01)
		  (.form-view (ul.in (li :border-color red)))
		  (.footer (.title-container :color ,base1
					     :border-bottom 2px solid ,base2)))
		 (.overview.point (.form-view (.point :color ,red)))))
 :basic
 (``((|#main|
      (.portal
       (.overview
	:font-family monospace
	;;:position absolute
	;;:top 0
	;;:left 0
	:height 100%
	:width 100%
	;;:width 16em
	;; :background "#fafafa"
	;; :color "#2e3135"
	;; :border-right 3px solid ;; "#ebebeb" ;"#dadde2"
	:z-index 1000
	(.overview-headspacer
	 :height 10px
	 :margin-right 6px)
	(.form-view
	 :margin 0 6px
	 (.portal-name
	  :height 37px
	  :margin-bottom 4px
	  ;; :margin 0 6px
	  (.title :font-family monospace
		  :font-size 1.2em
		  :line-height 2.2em))
	 (ul.in :padding 6px
		:list-style-type none
		:margin 8px 0
		(li :border-bottom 1px solid ; "#dadde2" ;"#e8ded0"
		    :cursor pointer)
		(.index
		 (.content
		  ((:and .title :after)
		   :content " ➜"
		   :float right
		   :margin 0.05em 6px 0 0
		   :font-size 1.2em
		   :line-height 1em)))))

	(.form-view.short
	 :margin 0
	 (ul.form-view.in :padding 0))
	
	;; styles for the overview footer
	(.footer
	 :position absolute
	 :bottom 0
	 :width 100%
	 (.title-container 
	  :margin 0 12px 5px 0
	  :position relative
	  (.title :font-size 1.2em
		  :margin 0
		  :padding 2px 0
		  :font-family monospace
		  :position absolute
		  :bottom 0
		  :right 0
		  :text-align right)))))))))

(specify-css-styles 
 css-adjunct
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :by-palette (``((.adjunct-view
		  :background ,base3
		  :border-left 2px solid ,base2
		  (.status :border-bottom 2px solid ,base2)
		  (.view-section (.header (.id-char :color ,base0))
				 (.content ((:or .bar .point-marker)
					    (div :background ,base00))
					   (.point (.bar (div :background ,red)))
					   (.bar.sub-point (div :background ,base00))
					   (.atom-inner.point (.point-marker (div :background ,red)))))
		  (.view-section.point (.id-char :color ,red)))))
 :basic
 (``((|#main|
      (.portal
       ;; styles for the main adjunct view pane
       (.adjunct-view
	:height 100%

	(.status :min-height 10px
		 :margin 0 4px)

	(.view-section
	 :margin 0 4px
	 (.header :text-align right
		  (.id-char :font-size 120%
			    :line-height 1.25em))
	 (.content
	  (.bar.composite :float left)
	  ((:or .bar .point-marker)
	   :width 100%
	   :height 2px
	   :margin 0 0 2px 0
	   (div ;; :background "#dadde2"
		:height 100%))
	  (.point-marker (div :display none))
	  (.atom-inner.point
	   (.point-marker (div :display block
			       ;; :background "#cc5c4b"
			       :width 9%
			       :float right)))))

	(.view-section.empty :display none)
	
	;; (.view-section.display-history
	;;  (.content ;;(.point (.bar (div :background "#dadde2")))
	;;   (.bar.sub-point (div :background "#6f7c91"))))
	))))))

(specify-css-styles 
 css-column-view
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :by-palette (``((.branches (.container :background ,base2
					(.portal-column
					 (.header
					  :color ,base1
					  :border-top 2px solid ,base1
					  :background
					  ,(format nil "linear-gradient(0deg, ~a 1px, ~a 1px)" base1 base3))
					 (.header.point :color ,red)
					 (.footer :border-top 1px solid ,base1
						  :background ,base3)
					 (.holder :background ,base3)
					  ;; (.footer :border-top 1px solid ,base1)
					 (.sub-header :border-bottom 1px solid ,base1)

					 ((:or .footer .sub-header)
					  :height 42px
					  (.inner (span :color ,base0
							:border-bottom 2px solid ,base2
							:cursor pointer)
						  (.atom-inner.point
						   (span :background ,base2))))
					 
					 ((:or .footer.point .sub-header.point)
					  (.inner :border-bottom 2px solid ,base1
						  (span :border-bottom 2px solid ,base1)
						  (.atom-inner.point (span :color ,base3
									   :background ,base1)))))))))
 :basic
 (``((|#main|
      (.portal
       (.view
	(.main
	 ;; :margin 0 4em 0 16em
	 :position relative

	 ;; (.status
	 ;;  :margin 0 0 6px
	 ;;  :padding 3px 14px
	 ;;  :position absolute
	 ;;  :width 100%
	 ;;  :background "#2e3135"
	 ;;  :color "#d1d5da"
	 ;;  :opacity 0.8
	 ;;  :z-index 800

	 ;;  (.text :font-size 0.9em
	 ;; 	:font-weight bold
	 ;; 	:font-family monospace
	 ;; 	:display none))

	 ;; ((:and .status :hover)
	 ;;  (.text :display inline))

	 ;; (.focus
	 ;;  (.status
	 ;;   :background "#888"
	 ;;   :color "#fff"))

	 (.branches
	  :position relative

	  ;; styles for the top-level branch display elements
	  (.container 
	   ;; :width 100%
	   :height 100%
	   :padding 8px; 24px
	   :margin 0
	   :max-width 100%
	   (.column-outer :padding-left 0
			  :padding-right 8px
			  :display flex
			  :flex-direction column)
	   ((:and .column-outer :last-child) :padding-right 0)
	   
	   (.portal-column
	    :height 100%
	    :padding 8px ;0 2px 0 0
	    (.header
	     :position relative
	     ;; :color "#93a1a1"
	     ;; :background "repeating-linear-gradient(0deg, #93a1a1, #93a1a1 2px, #073642 2px, #073642 40px)"
	     ;; :background "linear-gradient(0deg, #93a1a1 2px, #073642 2px)"
	     :height 38px
	     :font-family monospace
	     :padding 0 6px
	     :margin 0 2px
	     (.branch-info
	      :height 100%
	      (.locked-indicator
	       :float right
	       :font-weight bold
	       :color "#dc322f")))

	    (.footer :margin 0 2px)

	    (span.id
	     :font-size 1.25em
	     :line-height 40px)
	    	  
	    (.holder :height "calc(100% - 72px)"
		     :position relative
		     :margin 0 2px))

	   ((:or .portal-column.form .portal-column.spreadsheet)
	    (.pane :padding-right 2px))
	   
	   (.row 
	    ((:and .vista :last-child)
	     (.portal-column :padding 0))))

	  ((:or .footer .sub-header)
	   :height 30px
	   (.inner :padding 4px
		   :text-align right
		   :font-family monospace
		   (span.title :padding 0 4px)
		   (span :cursor pointer)))

	  (.sub-header (.inner :padding-top 4px
			       (.form-view :text-align left)))

	  (div.pane.with-sub-header :height "calc(100% - 30px)")
	  
	  (div.pane
	   :background "#fdf6e3"
	   :position relative
	   ;;:height "calc(100% - 40px)"
	   :height 100%
	   :margin 0
	   :overflow auto)))))))))

(specify-css-styles
 css-form-view
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :by-palette (``((.matrix-view
		  (table.form
		   (.atom
		    :border-bottom-color ,base2
		    (.content (.package-tag :background ,base2)))))))
 :basic
 (``((|#main|
      (.portal
       (.view
	(.main
	 (.branches
	  (div.pane
	   (.form-view :height 100%
		       :padding 2px 0
		       (table.form.root :margin-bottom 2px))

	   ;; styles for popover menus
	   (.form-view.menu-popover
	    :height auto
	    :border "2px solid rgba(0, 0, 0, 0.2)"
	    :padding 0
	    :margin-left 2.2em
	    :margin-top -1.9em
	    (.arrow :display none)
	    (.popover-content
	     :padding 4px
	     (.form-view
	      :margin 0
	      :padding 0
	      (ul.in :list-style-type none
		     (li :border-bottom 1px solid "#dadde2" ;"#e8ded0"
			 :cursor pointer
			 (.point
			  (.content
			   (.title
			    :color red))))))))

	   ;; form view styles
	   (.matrix-view
	    (table.form
	     (td
	      :vertical-align top
	      :position relative
	      :-moz-box-sizing border-box
	      :box-sizing border-box)

	     ((:and td :|not(:last-child)|)
	      :white-space nowrap)

	     ((:and td :last-child)
	      :width 100%)

	     ((:and td.point :last-child)
	      :border-right "2px solid #D9D4C5")

	     ;; ((:and td.point :last-child :after)
	     ;;  :content " "
	     ;;  :width 3px
	     ;;  :height 5px
	     ;;  :background red)

	     (tr (.atom :border-bottom-width 1px
			:border-bottom-style solid)
		 (.atom.custom-interface :border-bottom none)
		 (.atom.last :border-bottom none))

	     ;; styles for areas affected by macros
	     (.reader-context-quasiquote
	      :background "rgba(200,99,99,0.065)")

	     ((:and .reader-context-quasiquote .reader-context-start)
	      :background "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' version='1.1'><g style='fill:#916f6f;fill-opacity:1'><path style='fill:#916f6f;fill-opacity:0.3;stroke:none' d='M 0,3 2.9999998,-1e-7 12,9 9.0000005,12 z'/></g></svg>\"), linear-gradient(90deg, rgba(145,111,111,0.3) 4px, rgba(200,99,99,0.065) 4px)"
	      :background-repeat no-repeat
	      :background-position "bottom 2px right 6px, 0 0")

	     (.reader-context-unquote
	      :background "#fdf6e3")

	     ((:and .reader-context-unquote .reader-context-start)
	      :background "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' version='1.1'><g style='fill:#916f6f;fill-opacity:1'><path style='fill:#073642;fill-opacity:0.2;stroke:none' d='M 12,3 9.0000002,-1e-7 0,9 2.9999995,12 z'/></g></svg>\"), linear-gradient(90deg, rgba(7,54,66,0.15) 4px, #fdf6e3 4px)"
	      :background-repeat no-repeat
	      :background-position "bottom 2px right 6px, 0 0")

	     (.reader-context-unquote-splicing
	      :background "#fdf6e3")

	     ((:and .reader-context-unquote-splicing .reader-context-start)
	      :background "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='16' height='12' version='1.1'><g style='fill:#916f6f;fill-opacity:1'><path style='fill:#073642;fill-opacity:0.2;stroke:none'  d='M 12,3 9.0000002,-1e-7 0,9 2.9999995,12 z'/><path style='fill:#073642;fill-opacity:0.2;stroke:none' d='m 16.964286,8.875 a 2.5892856,2.5892856 0 1 1 -5.178572,0 2.5892856,2.5892856 0 1 1 5.178572,0 z' transform='matrix(1.1724138,0,0,1.1724138,-4.2271792,-2.5646177)'/></g></svg>\"), linear-gradient(90deg, rgba(7,54,66,0.15) 4px, #fdf6e3 4px)"
	      :background-repeat no-repeat
	      :background-position "bottom 2px right 6px, 0 0")

	     (.atom
	      (.editor
	       (input
		:outline none
		:position absolute
		:color "#586e75"
		:font-family monospace
 		:background none
		:border none
		:width 100%
		:line-height 1em))

	      (.content
	       :margin 0 8px 0 9px
	       :font-family monospace
	       :min-height 17px
	       :line-height 17px

	       (.package-tag
		:color "#268bd2"
		:cursor help
		:font-size 0.75em
		:line-height 1em
		:padding 0 2px
		:border-radius 0 6px 6px 6px
		;; :background "#eee8d5"
		:opacity 0.6
		:margin-left 2px
		(span (.seed-symbol
		       (.divider :display none)
		       ((:or .m .ll)
			:display none)
		       ((:and span :|not(:first-child)|)
			(.fl :text-transform none))
		       (span.leading
			(.fl :text-transform none))
		       ((:and span.leading :|not(:first-child)|)
			(.fl :color "#cb4b16"))))
		(span.native :display none))

	       (.package-tag.mini
		:font-size 0.9em
		:margin 0 0 0 2px
		:border-radius 3px 3px 3px 0)

	       (.package-tag.native
		:color "#cb4b16"
		:background "#cb4b16"
		:height 8px
		:width 8px
		:border-radius 0 3px 3px 3px
		:display block
		(span :display none)
		(span.native :display inline))

	       (.package-tag.native.mini
		:display inline
		:background none
		:font-size 0.7em
		:opacity 0.3
		:margin 0
		:border-radius 3px 3px 3px 0)

	       (.package-tag (.common :display none)))

	      ((:and .package-tag :hover)
	       :opacity 1)

	      (.point-marker
	       :position absolute
	       :bottom 0
	       :right 0
	       :height 4px
	       :width 4px
	       :background "#fdf6e3")

	      (.meta-comment
	       :margin 0 4px 0 0
	       :padding 0 6px
	       :line-height 1.2em
	       :font-size 0.8em
	       :background aliceblue
	       :border-right "2px solid #93a1a1"
	       :color cadetblue
	       :position absolute
	       :bottom 0
	       :right 0
	       
	       (input :border none
		      :outline none
		      :background none
		      :color inherit))
	      
	      (.rgb-control
	       :height 16px
	       :width 24px
	       :border-radius 8px
	       :float left
	       :border "2px solid #ccc")

	      (.rgb-string
	       :line-height 1.5em
	       :color "#6c71c4"))

	     (.info-tabs
	      (span :padding 3px
		    :background "#ededed"
		    :border "1px solid #dadde2"
		    :border-bottom none
		    :border-radius 4px 4px 0 0)
	      (.title :float left)
	      (.remove :float right
		       :padding 3px 9px
		       :cursor pointer))

	     (.atom.point
	      (.meta-comment.focus :border-left "2px solid #93a1a1"))

	     (.atom.singleton
	      (.content
	       (span.title :padding-right 4px
			   :border-right "1.6px solid #93a1a1")))

	     ;; ((:or .atom.mode-set.point .cell.mode-set.point)
	     ;;  (.text :opacity 0)
	     ;;  (.title :opacity 0)
	     ;;  (.editor :display block
	     ;; 	      :float left))

	     (.atom.point.active
	      ;; :background "repeating-linear-gradient(0deg, #eee8d5, #eee8d5 6px, #fdf6e3 6px, #fdf6e3 40px)"
	      :background "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='100' height='50'><rect fill='%23eee8d5' x='0' y='21' width='100%' height='8px'/></svg>\")"
	      :background-repeat repeat-y repeat-x
	      :background-position 0px 0px
	      ;; :animation "animatedBackground 3s linear infinite"
	      ;; :animation "animatedBackground 3s cubic-bezier(0, 0.5, 1, 1) infinite"
	      ;; :-ms-animation "animatedBackground 10s linear infinite"
	      ;; :-moz-animation "animatedBackground 10s linear infinite"
	      ;; :-webkit-animation "animatedBackground 10s linear infinite"
	      )

	     ((:or .atom.point .cell.point) :background "#eee8d5")
	     (.form-value.current :background "#eee8d5")

	     ((:or td.sub-table td.special-table)
	      :padding 0
	      :position relative
	      (.spacer
	       :width 12px
	       :height 100%
	       :float left)
	      (table
	       :width "calc(100% - 12px)"))

	     (td.sub-table.point
	      :linear-gradient "90deg, #eee8d5, #eee8d5 12px, rgba(0,0,0,0), rgba(0,0,0,0) 12px"
	      :border-right none
	      )

	     ))

	   ;; spreadsheet view styles
	   (.spreadsheet-view
	    :margin 3px 6px 0 2px
	    (table.form
	     (thead
	      (th :border-left 1px solid "#eee8d5"
		  :border-bottom 1px solid "#eee8d5"
		  :text-align left)
	      ((:and th :first-child)
	       :border-left none))
	     (th :color "#586e75"
		 :font-family monospace
		 :border-right 1px solid "#eee8d5"
		 :border-bottom 1px solid "#eee8d5"
		 :text-align right
					;:height 20px
		 :padding 0 4px)
	     (tbody
	      (:td :height 20px)
	      ((:and tr :last-child)
	       ((:or th td)
		:border-bottom none)))

	     (.atom
	      :border 1px solid "#eee8d5"
	      :min-width 52px
	      :text-align right
	      (.editor :float left)
	      (.content
	       :margin 0 1px
	       :padding 0 0px
	       :position relative
					;:background "repeating-linear-gradient(to right, #93a1a1, #93a1a1 1px, transparent 1px, transparent 2px)"
	       ;; :background "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAQAAAAQCAYAAAAxtt7zAAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH4QgfBgknWYMcHwAAABl0RVh0Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAAZSURBVBjTY5i8cOF/BgYGBhjNxIAGRpYAAO3DBcdsmHSyAAAAAElFTkSuQmCC') transparent"
	       :background-size 0 100%
	       :background-repeat no-repeat
	       (.text :color "#839496"
		      :margin-right 2px)
	       (.overridden-text :float left
				 :margin 0 12px 0 0
				 :color "#dc322f"))
	      (.content.input
	       (.text :color "#268bd2"))
	      (.content.computed-input
	       (.text :color "#859900"))
	      (.content.type-function
	       (.text :color "#6c71c4")))

	     (.atom.mode-set.point
	      (.overridden-text :display none))

	     (.content
	      ((:and .text :before)
	       :position absolute
	       :top -2px
	       :left 0
	       :transform "rotate(90deg)"
	       :transform-origin left top 0
	       :margin 0 0 0 1em
	       :letter-spacing -2px
	       :float left))
	     
	     (.content.it-2
	      ((:and .text :before)
	       :content "."))

	     (.content.it-3
	      ((:and .text :before)
	       :content ".."))

	     (.content.it-4
	      ((:and .text :before)
	       :content "..."))

	     (.content.it-5
	      ((:and .text :before)
	       :content "...."))

	     (.content.it-6
	      ((:and .text :before)
	       :content ":..."))

	     (.content.it-7
	      ((:and .text :before)
	       :content "::.."))

	     (.content.it-8
	      ((:and .text :before)
	       :content ":::."))

	     (.content.it-9
	      ((:and .text :before)
	       :content "::::"))

	     (.atom.active
	      :text-align left)
	     
	     ((:and .atom :last-child)
	      :border-right none)))

	   (svg.dendroglyphs :position absolute
			     :height 100%
			     :width 100%
			     :pointer-events none
			     (.glyph (path :fill none
					   :stroke "#93a1a1"
					   :stroke-width 1.6))
			     (.glyph-shadow (path :fill none
						  :stroke "#fdf6e3"
						  :stroke-width 2.4))
			     (.point (.glyph (path :stroke "#073642")))
			     :z-index 500))))))))))

(specify-css-styles
 css-form-view-interface-elements
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :by-palette (``((.item-interface-holder
		  :color ,base00
		  :background-color ,base3
		  :border-color ,base2
		  :|box-shadow| ,(format nil "2px 2px 0px ~aaa" base1))
		 ((:or .list-interface-holder .menu-holder .item-interface-holder)
		  :color ,base0
		  (.navbar :color ,base00
			   :background-color ,base3
			   :border-color ,base2
			   (.main :border-color ,base2))
		  (.main ((:and .title :hover)
			  :background-image ,(format nil "-webkit-repeating-linear-gradient(-45deg, ~a33, ~a33 25%, transparent 25%, transparent 50%, ~a33 50%)" base1 base1 base1)
			  :background-image ,(format nil "-moz-repeating-linear-gradient(-45deg, ~a33, ~a33 25%, transparent 25%, transparent 50%, ~a33 50%)" base1 base1 base1)
			  :background-image ,(format nil "-mz-repeating-linear-gradient(-45deg, ~a33, ~a33 25%, transparent 25%, transparent 50%, ~a33 50%)" base1 base1 base1)
			  :background-image ,(format nil "-o-repeating-linear-gradient(-45deg, ~a33, ~a33 25%, transparent 25%, transparent 50%, ~a33 50%)" base1 base1 base1)
			  :background-image ,(format nil "repeating-linear-gradient(-45deg, ~a33, ~a33 25%, transparent 25%, transparent 50%, ~a33 50%)" base1 base1 base1)))
		  (button :color ,base00
			  :background-color ,base3
			  :border-color ,base2
			  (.button-detail :border-color ,base1))
		  (.select-control
		   :color ,base00
		   :background-color ,base2
		   :border-right-color ,base1))
		 (|.list-interface-holder > .navbar|
		  :|box-shadow| ,(format nil "2px 2px 0px ~aaa" base1))
		 (.textfield-holder
		  :color ,base00
		  :border-color ,base2
		  :background-color ,base3
		  :|box-shadow| ,(format nil "2px 2px 0px ~aaa" base1)
		  (.input-wrapper
		   :border-color ,base2
		   (input :border-color ,base1))
		  (.input-group-append
		   :background ,base2
		   (.label-holder :color ,base0
				  :border-color ,base1)))
		 (.textarea-holder
		  :color ,base00
		  :border-color ,base2
		  (input.textarea
		   :background-color ,base3))
		 
		 (.menu-holder
		  (.dropdown.btn-group
		   :|box-shadow| ,(format nil "2px 2px 0px ~aaa" base1)
		   (button :border-color ,base2)))))
 :basic
 (``((|#main|
      (.portal
       (.form-view
	(|.item > .content > table > tbody > tr > td|
	 :padding 0)
	(.item-interface-holder
	 :margin 6px 12px 0 12px
	 :padding 0
	 :min-height 1.6rem
	 :border-radius 0
	 :border-width 0 0 1px 4px
	 :border-style solid)
	(.list-interface-holder
	 (.navbar :margin 6px 12px 0 12px
		  :padding 0
		  ;; :min-height 1.8em
		  :border-radius 0
		  :border-width 0 0 1px 4px
		  :border-style solid))
	((:or .list-interface-holder .menu-holder .item-interface-holder)
	 (.dropdown.btn-group
	  (button :border-width 0 1px 0 0
		  :border-radius 0
		  :border-style solid
		  :padding 0.2rem 0.6rem))
	 (.dropdown.open.btn-group
	  (.dropdown-menu :display block))
	 (.main
	  :height 1.6rem
	  :flex 1 1 auto
	  :border-style solid
	  :border-width 0
	  :margin 0
	  (.sortable-glyph :float left
			   :padding-top 1px)
	  (.remove :float right :cursor pointer
		   :padding-top 3px)
	  (.title :float left
		  :margin 2px 0 0 0
		  :padding 2px 0 2px 2px
		  :cursor grab
		  :width 80%)
	  ((:and .title :hover)
	   :background-size 4px 4px)
	  (.list-label :float right)
	  (.list-info
	   :float right
	   :padding 8px 0
	   (.remove :margin-left 8px
		    :padding-top 3px))
	  (.select
	   :width 40%
	   :float left
	   ;; (.select-control
	   ;; 	:background-color "#fafafa"
	   ;; 	:border-color "#dadde2"
	   ;; 	:margin 2px 0
	   ;; 	:border-radius 0 4px 4px 0
	   ;; 	:border-left none)
	   (.select-control
	    :margin 2px 0
	    :border-radius 0
	    :border-width 0
	    :border-right-width 2px)))

	 (.btn-group.toggle
	  :float left
	  :margin 0
	  (button :width 3em
		  :height 1.6rem
		  :border-width 0
		  :border-radius 0
		  :position relative
		  (.button-detail :position absolute
				  :bottom 2px
				  :right 2px
				  :height 5px
				  :width 5px
				  :border-style solid
				  :border-width 1px 0 0 1px))
	  ((:and button :active)
	   (.button-detail :top 2px
			   :left 2px
			   :border-width 0 1px 1px 0)))
	 (.list-info))
	
	(.item-interface-holder.with-toggle
	 (.main :border-width 0 0 0 1px))
	
	(.textfield-holder
	 (.input-wrapper
	  :padding 4px
	  :border-style solid
	  :border-width 0 0 1px 2px
	  :border-radius 0
	  :height auto
	  :background none
	  (input.textfield
	   :border-radius 0
	   :width "calc(100% - 6px)"
	   :background none
	   :border-width 0 0 0 1px
	   :border-style solid
	   :margin 0
	   :padding 0 4px))
	 (.input-group-append
	  :border-radius 0
	  :border-width 0
	  :border-left-width 1px
	  :padding 3px 6px
	  (.label-holder.input-group-text
	   :padding 0 0 0 6px
	   :border-width 0 0 1px 0
	   :border-style solid
	   :background none
	   :border-radius 0)))

	(.textarea-holder
	 (textarea
	  :resize none
	  :width 100%
	  :margin 3px 0 3px 12px
	  :border-style solid
	  :margin 0
	  :padding 4px
	  :border-radius 0))
	
	(.menu-holder
	 (.dropdown.btn-group
	  (button :width 100%
		  :border-width 1px 2px 1px 4px
		  :border-radius 0
		  :border-style solid))
	 (.dropdown.btn-group.open (.dropdown-menu :display block)))
	))))))

;; (specify-css-styles
;;  css-form-view-interface-elements
;;  (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
;; 			 yellow orange red magenta violet blue cyan green))
;;  :by-palette (``(((:or .list-interface-holder .menu-holder .item-interface-holder)
;; 		  (.panel :background-color ,base3
;; 			  :border-left-color ,base2)
;; 		  (button :border-left--color ,base2)
;; 		  (.select-control
;; 		   :background-color ,base2
;; 		   :border-right-color ,base1))))
;;  :basic
;;  (``((|#main|
;;       (.portal
;;        (.view
;; 	(.main
;; 	 (.branches
;; 	  (div.pane
;; 	   (.form-view
;; 	    ((:or .list-interface-holder .menu-holder .item-interface-holder)
;; 	     (.panel
;; 	      :width "calc(100% - 12px)"
;; 	      :margin 3px 0 3px 12px
;; 	      :border-width 0
;; 	      :border-radius 0
;; 	      :border-left-width 2px
;; 	      (.panel-body
;; 	       :padding 4px 8px 4px 0
;; 	       (.panel-heading
;; 		:padding 0
;; 		(.handle
;; 		 :float left
;; 		 :height 20px
;; 		 :width 24px
;; 		 :cursor grab
;; 		 :margin 0 0 0 4px
;; 		 :background-image "-webkit-repeating-linear-gradient(-45deg, rgba(0,0,0,0.20), rgba(0,0,0,0.20) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.20) 50%)"
;; 		 :background-image "-moz-repeating-linear-gradient(-45deg, rgba(0,0,0,0.20), rgba(0,0,0,0.20) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.20) 50%)"
;; 		 :background-image "-ms-repeating-linear-gradient(-45deg, rgba(0,0,0,0.20), rgba(0,0,0,0.20) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.20) 50%)"
;; 		 :background-image "-o-repeating-linear-gradient(-45deg, rgba(0,0,0,0.20), rgba(0,0,0,0.20) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.20) 50%)"
;; 		 :background-image "repeating-linear-gradient(-45deg, rgba(0,0,0,0.20), rgba(0,0,0,0.20) 25%, transparent 25%, transparent 50%, rgba(0,0,0,0.20) 50%)"
;; 		 :background-size 4px 4px)))
;; 	      (.remove :float right :cursor pointer)
;; 	      (.title :float left
;; 		      :margin-left 8px)
;; 	      (.list-label :float right)
;; 	      (.list-info
;; 	       :float right
;; 	       :padding 8px 0
;; 	       (.remove :margin-left 8px))
;; 	      (.select
;; 	       :width 40%
;; 	       :float left
;; 	       (.select-control
;; 		:margin 2px 0
;; 		;; :border-radius 0 4px 4px 0
;; 		:border-radius 0
;; 		:border-width 0
;; 		:border-right-width 2px))

;; 	    (.item-interface-holder
;; 	     :margin 6px 0 0 12px
;; 	     (.panel :float left
;; 		     :width "calc(100% - 12px)"
;; 		     :height 1.8em
;; 		     :margin 0)
;; 	     (.btn-group.toggle
;; 	      :float left
;; 	      :margin 0
;; 	      (button :width 3em
;; 		      :height 1.8em
;; 		      :background "#fff"
;; 		      ;; :border "1px solid #ddd"
;; 		      :border-width 0
;; 		      ;; :|box-shadow| "0 1px 1px rgba(0,0,0,.05)"
;; 		      ;; :border-radius 4px 0 0 4px
;; 		      :border-radius 0))

;; 	     ;; ((:and .btn-group :|:first-child|)
;; 	     ;;  (button :border-left-width 2px))

;; 	    (.item-interface-holder.with-toggle
;; 	     (.panel :width "calc(100% - 12px - 3em)"
;; 		     :border-radius 0 4px 4px 0
;; 		     :border-left none))
	    
;; 	    (.textfield-holder
;; 	     (input.textfield
;; 	      :background-color "#fafafa"
;; 	      :border "1px solid #dadde2"
;; 	      :border-radius 2px
;; 	      :width "calc(100% - 6px)"
;; 	      ;; :margin 1px 0 0 6px
;; 	      :margin 0 0 0 6px
;; 	      :padding 4px 8px))

;; 	    (.textarea-holder
;; 	     (textarea
;; 	      :resize none
;; 	      :width 100%
;; 	      :margin 3px 0 3px 12px
;; 	      :background-color "#fafafa"
;; 	      :border-color "#dadde2"
;; 	      :margin 0
;; 	      :padding 4px
;; 	      :border-radius 0 4px 4px 4px)))))))))))

(specify-css-styles 
 css-glyph-display
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :by-palette (``((.icon :color ,base0
			(.spot :color ,red
			       :text-shadow 2px 2px ,base3)
			(.backdrop :color ,base2))))
 :basic
 (``((|#main|
      (.portal
       (.view
	((:or div.icon-holder div.icon.simple) :display inline)
	(div.icon
	 ;; :display inline
	 :position relative
	 :width 2em
	 (.main :margin 0
		:position absolute
		:z-index 200
		(.material-icons :font-size 1em))
	 (.hint
	  :z-index 500
	  :position absolute
	  :top 0.4em
	  :left -0.2em
	  (.material-icons :font-size 0.6em))
	 (.backdrop
	  :z-index 100
	  :position absolute
	  (.material-icons :font-size 1em)
	  ;; :right -0.2em
	  ;; :top -0.2em
	  )
	 (div :display inline))))))))

(specify-css-styles
 css-text-view
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :basic
 (``((|#main|
      (.portal
       (.view
	(.main
	 (.branches
	  (.portal-column.text
	   (.text-pane-outer
	    :height 100%
	    (.reactcodemirror
	     :height "calc(100% - 30px)"
	     (.codemirror :height 100%
			  :|box-shadow| none
			  :background transparent))
	    ;;(.status-bar :height 30px)
	    ))

	  (.portal-column.document
	   (.document-pane-outer
	    :height 100%
	    (.slate-editor-pane
	     :height "calc(100% - 30px)"
	     :padding 4px 6px
	     :color "#002b36"
	     :font-size 16px
	     :letter-spacing 0.03em
	     (div.node-holder
	      (div.glyph :cursor pointer :height "calc(3px + 1em)" :width 16px :float left
			 :background "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='20' version='1.1'><g transform='translate(0,3)'><rect style='fill:%23839496;fill-opacity:1;stroke:none' x='0' y='0' width='2' height='15' /></g></svg>\") no-repeat")
	      (blockquote :font-size 1.2em
			  :margin 6px 0 6px 6px
			  :padding 6px 0 6px 18px
			  :border-left "4px solid #eee8d5")
	      ((:or ul ol) :margin 8px 0))
	     (div.node-holder.p (div.node :margin-left 16px))
	     ;; ((:and div :before)
	     ;;  :content "."
	     ;;  :padding-right 16px
	     ;;  :opacity 0
	     ;;  :cursor pointer
	     ;;  ;:background "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='12' version='1.1'><rect fill='%23eee8d5' x='0' y='21' width='100%' height='8px'/></svg>\")"
	     ;;  )
	     )
	    (.status-bar :height 30px)))

	  (.portal-column.html-element
	   (.html-display
	    :background "#fefefa"
	    :padding 12px
	    :font-family "Verdana"
	    (svg :height 100%
		 :width 100%)))
	  
	  )))))
     )))

(specify-css-styles
 css-symbol-style-camel-case
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :basic
 (``((.seed-symbol
      ((:and span :|not(:first-child)|)
       (.fl :text-transform uppercase))
      (span.leading (.fl :text-transform none))
      (span.divider :opacity 0.5)
      ((:and span.divider :before)
       :content ".")))))

(specify-css-styles
 css-symbol-style-dash-separated
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :basic
 (``((.seed-symbol
      ((:and span :|not(:first-child)|)
       ((:and .fl :before)
	:content "-"
	:opacity 0.75))
      (span.leading
       ((:and .fl :before)
	:display none))
      (span.divider :opacity 0.5)
      ((:and span.divider :before)
       :content ".")))))

(specify-css-styles
 css-symbol-style-underscore-separated
 (with (:palette-symbols base3 base2 base1 base0 base00 base01 base02 base03
			 yellow orange red magenta violet blue cyan green))
 :basic
 (``((.seed-symbol
      ((:and span :|not(:first-child)|)
       ((:and .fl :before)
	:content "_"
	:opacity 0.75))
      (span.leading
       ((:and .fl :before)
	:display none))
      (span.divider :opacity 0.5)
      ((:and span.divider :before)
       :content ".")))))

(defmacro point-casters (&rest plots)
  "Create the styles for the divs used to cast the scrolling multiple shadows."
  (loop :for index :from 0 :to (1- (length plots))
     append `((,(intern (format nil "#star-caster-~d" index))
	       :width ,(format nil "~dpx" (getf (nth index plots) :size))
	       :height ,(format nil "~dpx" (getf (nth index plots) :size))
	       :background transparent
	       :animation ,@(getf (nth index plots) :animation)
	       :|box-shadow| ,(getf (nth index plots) :plot))
	      ((:and ,(intern (format nil "#star-caster-~d" index))
		     :after)
	       :content " "
	       :position absolute
	       :right 2000px
	       :width ,(format nil "~dpx" (getf (nth index plots) :size))
	       :height ,(format nil "~dpx" (getf (nth index plots) :size))
	       :background transparent
	       :animation ,@(getf (nth index plots) :animation)
	       :|box-shadow| ,(getf (nth index plots) :plot)))))

(defmacro css-animation-silicon-sky ()
  "Plot a field of scrolling dots, some grouped into rectangular arrays."
  (flet ((scatter-stars (star-count &rest params)
	     (let ((mode-data nil)
		   (spread-points nil))
	       (labels ((plot-dots (count &optional output)
			  ;; plot dots, either randomly or in an array pattern
			  (if (< 0 count)
			      (let* ((gen-params (getf params :array))
				     (coords (if spread-points
						 (let ((pt (first spread-points)))
						   (setq spread-points (rest spread-points))
						   pt)
						 (list (funcall (getf params :x-range))
						       (funcall (getf params :y-range)))))
				     (current-mode (first mode-data)))
				(if gen-params
				    (if current-mode
					(cond ((eq :array (getf current-mode :mode))
					       (macrolet ((dims () `(getf current-mode :dims))
							  (origin () `(getf current-mode :origin))
							  (space () `(getf current-mode :space)))
						 (if (dims)
						     (setf coords (list (+ (first (origin))
									   (* (space) (first (dims))))
									(+ (second (origin))
									   (* (space) (1- (length (dims))))))
							   (dims) (if (= 0 (first (dims)))
								      (rest (dims))
								      (cons (1- (first (dims)))
									    (rest (dims)))))
						     (setf mode-data (rest mode-data))))))
					(if (funcall (getf gen-params :block-chance))
					    (let ((width (funcall (getf gen-params :block-width)))
						  (height (funcall (getf gen-params :block-height)))
						  (space (funcall (getf gen-params :block-space)))
						  (x-origin (funcall (getf params :x-range)))
						  (y-origin (funcall (getf params :y-range))))
					          ;; don't generate a block if there aren't enough points left 
					          ;; in the count to fill it completely
					      (if (> count (1+ (* width height)))
						  (setq mode-data
							(cons (list :mode :array
								    :space space
								    :dims (loop for n from 0 to height
									     collect width)
								    :origin (list x-origin y-origin))
							      mode-data)))))))
				(plot-dots (1- count)
					   (format nil "~a~dpx ~dpx #fff~a"
						   (if output output "")
						   (first coords)
						   (second coords)
						   (if (< 1 count)
						       ", " ""))))
			      output)))
	       (plot-dots star-count)))))
    `(quote ("
  @keyframes anim-sky1 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky2 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky3 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky4 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky5 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky6 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky7 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky8 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
  @keyframes anim-sky9 {
    from { transform: translateX(0px); }
    to { transform: translateX(-2000px); }}
"
      (.intro-animation
       :background "#6f7c91"
       :height 100%
       :width 100%
       :z-index -1000
       :position relative
       ;; :margin-left 16em
       :overflow hidden
       (.title :color "#fff"
	       :font-size 1.2em
	       :margin 0
	       :padding 4px 2px
	       :font-family monospace
	       :position absolute
	       :bottom 0
	       :left 4px
	       :text-align right)
       (.animation-inner
	:height 100%
	:width 100%
	:-moz-transform "scale(1, -1)"
	:-webkit-transform "scale(1, -1)"
	:-o-transform "scale(1, -1)"
	:-ms-transform "scale(1, -1)"
	:transform "scale(1, -1)"
	,@(macroexpand `(point-casters
			 (:plot
			  ,(scatter-stars 400 :x-range (lambda () (random 3000))
			 		  :y-range (lambda () (+ 60 (random 1000))))
			  :size 1
			  :animation (anim-sky1 320s linear infinite))
			 (:plot
			  ,(scatter-stars 60 :x-range (lambda () (random 3000))
			 		  :y-range (lambda () (+ 120 (random 1000))))
			  :size 2
			  :animation (anim-sky2 440s linear infinite))
			 (:plot
			  ,(scatter-stars 30 :x-range (lambda () (random 3000))
			 		  :y-range (lambda () (+ 200 (random 1000))))
			  :size 3
			  :animation (anim-sky3 680s linear infinite))
			 (:plot
			  ,(scatter-stars
			    1200 :x-range (lambda () (random 3000))
			    :y-range (lambda () (+ 20 (random 80) (random 120) (random 120)))
			    :array (list :block-width (lambda () (+ 3 (random 6) (random 6) (random 6)))
					 :block-height (lambda () (+ 2 (random 3) (random 6)))
					 :block-chance (lambda () (= 0 (+ (random 2))))
					 :block-space (lambda () (+ 4 (random 10) (random 3) (random 3)))))
			  :size 1
			  :animation (anim-sky4 220s linear infinite))
			 (:plot
			  ,(scatter-stars
			    250 :x-range (lambda () (random 3000))
			    :y-range (lambda () (+ 60 (random 40) (random 60) (random 200)))
			    :array (list :block-width (lambda () (+ 3 (random 3) (random 3) (random 3)))
			 		 :block-height (lambda () (+ 3 (random 3) (random 3)))
			 		 :block-chance (lambda () (= 0 (+ (random 2) (random 2))))
			 		 :block-space (lambda () (+ 10 (random 8) (random 8) (random 8)))))
			  :size 2
			  :animation (anim-sky5 340s linear infinite))
			 (:plot
			  ,(scatter-stars
			    95 :x-range (lambda () (random 3000))
			    :y-range (lambda () (+ 260 (random 600)))
			    :array (list :block-width (lambda () (+ 1 (random 2) (random 6)))
			 		 :block-height (lambda () (+ 1 (random 2) (random 4)))
			 		 :block-chance (lambda () (= 0 (+ (random 2) (random 2))))
			 		 :block-space (lambda () (+ 8 (random 10) (random 10) (random 10)))))
			  :size 3
			  :animation (anim-sky6 500s linear infinite))
			 (:plot
			  ,(scatter-stars
			    1200 :x-range (lambda () (random 3000))
			    :y-range (lambda () (+ 20 (random 80) (random 180) (random 180)))
			    :array (list :block-width (lambda () (+ 3 (random 6) (random 6) (random 6)))
					 :block-height (lambda () (+ 2 (random 3) (random 6)))
					 :block-chance (lambda () (= 0 (+ (random 2))))
					 :block-space (lambda () (+ 4 (random 10) (random 3) (random 3)))))
			  :size 1
			  :animation (anim-sky4 320s linear infinite))
			 (:plot
			  ,(scatter-stars
			    400 :x-range (lambda () (random 3000))
			    :y-range (lambda () (+ 200 (random 240) (random 240)))
			    :array (list :block-width (lambda () (+ 3 (random 12) (random 12)))
					 :block-height (lambda () (+ 2 (random 8) (random 8)))
					 :block-chance (lambda () (= 0 (+ (random 2))))
					 :block-space (lambda () (+ 4 (random 24) (random 3) (random 24)))))
			  :size 1
			  :animation (anim-sky8 800s linear infinite))
			 (:plot
			  ,(scatter-stars
			    50 :x-range (lambda () (random 3000))
			    :y-range (lambda () (+ 60 (random 160) (random 120) (random 160)))
			    :array (list :block-width (lambda () (+ 3 (random 4) (random 4) (random 8)))
					 :block-height (lambda () 0)
					 :block-chance (lambda () (= 0 (+ (random 2))))
					 :block-space (lambda () (+ 4 (random 24) (random 3) (random 24)))))
			  :size 2
			  :animation (anim-sky9 200s linear infinite))))))))))
