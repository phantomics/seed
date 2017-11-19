;;;; modulate.lisp

(in-package #:seed.modulate)

(defun array-map (function &rest arrays)
  "Maps the function over the arrays. Assumes that all arrays are of the same dimensions. Returns a new result array of the same dimension."
  (flet ((make-displaced-array (array)
           (make-array (reduce #'* (array-dimensions array))
                       :displaced-to array)))
    (let* ((displaced-arrays (mapcar #'make-displaced-array arrays))
           (result-array (make-array (array-dimensions (first arrays))))
           (displaced-result-array (make-displaced-array result-array)))
      (declare (dynamic-extent displaced-arrays displaced-result-array))
      (apply #'map-into displaced-result-array function displaced-arrays)
      result-array)))

(defun array-coord-enum (ar &optional result-array coords)
  "Create an array with the same dimensions of the input array whose members are lists of numbers enumerating the coordinates of the input array's members."
  (let ((result-array (if result-array result-array
			  (make-array (array-dimensions ar)
				      :initial-element nil))))
    (if (< (length coords)
	   (length (array-dimensions ar)))
	(progn (loop for index from 0 to (1- (array-dimension ar (length coords)))
		  do (array-coord-enum ar result-array (append coords (list index))))
	       (if (not coords) result-array))
	(setf (apply #'aref (cons result-array coords))
	      coords))))

(defun list-dimensions (list depth)
  "Get the dimensions of a list."
  (loop repeat depth
        collect (length list)
        do (setf list (car list))))

(defun list-to-array (list depth)
  "Convert list to array."
  (make-array (list-dimensions list depth)
              :initial-contents list))

(defun array-to-list (array)
  "Convert array to list."
  (let* ((dimensions (array-dimensions array))
         (depth (1- (length dimensions)))
         (indices (make-list (1+ depth) :initial-element 0)))
    (labels ((recurse (n)
               (loop for j below (nth n dimensions)
		  do (setf (nth n indices) j)
		  collect (if (= n depth)
			      (apply #'aref array indices)
			      (recurse (1+ n))))))
      (recurse 0))))

(defun trace-symbol (sym package)
  (if (find-package package)
      (multiple-value-bind (symbol provenance)
	  (intern (string-upcase sym)
		  (package-name package))
	(if provenance (if (eq provenance :inherited)
			   (labels ((use-list-search (packages &optional output)
				      (if (or output (not packages))
					  output
					  (let ((symbol-list (let ((slist nil))
							       (do-external-symbols (sym (first packages))
								 (setq slist (cons sym slist)))
							       slist)))
					    (use-list-search (rest packages)
							     (if (find symbol symbol-list)
								 (first packages)))))))
			     (use-list-search (package-use-list package)))
			   package)))))

(defmacro create-meta ()
  nil)

(defmacro of-meta (property)
  `(getf meta ,property))

(defmacro of-properties (property properties)
  `(getf ,properties ,property))

;; (defmacro create-meta ()
;;   '(make-hash-table :test #'eq))

;; (defmacro of-meta (property)
;;   `(gethash ,property meta))

;; (defmacro of-properties (property properties)
;;   `(gethash ,property ,properties))

(defun encode (package-string form)
  "Top-level wrapper for encode process; initializes encoding metadata and passes code to encodeExpr function."
  (let ((meta (create-meta)))
    (setf (of-meta :package) package-string)
    (multiple-value-bind (form-out meta-out)
	(encode-expr form meta)
      (values (downcase-jsform form-out)
	      meta-out))))

(defun decode (input) 
  "Wrapper for decode function - the decoding process is less variable than the encoding process, so it's merely a formality."
  (decode-expr input))

(defun encode-expr (form &optional meta output)
  "Convert a given form to the display format."
  (let ((point (if (listp form) ; this condition should only go into effect when an atom is
		   (first form) ; passed directly from an output function
		   form))
	(meta (if meta meta (create-meta))))

    ; set initial element flag to true so that the atom heading a form can be correctly marked
    (if (not output)
	(setf (of-meta :initial) t))

    (if (or (and point (atom point)) ; if the point is an atom or nil
	    (and (not point) form))
	(multiple-value-bind (output-form output-meta)
	    (atom-to-jsform point meta)
	  (encode-expr (if (listp form) (rest form))
		       output-meta (append output (list (if (and (arrayp point)
								 (not (stringp point)))
							    (encode-array point)
							    output-form)))))
	(if point ; if the point is a non-nil list
	    (multiple-value-bind (result-output result-meta)
		; encodeExpr for processing forms, atomToJsform for processing forms converted to atoms
		(encode-form point #'encode-expr #'atom-to-jsform meta output)
	      (let ((new-meta result-meta))
		(if (and (not output)
			 (not (of-properties :enclosed result-meta)))
		    (setf (of-properties :to-enclose result-meta) t
			  (of-properties :enclosed new-meta) t))
		(encode-expr (rest form)
			     new-meta ; begin the list with a plain list object if the list is nested
			     ; the enclosed property marks whether or not the form has been enclosed
			     ; in its outermost list. Because of the way the indexing works, a special
			     ; provision is made to correctly number the outermost list with the 0 index. x
			     (append (if output output (list (atom-to-jsform (list :ty (list "plain"))
									     result-meta)))
				     (list result-output)))))
	    (progn (setf (of-meta :initial) nil)
		   ; strip away plain list header if the head of the list has an atom macro - i.e. if the first
		   ; element is not a true list but an atom with a macro applied - and if the head of the list
		   ; does _not_ have a form macro, meaning that it is also the head of a sub-form.
		   ; the double application is rare but occurs on the first element in a portal specification,
		   ; thus its quick discovery
		   (values (if (and (eq :ty (caar output))
				    (string= "plain" (caadar output))
				    (keywordp (caadr output))
				    (getf (second output) :am)
				    (not (getf (first output) :fm))
				    (not (getf (second output) :fm)))
			       ;(progn (print (list :mm meta))
				;      output)
			       (rest output)
			       output)
			   meta))))))

(defun encode-array (array &optional dims point output)
  "Convert a given array to the display format."
  (let ((point (if point point (list 0)))
	(dims (if dims dims (array-dimensions array))))
    (if (> (nth (1- (length point)) dims)
	   (first (last point)))
	(encode-array array dims
		      (append (butlast point)
			      (mapcar #'1+ (last point)))
		      (append output (if (> (length dims)
					    (length point))
					 (list (encode-array array dims (append point (list 0))))
					 (encode-expr (apply #'aref (cons array point))))))
	(if (> (length point) 1) ; prepend array information object if
	    output               ; this is the end of the array
	    (cons (list :ty (list "array")
			:dm dims)
		  output)))))

(defun decode-expr (form &optional output macros)
  "Convert a display-formatted form back to a standard Lisp form."
  (let ((point (first form)))
    (if (keywordp (first point)) ; if the point is a JSON object
	(let ((point-macros (if (getf point :fm)
				(append (getf point :fm) macros)
				macros)))
	  (if (string= "plain" (first (getf point :ty))) ; if this is the head of a plain list
	      (decode-expr (rest form)
			   output point-macros)
	      (if (string= "array" (first (getf point :ty)))
		  (list-to-array (rest form)
				 (1- (length (getf point :ty))))
		  (decode-expr (rest form)
			       (append output (list (decode-atom point)))
			       point-macros))))
	(if point
	    (multiple-value-bind (output-form returned-macros)
		(decode-expr point)
	      (decode-expr (rest form)
			   (append output (list (decode-form output-form returned-macros (first point))))
			   macros))
	    (values output macros)))))

(defun atom-to-jsform (obj meta)
  "Generates a JSON-convertible property list from a Lisp atom."
  (let* ((object (if (and (listp obj)
			  (keywordp (first obj)))
		     obj (encode-atom obj meta)))
	 (jsform (append (if (and (arrayp obj)
				 (not (stringp obj)))
			    (let ((base-ct (of-meta :ct))
				  (base-ly (of-meta :ly)))
			      (list :ty (list "array") ; *** TODO: array-handling needs much more work
				    :vl (array-map (lambda (member coords)
						     (list :vl (encode-expr member meta)
							   :ct (+ (if base-ct base-ct 0)
								  (first coords))
							   :ly (+ (if base-ly base-ly 0)
								  (if (second coords)
								      (second coords)
								      0))))
						   obj (array-coord-enum obj))))
			    object)
			(list :ix (let ((index (of-meta :ix))
					(enclosing nil))
				    (if (of-meta :to-enclose)
					(setf (of-meta :to-enclose) nil
					      (of-meta :enclosed) t
					      enclosing t))
				    (if enclosing 0 (setf (of-meta :ix) (if index (1+ index) 1))))))))

    (setf (getf jsform :ty)
	  ; prepend a form-describing type to the type list if this atom is at the start of a list
	  (append (if (of-meta :initial)
		      ; check that this is marked as the initial atom in the list
		      (progn (setf (of-meta :initial) nil)
			     ; the initial atom marker is now set to nil
			     (if (and (getf object :vl)
				      (of-meta :package)
				      (or (string= "symbol" (first (getf object :ty)))
					  (string= "keyword" (first (getf object :ty))))
				      ; check that value is not nil
				      ; also check that value is not blank
				      (not (= 0 (length (getf object :vl))))
				      (not (char= #\# (aref (getf object :vl) 0))))
				      ; the # character causes problems - TODO: a better way to do this?
				 (let ((sym (intern (string-upcase (getf object :vl))
						    (package-name (find-package (of-meta :package))))))
				   (list (if (string= "keyword" (first (getf object :ty)))
					     "form-keyword-list"
					     (if (macro-function sym)
						 "form-macro"
						 (if (fboundp sym)
						     "form-function" "form-list"))))))))
		  (getf object :ty)))

    (if (not (of-meta :glyphs))
	(setf (of-meta :glyphs)
	      (make-array 0 :adjustable t)))

    (setf (of-meta :glyphs)
	  (add-array-glyph (of-meta :glyphs)
			   (if (and (getf jsform :vl)
				    (stringp (getf jsform :vl)))
			       ; add the atom's value to the type list, if said value is a string, indicating
			       ; the atom is of type symbol, keyword or string
			       (cons (getf jsform :vl)
				     (getf jsform :ty))
			       (getf jsform :ty))
			   (getf jsform :ix)))
    (values jsform meta)))


(defun display-format-predicate (data)
  "This function tests whether a form is a piece of data encoded for frontend display. Currently, this is done by checking for the presence of a :ty property."
  (flet ((atom-form-test (datum)
	   (if (keywordp (first datum))
	       (let ((type-property (getf datum :ty)))
		 (and type-property (listp type-property))))))
    (if (listp (first data))
	(if (listp (caar data))
	    (atom-form-test (caar data))
	    (atom-form-test (first data))))))

(defun downcase-jsform (list &optional output)
  "Prepare a data structure for expression as JSON, preserving semantics including keywords and symbols."
  (if (and list (first list))
      (if (listp (first list))
	  (mapcar #'downcase-jsform list)
	  (if (keywordp (first list))
	      (downcase-jsform (cddr list)
			       (cons (intern (string-downcase (first list))
						   "KEYWORD")
				     (cons (second list)
					   output)))
	      list))
      output))

(defun preprocess-structure (list &optional output)
  "Prepare a data structure for expression as JSON, preserving semantics including keywords and symbols."
  (if (and list (first list))
      (if (listp (first list))
	  (mapcar #'preprocess-structure list)
	  (if (keywordp (first list))
	      (preprocess-structure (cddr list)
				    (append (list (intern (lisp->camel-case (first list))
							  "KEYWORD")
						  (cond ((or (eq :default (first list))
							     (eq :data (first list))
							     (eq :format (first list))
							     (eq :value (first list)))
							 (downcase-jsform (encode-expr (second list))))
							((eq t (second list))
							 t)
							; TODO: figure better heuristic for handling
							; nil/empty array conversion between Lisp and JSON
							((null (second list))
							 "_nil")
							((symbolp (second list))
							 (concatenate 'string
								      (if (keywordp (second list))
									  "__" "_")
								      (lisp->camel-case (second list))))
							((listp (second list))
							 (preprocess-structure (second list)))
							(t (second list))))
					    output))
	      list))
      output))

(defun postprocess-structure (list &optional output)
  "Prepare a data structure converted back from JSON, translating leading underscore strings back to symbols and more."
  (if (and list (first list))
      (if (listp (first list))
	  (mapcar #'postprocess-structure list)
	  (if (keywordp (first list))
	      (postprocess-structure (cddr list)
				     (append (list (first list)
						   (cond ((or (eq :default (first list))
							      (eq :data (first list))
							      (eq :format (first list))
							      (eq :value (first list)))
							      ; if the decoded expression is just an atom,
							      ; pull it out of the list it comes in,
							      ; otherwise pass the decoded expression back
							  (let ((decoded (decode-expr (second list))))
							    (if (and (= 1 (length decoded))
								     (atom (first decoded)))
								(first decoded)
								decoded)))
							 ((and (stringp (second list))
							       (< 0 (length (second list)))
							       (char= #\_ (aref (second list) 0)))
							       ; convert keywords and symbols according to
							       ; the leading underscores
							  (if (char= #\_ (aref (second list) 1))
							      (intern (string-upcase (camel-case->lisp-symbol
										      (subseq (second list) 2)))
								      "KEYWORD")
							      (intern (string-upcase (camel-case->lisp-symbol
										      (subseq (second list) 1))))))
							 ((listp (second list))
							  (postprocess-structure (second list)))
							 (t (second list))))
					     output))
	      list))
	  output))

(defmacro glyphs (&rest media)
  "Top-level wrapper for nested glyph specifications, whose function is simply to make the property list produced by the spec functions into the argument to the assignGlyphs macro."
  (cons 'assign-glyphs (macroexpand (labels ((nest (media-list &optional output)
					       (if media-list
						   (nest (rest media-list)
							 (cons (first media-list)
							       output))
						   output)))
				      (nest media)))))

(defmacro specify-glyphs (name &rest params)
  "Define (part of) the set of glyphs to represent Lisp symbols and datatypes."
  (let ((spec (gensym)) (join-plists (gensym)) (new (gensym)) (existing (gensym)))
    `(defmacro ,name (&optional ,spec)
       (labels ((,join-plists (,new ,existing)
		  (if ,new
		      (progn (if (eq :default (first ,new))
				 (setf (getf ,existing (first ,new))
				       (second ,new))
				 (setf (getf ,existing (first ,new))
				       (append (second ,new)
					       (getf ,existing (first ,new)))))
			     (,join-plists (cddr ,new)
					   ,existing))
		      ,existing)))
	 (if ,spec
	     (,join-plists (quote ,params)
			   (macroexpand ,spec))
	     (quote ,params))))))

(defmacro assign-glyphs (&rest categories)
  "Build the function used to assign glyphs to atoms by matching the atoms with specified heuristics."
  (labels ((process (segments &optional points seg-out points-out inverted-offset inverted-endpoint)
	     (if (or segments points)
		 (if points
		     (let ((point (first points)) (ratios (list 4/3 1)) (resolution 16))
		       (if (third point) ; if an inverted segment begins here
			   (process segments (rest points) seg-out points-out (first point) (rest point))
			   (if point
			       (process segments (rest points) seg-out
					(append points-out
						(list (funcall (lambda (pt)
								 (mapcar #'* 
									 (if inverted-offset (list 1 1) ratios)
									 pt))
							       (if inverted-offset
								   (list (+ inverted-offset (second point))
									 (+ (* (first ratios)
									       (first point))
									    (- resolution
									       (second inverted-endpoint)
									       inverted-offset)))
								   (list (first point)
									 (- resolution (second point)))))))
					inverted-offset inverted-endpoint)
			       (process segments (rest points) ; if point is nil, end inverted segment
					seg-out
					(append points-out 
						(if inverted-offset
						    (list (list (+ inverted-offset (first inverted-endpoint))
								(- (- resolution (second inverted-endpoint))
								   inverted-offset))
							  (list (first inverted-endpoint)
								(- resolution (second inverted-endpoint))))))))))
		     (process (rest segments) (first segments)
			      (append seg-out (if points-out (list points-out)))
			      nil inverted-offset inverted-endpoint))
		 (append seg-out (if points-out (list points-out))))))
    (let ((type-list (gensym)) (head (gensym)))
      `(defun glyph-find (,type-list)
	 (let ((,head (first ,type-list)))
	   (cond ,@(mapcar (lambda (entry)
			     (list (if (stringp (first entry))
				       `(equal ,head ,(first entry))
				       (first entry))
				   (cons 'quote (list (process (second entry))))))
			   (getf categories :type-is))
		 (,type-list (glyph-find (rest ,type-list)))
		 (t (quote ,(process (getf categories :default))))))))))

(defun plot-glyph (type-list)
  "Plot the points of a glyph."
  (labels ((place-points (points &optional placed)
	     (let ((point (first points)))
	       (if (not point)
		   placed
		   (place-points (rest points) ; TODO; is this still needed?
				 (append placed (list (list (first point)
							    (second point))))))))
	   (format-set (glyph-lines)
	     (mapcar (lambda (line) (place-points line))
		     glyph-lines)))
    (format-set (if (fboundp 'glyph-find)
		    (glyph-find type-list)))))

(defun add-array-glyph (glyph-array type-list index)
  "Add a glyph to the array of glyphs to index."
  (if (<= (first (array-dimensions glyph-array))
	  (1+ index))
      (setf glyph-array (adjust-array glyph-array
				      (list (1+ index))
				      :initial-element nil)))
  (setf (aref glyph-array index)
	(plot-glyph type-list))
  glyph-array)

(defmacro reflect (&key (atom nil) (form nil))
  `(progn ,@(if atom (macroexpand (cons 'set-atom-reflection
					(loop :for spec :in atom :append (macroexpand (list spec))))))
	  ,@(if form (macroexpand (cons 'set-form-reflection
				        (loop :for spec :in form :append (macroexpand (list spec))))))))

(defmacro specify-atom-reflection (name &rest params)
  "Define (part of) an atom reflection specification to determine the behavior of seed.modulate."
  `(defmacro ,name ()
     `(,@',params)))

(defmacro specify-form-reflection (name &rest params)
  "Define (part of) a form reflection specification to determine the behavior of seed.modulate."
  `(defmacro ,name ()
     `(,@',params)))

(defmacro set-atom-reflection (&rest entries)
  "Define encoding and decoding processes for individual atoms, according to their type and other qualities."
  (list `(defun encode-atom (item meta)
	   (cond ((eq item :seed-constant-blank) ; handle the blank symbol
		  (list :vl "" :ty (list "symbol")))
		 ,@(mapcar (lambda (entry) 
			     `((typep item (quote ,(getf (getf entry :predicate) :type-is)))
			       (let ((properties nil))
				 ,(if (getf entry :process)
				      (getf entry :process))
				 (append (if properties (list :pr properties))
					 (list :vl ,(getf entry :view)
					       ,@(if (getf entry :display)
						     (list :ti (getf entry :display)))
					       :ty (mapcar (lambda (item)
							     (if (symbolp item)
								 (string-downcase item)
								 item))
							   (cons (quote ,(getf (getf entry :predicate) :type-is))
								 ,(getf entry :type-extension))))))))
			   entries)))
	`(defun decode-atom (item)
	   (flet ((process (atom) atom))
	     (let ((type (getf item :ty))
		   (value (getf item :vl))
		   (macros (getf item :am)))
	       (cond ,@(append '(((not type) item))
			       (loop :for entry :in entries :append
				    (cond ((eq :type-is (first (getf entry :predicate)))
					   `(((string= (first type)
						       ,(string-downcase (getf (getf entry :predicate)
									       :type-is)))
					      ,(getf entry :eval))))
					  ((eq :enclosed-by (first (getf entry :predicate)))
					   (let ((symbols (getf (getf entry :predicate) :enclosed-by)))
					     (mapcar (lambda (symbol)
						       `((string= (first macros)
								  ,(string-downcase symbol))
							 (let ((new-item item))
							   (setf (getf new-item :am)
								 (rest (getf new-item :am)))
							   ,@(if (getf entry :decode)
								 (getf entry :decode)
								 `((list (quote ,symbol)
									 (decode-atom new-item)))))))
						     symbols)))))
			       '((t (progn (setf (getf item :ty) (rest type))
					   (decode-atom item)))))))))))

(defmacro set-form-reflection (&rest entries)
  "Define encoding and decoding methods for forms based on given heuristics. For example, certain macros, such as the quasiquote macros, may be encoded and decoded in unique ways."
  (let ((form-process (gensym)) (atom-process (gensym)) (meta (gensym))
	(output (gensym)) (macros (gensym)) (macro (gensym)))
    (list `(defun encode-form (form ,form-process ,atom-process ,meta ,output)
	     (setf (of-properties :length ,meta) ; get length of all forms to assign
		   (1- (length form)))
	     (cond ,@(append 
		      (loop :for entry :in entries :append
			   (append (cond ((eq :enclosed-by (first (getf entry :predicate)))
					  (let ((symbols (getf (getf entry :predicate) :enclosed-by)))
					    (mapcar (lambda (symbol)
						      `((and (symbolp (first form))
							     (string= (string-downcase (first form))
								      ,(string-downcase symbol)))
							(multiple-value-bind (result-output result-meta)
							    (if (and (second form)
								     (listp (second form)))
								(encode-form (second form) ,form-process 
									     ,atom-process ,meta ,output)
								(funcall ,atom-process (second form) ,meta))
							  ,@(if (getf entry :encode)
								(getf entry :encode)
								`((if (keywordp (first result-output))
								      (setf (getf result-output :am)
									    (cons ,(string-downcase symbol) 
										  (getf result-output :am)))
								      (setf (getf (first result-output) :fm)
									    (cons ,(string-downcase symbol) 
										  (getf (first result-output) 
											:fm))))))
							  (values result-output result-meta))))
						    symbols))))))
		      `((t (funcall ,form-process form ,meta))))))
	  `(defun decode-form (form ,macros original-form)
	     (let ((,macro (first ,macros)))
	       (if (not ,macros)
		   form 
		   (decode-form 
		    (cond ,@(append 
			     (loop :for entry :in entries :append
				(append (cond ((eq :enclosed-by (first (getf entry :predicate)))
					       (let ((symbols (getf (getf entry :predicate) :enclosed-by)))
						 (mapcar (lambda (symbol)
							   `((string= ,macro ,(string-downcase symbol))
							     ,@(if (getf entry :decode)
								   (getf entry :decode)
								   `((list (intern (string-upcase ,macro))
									   form)))))
							 symbols))))))
			     '((t form))))
		    (rest ,macros)
		    original-form)))))))

;; (defun decode-array (form dims &optional point output callback)
;;   (let ((point (if point point (list 0)))
;; 	(output (if output output (make-array dims :initial-element nil))))
;;     (flet ((to-next () (decode-array (rest form) dims
;; 				     (append (butlast point)
;; 					     (mapcar #'1+ (last point)))
;; 				     output callback)))
;;       (if (> (nth (1- (length point)) dims)
;; 	     (first (last point)))
;; 	  (if (= (length dims)
;; 		 (length point))
;; 	      (progn (setf (apply #'aref (cons output point))
;; 			   (first (decode-expr (list (first form)))))
;; 		     (to-next))
;; 	      (decode-array (first form) dims
;; 			    (append point (list 0))
;; 			    output #'to-next))
;; 	  (if callback (funcall callback)
;; 	      output)))))

