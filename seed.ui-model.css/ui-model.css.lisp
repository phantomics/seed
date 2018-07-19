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

(defun palette-list (hex-list)
  (if (= 8 (length hex-list))
      (let ((keys (list :base03 :base02 :base01 :base00 :base0 :base1 :base2 :base3)))
	(loop for index from 0 to 7 append (list (nth index keys)
						 (concatenate 'string "#" (nth index hex-list)))))
      hex-list))

(defmacro setup-palette (palette-argument colors content)
  ``(let ,(loop for color in ,(cons 'list colors)
	     collect (list color `(getf ',palette-argument (intern (string-upcase color)
								  "KEYWORD"))))))

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
			      (loop :for ,palette :in ,palettes :append
				 `((let* ((,',pal-data ,(cons 'list (rest ,palette)))
					  ;;(pal-data ,(cons 'list (rest ,palette)))
					  ,@(loop :for symbol :in ,palette-symbols
					       :collect (list symbol `(getf ,',pal-data
									    ,(intern (string-upcase symbol)
										     "KEYWORD")))))
				     (declare (ignorable ,@(loop :for symbol :in ,palette-symbols
							      :collect symbol)))
				     (list `(,(intern (format nil ".PALETTE-~a" ,(first ,palette)))
					      ,@,,@by-palette)))))))
		  ,,@basic)))))

;; (defmacro css-style-set (name options &rest components)
;;   `(let ,(loop for color in (getf options :palette)
;; 	    collect (list color `(getf ,)))))

(defmacro css-styles (options &rest styles)
  `(append ,@(loop for style in styles
		collect (macroexpand (list style options)))))

;; (main-branch-styles (with :palettes ((:basic :base3 "#fff" :base2 "#ddd")
;; (:other :base3 "#ff0000" :base2 "#00ff00"))))

;; (hex-express (lab-palette (15 4 -10) (20 4 -10) (45 6 -2) (50 6 0) (60 6 2) (65 6 4) (92 8 12) (97 8 12)))

;; (specify-css-styles
;;  main-branch-styles
;;  (with :palette-symbols (base3 base2 base1 base0 base00 base01 base02 base03
;; 			       yellow orange red magenta violet blue cyan green))
;;  :by-palette
;;  (``(.branches
    
;;     ;; styles for the top-level branch display elements
;;     (.container 
;;      :width 100%
;;      :background "#fff"
;;      (.column-outer :padding-left 0
;;  		    :padding-right 4px)
;;      ((:and .column-outer :last-child) :padding-right 0)
     
;;      (.portal-column 
;;       :padding 0 2px 0 0
;;       (.header
;;        :position relative
;;        :color ,base2
;;        ;; :background "repeating-linear-gradient(0deg, #93a1a1, #93a1a1 2px, #073642 2px, #073642 40px)"
;;        :background "linear-gradient(0deg, #93a1a1 2px, #073642 2px)"
;;        :height 38px
;;        :font-family monospace
;;        :padding 0 6px
;;        :border-left "8px solid #D9D4C5"
;;        :border-right "8px solid #D9D4C5"
;;        (.locked-indicator
;;  	:float right
;;  	:font-weight bold
;;  	:color "#dc322f"))
;;       ))))
;;  :basic
;;  (``(.branches :position relative)))

#|
purple palette
(:adjunct :base03 "#242434" :base02 "#2F2F3F" :base01 "#73676E"
	  :base00 "#817477" :base0 "#9D8D8D" :base1 "#AC9A97"
	  :base2 "#F8E5D5" :base3 "#FFF3E2" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

faded
(hex-express (lab-palette (15 2 -4) (20 2 -4) (45 1 -3) (50 1 -3) (60 1 -3) (65 1 -3) (92 0 -2) (97 0 -2)))

more faded
(:adjunct :base03 "#26252B" :base02 "#313036" :base01 "#6E6969"
	  :base00 "#7B7676" :base0 "#968F8D" :base1 "#A39D9A"
	  :base2 "#EFE7E0" :base3 "#FCF3ED" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

brown faded
(hex-express (lab-palette (15 6 2) (20 6 2) (45 4 3) (50 4 3) (60 3 4) (65 3 4) (92 1 2) (97 1 2)))

(:adjunct :base03 "#2F2323" :base02 "#3A2D2E" :base01 "#736866"
	  :base00 "#807572" :base0 "#998F8A" :base1 "#A69C97"
	  :base2 "#ECE7E4" :base3 "#FAF6F3" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

gray through blue
(hex-express (lab-palette (15 0 0.6) (20 0 -2) (45 0 -4) (50 0 -8) (60 0 -8) (65 0 -4) (92 0 -2) (97 0 0.6)))

(:adjunct :base03 "#242628" :base02 "#2F3033" :base01 "#676B71"
	  :base00 "#707784" :base0 "#89919E" :base1 "#9A9EA5"
	  :base2 "#E6E8EC" :base3 "#F4F6FA" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

gray through brown
(hex-express (lab-palette (15 1 2) (20 1 2) (45 2 4) (50 4 8) (60 4 8) (65 2 4) (92 1 2) (97 1 2)))
(:BASE03 "#282523" :BASE02 "#33302D" :BASE01 "#716964" :BASE00 "#83746A" :BASE0
 "#9E8E83" :BASE1 "#A59C97" :BASE2 "#ECE7E4" :BASE3 "#FAF6F3")
- more gray at ends
(hex-express (lab-palette (15 0.16 0.6) (20 1 2) (45 2 4) (50 4 8) (60 4 8) (65 2 4) (92 1 2) (97 0.16 0.6)))
(:BASE03 "#262625" :BASE02 "#33302D" :BASE01 "#716964" :BASE00 "#83746A" :BASE0
 "#9E8E83" :BASE1 "#A59C97" :BASE2 "#ECE7E4" :BASE3 "#F7F6F5")


orange peak
(hex-express (lab-palette (15 8 4) (20 8 4) (45 24 16) (50 50 50) (60 50 50) (65 16 24) (92 0 2) (97 0 2)))

orange peak to cinnamon
(hex-express (lab-palette (15 12 6) (20 12 6) (45 24 16) (50 50 50) (60 50 50) (65 16 24) (92 0 2) (97 0 2)))


50% hues
(:yellow "#AB8C58" :orange "#AA654A" :red "#B26053" :magenta "#A9627C"
	 :violet "#6E759C" :blue "#5F88A9" :cyan "#699995" :green "#939457")

75% hues
(:yellow "#B38A39" :orange "#BD5A34" :red "#C94F42" :magenta "#BE527E"
	 :violet "#6874AF" :blue "#408ABC" :cyan "#509D95" :green "#919637")

|#
