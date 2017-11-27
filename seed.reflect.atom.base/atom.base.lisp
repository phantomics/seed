;;;; atom.base.lisp

(in-package #:seed.modulate)

(defun subdivide-for-display (symbol)
  "Divide a symbol's textual representation into major segments, delineated by periods, and minor segments, delineated by dashes."
  (cond ((string= "-" symbol)
	 '(("-")))
	((string= "." symbol)
	 '((".")))
	(t (mapcar (lambda (substring) (split-sequence #\- substring)) 
		   (split-sequence #\. symbol)))))

(specify-atom-reflection
 reflect-atom-base
 (:predicate
  (:enclosed-by (meta))
  :decode ((cons (intern "META")
		 (cons (decode-atom new-item)
		       (postprocess-structure (getf item :mt))))))
 (:predicate
  (:enclosed-by (quote quasiquote unquote unquote-splicing)))
 (:predicate
  (:type-is string)
  :type-extension (type-of item)
  :view (regex-replace-all "~~" item "~")
  :eval (process (regex-replace-all "~" value "~~")))
 (:predicate
  (:type-is character)
  :type-extension (list (type-of item))
  :view (concatenate 'string (list item))
  :eval (process (aref value 0)))
 (:predicate
  (:type-is nil)
  :view (if item "t" "nil")
  :eval (process (equal "t" value)))
 (:predicate
  (:type-is number)
  :type-extension (let ((type (type-of item)))
		    (if (listp type)
			type (list type)))
  ;; if the type-of function returns a single atom (not a list), push that atom onto an empty list 
  ;; so it can be appended
  :view (write-to-string item)
  :eval (process (parse-number value)))
 (:predicate
  (:type-is keyword)
  :view (string-downcase item)
  :eval (process (intern (string-upcase value) "KEYWORD"))
  :display (subdivide-for-display (string-downcase item)))
 (:predicate
  (:type-is symbol)
  :view (string-downcase item)
  :eval (if (or (null value)
		(string= value ""))
	    (process :seed-constant-blank)
	    (process (read-from-string value)))
  :display (subdivide-for-display (string-downcase item))
  :process (let ((origin (trace-symbol item (of-meta :package))))
	     (if (and origin (symbolp item))
		 (setf (getf properties :|pkg|)
		       (string-downcase (package-name origin))
		       (getf properties :|pkd|)
		       (subdivide-for-display (string-downcase (package-name origin))))))))
