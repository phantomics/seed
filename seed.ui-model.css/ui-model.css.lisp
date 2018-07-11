;;;; ui-model.css.lisp

(in-package #:seed.ui-model.css)

;; (defmacro with-css-palettes (&rest specs)
;;   (labels ((join-spec (spec &optional output)
;; 	     (if (not spec)
;; 		 output
;; 		 (if (and (listp spec)
;; 			  (string= "PALETTE" (string-upcase (first spec))))
;; 		     (join-spec (rest specs)
;; 				`(let ))))))
;;     (join-spec specs)))

(defun replace-keys-in-form (to-find to-replace-with form)
  (loop for item in form collect
       (cond ((listp item)
	      (replace-keys-in-form to-find to-replace-with item))
	     ((and (keywordp item)
		   (find item to-find))
	      (nth (position item to-find)
		   to-replace-with))
	     (t item))))

(defmacro css-specs (&key (palettes nil) (templates nil))
  (let ((palette-keys (list :base03 :base02 :base01 :base00 :base0 :base1 :base2 :base3
			    :yellow :orange :red :magenta :violet :blue :cyan :green))))
  (loop for palette in palettes collect
       (loop for template in templates collect `(replace-keys-in-form palette-keys palette template))))

(defun lab-space-gradient (degrees a-origin b-origin a-terminal b-terminal)
  (let ((l-degrees (list 15 20 45 50 60 65 92 97)))
    (loop for index from 0 to (1- degrees)
       collect (let ((l (nth index l-degrees))
		     (a (if (< index 2)
			    a-origin (if (> index (- degrees 2))
					 a-terminal (floor (* (- a-origin a-terminal)
							      (/ degrees index))))))
		     (b (if (< index 2)
			    b-origin (if (> index (- degrees 2))
					 b-terminal (floor (* (- b-origin b-terminal)
							      (/ degrees index)))))))
		 (multiple-value-bind (r g b)
		     (multiple-value-call #'dufy:xyz-to-qrgb (dufy:lab-to-xyz l a b))
		   (format nil "~2,'0x~2,'0x~2,'0x" r g b))))))

(defmacro lab-palette (&rest colors)
  `(list ,@(loop for color in colors collect
		`(multiple-value-bind (r g b)
		     (multiple-value-call #'dufy:xyz-to-qrgb (dufy:lab-to-xyz ,@color))
		   (list r g b)))))

(defun hex-express (color-list)
  (flet ((hex-convert (r g b) (format nil "~2,'0x~2,'0x~2,'0x" r g b)))
    (if (listp (first color-list))
	(loop for color in color-list collect (apply #'hex-convert color))
	(apply #'hex-convert color-list))))

(defmacro setup-palette (palette-argument colors content)
  ``(let ,(loop for color in ,(cons 'list colors)
	     collect (list color `(getf ',palette-argument (intern (string-upcase color)
								  "KEYWORD"))))))

;; (defmacro setup-style (palette content)
;;   `(let ,(loop for color in palette
;; 	    collect (list (intern (string-upcase (first color))
;; 				  (package-name *package*))
;; 			  (rest color)))
;;      ,(macroexpand content)))

(defmacro specify-css-styles (name params &key (by-palette nil) (basic nil))
  "Define (part of) a component set specification to be used in building a React interface."
  (let ((options (gensym)) (palette (gensym)) (palettes (gensym)) (palette-symbols (gensym))
	(pal-data (gensym)))
    `(defmacro ,name (&optional ,options)
       (let* ((,options (rest ,options))
	      (,palettes (getf ,options :palettes))
	      (,palette-symbols '(,@(getf (rest params) :palette-symbols))))
	 `(append ,@,(if (not (null by-palette))
			 `(if ,palettes
			      (loop :for ,palette :in ,palettes :collect
				 `(let* ((,',pal-data ,(cons 'list (rest ,palette)))
					 ;;(pal-data ,(cons 'list (rest ,palette)))
					 ,@(loop :for symbol :in ,palette-symbols
					      :collect (list symbol `(getf ,',pal-data
									   ,(intern (string-upcase symbol)
										    "KEYWORD")))))
				    (list `(,(intern (format nil ".PALETTE-~a" ,(first ,palette)))
					     ,@,,@by-palette))))))
		  ,,@basic)))))

;; (defmacro css-style-set (name options &rest components)
;;   `(let ,(loop for color in (getf options :palette)
;; 	    collect (list color `(getf ,)))))

(defmacro css-styles (options &rest styles)
  (loop for style in styles
     collect (macroexpand (list style options))))

;; (main-branch-styles (with :palettes ((:basic :base3 "#fff" :base2 "#ddd")
;; (:other :base3 "#ff0000" :base2 "#00ff00"))))

;; (lab-palette (15 4 -10) (20 4 -10) (45 6 -2) (50 6 0) (60 6 2) (65 6 4) (92 8 12) (97 8 12))

(specify-css-styles
 main-branch-styles
 (with :palette-symbols (base3 base2 base1 base0 base00 base01 base02 base03
			       yellow orange red magenta violet blue cyan green))
 :by-palette
 (``(.branches
    
    ;; styles for the top-level branch display elements
    (.container 
     :width 100%
     :background "#fff"
     (.column-outer :padding-left 0
 		    :padding-right 4px)
     ((:and .column-outer :last-child) :padding-right 0)
     
     (.portal-column 
      :padding 0 2px 0 0
      (.header
       :position relative
       :color ,base2
       ;; :background "repeating-linear-gradient(0deg, #93a1a1, #93a1a1 2px, #073642 2px, #073642 40px)"
       :background "linear-gradient(0deg, #93a1a1 2px, #073642 2px)"
       :height 38px
       :font-family monospace
       :padding 0 6px
       :border-left "8px solid #D9D4C5"
       :border-right "8px solid #D9D4C5"
       (.locked-indicator
 	:float right
 	:font-weight bold
 	:color "#dc322f"))
      ))))
 :basic
 (``(.branches :position relative)))


#|
   
   (span.id
    :font-size 1.25em
    :line-height 48px)

   (.header.point
    :color "#fdf6e3"))

  ((:or .portal-column.form .portal-column.spreadsheet)
   (.pane :padding-right 2px))
  
  (.row 
   ((:and .vista :last-child)
    (.portal-column :padding 0))))

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
    (div.node-holder
     (div.glyph :cursor pointer :height "calc(3px + 1em)" :width 16px :float left
		:background "url(\"data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='12' height='20' version='1.1'><g transform='translate(0,3)'><rect style='fill:%23839496;fill-opacity:1;stroke:none' x='0' y='0' width='2' height='15' /></g></svg>\") no-repeat")
     (blockquote :font-size 1.2em
		 :margin 6px 0 6px 6px
		 :padding 6px 0 6px 18px
		 :border-left "4px solid #eee8d5")
     ((:or ul ol) :margin 8px 0))
    (div.node-holder.p (div.node :margin-left 16px)))
   (.status-bar :height 30px)))

 (.portal-column.html-element
  (|.branch-0-page|
   (.html-display
    :background "#fefefa"
    :padding 12px
    :font-family "Verdana")))
 )
|#
