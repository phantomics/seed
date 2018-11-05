;;;; ui-model.css.lisp

(in-package #:seed.ui-model.css)

(defun replace-keys-in-form (to-find to-replace-with form)
  (loop for item in form collect
       (cond ((listp item)
	      (replace-keys-in-form to-find to-replace-with item))
	     ((and (keywordp item)
		   (find item to-find))
	      (nth (position item to-find)
		   to-replace-with))
	     (t item))))

(defmacro specify-css-styles (name params &key (by-palette nil) (basic nil))
  "Define (part of) a component set specification to be used in building a React interface."
  (let ((options (gensym)) (palette (gensym)) (palettes (gensym)) (palette-symbols (gensym))
	(palette-contexts (gensym)) (pal-data (gensym)))
    `(defmacro ,name (&optional ,options)
       (let* ((,palettes (rest (assoc :palettes ,options)))
	      (,palette-contexts (rest (assoc :palette-contexts ,options)))
	      (,palette-symbols '(,@(rest (assoc :palette-symbols (rest params))))))
	 `(append ,@,(if (not (null by-palette))
		  	 `(if ,palettes
		  	      (loop :for ,palette :in ,palettes :append
		  		 `((let* ((,',pal-data ,(second ,palette))
		  			  ,@(loop :for symbol :in ,palette-symbols
		  			       :collect (list symbol `(getf ,',pal-data
		  							    ,(intern (string-upcase symbol)
		  								     "KEYWORD")))))
		  		     (declare (ignorable ,@(loop :for symbol :in ,palette-symbols
		  					      :collect symbol)))
		  		     (list `((:or ,(intern (format nil ".PALETTE-~a" ,(first ,palette)))
		  				  ,@(loop :for symbol :in ',,palette-contexts
		  				       collect (intern (format nil ".PALETTE-~a.~a"
		  							       ,(first ,palette)
		  							       symbol))))
		  			     ,@,,@by-palette)))))))
		  ,,@basic)))))

;; (defmacro css-style-set (name options &rest components)
;;   `(let ,(loop for color in (getf options :palette)
;; 	    collect (list color `(getf ,)))))

(defmacro css-styles (options &rest styles)
  `(append ,@(loop for style in styles
		collect (macroexpand (if (listp style)
					 (list (first style)
					       (append (cdadr style)
						       (rest options)))
					 (list style (rest options)))))))

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
