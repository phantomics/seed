;;;; ui-model.keys.lisp

(in-package #:seed.ui-model.keys)

(defmacro specify-key-ui (name &key (discrete nil) (navigational nil) (keymap nil))
  "Define (part of) a key ui specification."
  `(defmacro ,name ()
     (list ,@(mapcar (lambda (input) (list 'quote input))
		     (if discrete (mapcar (lambda (category)
					    (cons (first category)
						  (macroexpand (cons 'discrete-key-ui (rest category)))))
					  discrete)))
	   ,@(mapcar (lambda (input) (list 'quote input))
		     (if keymap (mapcar (lambda (category)
					  (cons (first category)
						(macroexpand (cons 'keymap-ui (rest category)))))
					keymap)))
	   ,@(mapcar (lambda (input) (list 'quote input))
		     (if navigational (mapcar (lambda (category)
						(cons (first category)
						      (macroexpand (cons 'nav-key-ui (rest category)))))
					      navigational))))))

(defmacro key-ui (name &rest ui-specs)
  "Build the complete keystroke UI specification object and assign it to a variable with the given name."
  `((setf ,name (create ,@(labels ((functionize (input &optional output)
					       (if input
						   (functionize (cddr input)
								(append (list (first input)
									      `(lambda (portal) ,(second input)))
									output))
						   output)))
				  (functionize (let ((output nil))
						 (mapcar (lambda (ui-spec)
							   (mapcar (lambda (ui-mode)
								     (setf (getf output (first ui-mode))
									   (append (cons 'list (rest ui-mode))
										   (rest (getf output 
											       (first ui-mode))))))
								   (macroexpand (list ui-spec))))
							 (reverse ui-specs))
						 output)))))))

(defmacro discrete-key-ui (&rest combos)
  "Build a discrete key UI specification from the given key combinations."
  (cons 'build-key-ui 
	;; if a list of keystrokes is given, create duplicate behavior for each keystroke
	(loop :for combo :in combos :append (if (listp (first combo))
						(mapcar (lambda (combo-element) (cons combo-element (rest combo)))
							(first combo))
						(list (cons (first combo)
							    (rest combo)))))))

(defmacro nav-key-ui (direction-aliases &rest combos)
  "Build a navigational key UI from the given combinations, combining one or more sets of directional keys
   with each given set of combos."
  (cons 'build-key-ui
	(loop :for combo :in combos :append
	   (loop :for sub-combo :in (mapcar (lambda (combo-element direction)
					      (mapcar (lambda (direction-alias)
					                ;; If the combo key string is empty, thus specifying the
					                ;; function of the dirrectional keys when pressed alone,
					                ;; make sure no extra space is added in the string
							(cons (concatenate 'string (first combo)
									   (if (< 0 (length (first combo)))
									       " " "")
									   (nth direction direction-alias))
							      combo-element))
						      direction-aliases))
					    (rest combo)
					    (loop :for direction :from 0 :to (1- (length (first direction-aliases)))
					       :collect direction))
	      append sub-combo))))

(defmacro keymap-ui (&rest combos)
  "Build a specification for a modified keymap."
  (cons 'build-keymap 
	;; if a list of keystrokes is given, create duplicate behavior for each keystroke
	(loop :for combo :in combos :append
	   (let* ((char-string (string-downcase (write-to-string (first combo))))
		  (input-string (if (= 1 (length char-string))
				    char-string (aref char-string 1))))
	     (append (if (second combo)
			 (list `(,input-string (portal-action insert-char char ,(string (second combo))))))
		     (if (third combo)
			 (list `(,(format nil "shift ~a" input-string)
				  (portal-action insert-char char ,(string (third combo))))))
		     (if (fourth combo)
			 (list `(,(format nil "ctrl ~a" input-string)
				  (portal-action insert-char char ,(string (fourth combo))))))
		     (if (fifth combo)
			 (list `(,(format nil "ctrl shift ~a" input-string)
				  (portal-action insert-char char ,(string (fifth combo)))))))))))

(defpsmacro portal-action (action-name &rest params)
  "This macro is used in key definition files to wrap portal actions in functions for use in response to key commands."
  `(lambda () (chain portal (act ,(lisp->camel-case action-name) (create ,@params)))))

(defmacro build-key-ui (&rest combos)
  "Format and generate a set of key UI parameters."
  (macrolet ((inp (sym)
	       `(intern (string-upcase (quote ,sym))
			(package-name *package*))))
    (mapcar (lambda (combo)
	      (let ((commands (if (listp (first combo))
				  (first combo)
				  (list (first combo))))
		    (options (rest combo)))
		;; set standard Keystroke options for the Seed key UI
		(if (not (getf options (inp is-exclusive)))
		    (setf (getf options (inp is-exclusive)) t))
		(if (not (getf options (inp prevent-default)))
		    (setf (getf options (inp prevent-default)) t))
		(append `(create keys ,(first combo))
			;; object properties must be converted to underscore_format to work with the
                        ;; Keystroke library
			(labels ((underscore (input &optional output)
				   (if input
				       (underscore (cddr input)
						   (append (list (symbol-munger:lisp->underscores (first input))
								 (second input))
							   output))
				       output)))
			  (underscore options)))))
	    combos)))

(defmacro build-keymap (&rest combos)
  (mapcar (lambda (combo) (append `(create keys ,(first combo)
					   "on_keyup" ,(second combo)
					   "is_exclusive" t "prevent_default" t)))
	  combos))
