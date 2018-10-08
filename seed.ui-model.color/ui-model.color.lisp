;;;; seed.ui-model.color.lisp

(in-package #:seed.ui-model.color)

(defvar *common-lab-palette-lightness-gradient* (list 15 20 45 50 60 65 92 97))

(defun lab-space-gradient (degrees a-origin b-origin a-terminal b-terminal)
  (let ((l-degrees *common-lab-palette-lightness-gradient*))
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
