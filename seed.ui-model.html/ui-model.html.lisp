;;;; ui-model.html.lisp

(in-package #:seed.ui-model.html)

(defmacro browser-interface (&rest params)
  "Top-level macro to generate a browser interface."
  (let ((foundation (rest (assoc :foundation params)))
	(markup (rest (assoc :markup params)))
	(script (rest (assoc :script params)))
	(style (rest (assoc :style params))))
    `(progn ,@(if foundation (list (macroexpand (cons 'dig-foundation foundation))))
	    ,@(if markup (list (macroexpand (cons 'build-browser-markup markup))))
	    ,@(if script (list (macroexpand (cons 'build-browser-script script))))
	    ,@(if style (list (macroexpand (cons 'build-browser-style style)))))))

(defmacro dig-foundation (&rest args)
  (let* ((stream (gensym)) (infile (gensym)) (outfile (gensym)) (line (gensym))
	 (scripts (rest (assoc :scripts args)))
	 (styles (rest (assoc :styles args)))
	 (local-package-name (intern (package-name *package*) "KEYWORD"))
	 (output-script-path (asdf:system-relative-pathname local-package-name "./main.js"))
	 (output-style-path (asdf:system-relative-pathname local-package-name "./main.css"))
	 (output-style-assets-path (asdf:system-relative-pathname local-package-name "./style-assets"))
	 ;; check for the presence of an nvm-based Node.js installation
	 (nvm-found (and (probe-file "~/.nvm")
			 (probe-file "~/.nvm/nvm.sh")))
	 ;; if nvm is present, this prefix must come before the invocation of Node build commands
	 (nvm-prefix "export NVM_DIR=$HOME/.nvm && [ -s \"$NVM_DIR/nvm.sh\" ] && . $NVM_DIR/nvm.sh && "))
    `(qualify-build
      ((defun ,(intern "FOUND-INTERFACE" (package-name *package*)) ()
	 ,(if scripts `(princ ,(format nil "~%Generating foundational Javascript via Gulp and Webpack.~%")))
	 ,@(loop for script in scripts
	      append (let* ((script-package-name (intern (package-name
							  (trace-symbol script (package-name *package*)))
							 "KEYWORD"))
			    (script-path (asdf:system-relative-pathname script-package-name "./"))
			    (output-path script-path)
			    (script-build-file (asdf:system-relative-pathname script-package-name "./gulpfile.js"))
			    (root-script (asdf:system-relative-pathname script-package-name "./src.js"))
			    (script-output-filename "main"))
		       (flet ((gulp-build-script ()
				(if script `((chain gulp (src ,(namestring root-script))
						    (pipe (gulp-webpack webpack-config))
						    (pipe (chain gulp (dest ,(namestring output-path)))))))))
			 `((with-open-file (,stream ,(namestring script-build-file)
						    :direction :output :if-exists :supersede :if-does-not-exist :create)
			     (format ,stream (ps (let ((gulp (require "gulp"))
						       (webpack (require "webpack"))
						       (gulp-webpack (require "gulp-webpack"))
						       (webpack-config (create context ,(namestring script-path)
									       entry (create ,script-output-filename "./src.js")
									       resolve (create extensions (list "" ".js" ".json"))
									       node (create fs "empty" child_process "empty")
									       ;; the above needed to prevent these modules
									       ;; causing errors when they cannot be loaded
									       ;; for client-side JS
									       output (create filename "./[name].js")
									       module
									       (create loaders
										       (list (create test (regex "\.json$")
												     loaders
												     (list "json-loader")))))))
						   (chain gulp (task "dev" (lambda () ,@(gulp-build-script))))))))
			   ;; invoke cornerstone macro from script package to create root source file
			   (with-open-file (,stream ,(namestring root-script)
						    :direction :output :if-exists :supersede 
						    :if-does-not-exist :create)
			     (format ,stream (macroexpand (list ',script))))
			   ,@(if script-path (list `(princ
						     ,(format nil "~%Synchronizing source files for Javascript generation.~%"))
						   (macroexpand (list 'synchronize-npm-modules script-path
								      (if nvm-found nvm-prefix "")))))
			   ;; run Gulp build process
			   (uiop:run-program ,(format nil "~agulp --gulpfile ~agulpfile.js dev"
						      (if nvm-found nvm-prefix "")
						      (namestring script-path))
					     :output *standard-output*)
			   (delete-file ,script-build-file)
			   (delete-file ,root-script)))))
	 (if (probe-file ,output-script-path)
	     (delete-file ,output-script-path))
	 (with-open-file (,outfile ,output-script-path :direction :output :if-exists :append
				   :if-does-not-exist :create)
	   ,@(loop for script in scripts
		append (let* ((script-package-name (intern (package-name
							    (trace-symbol script (package-name *package*)))
							   "KEYWORD"))
			      (root-script (asdf:system-relative-pathname script-package-name "./main.js")))
			 `((with-open-file (,infile ,root-script)
			     (loop :for ,line := (read-line ,infile nil)
				:while ,line :do (format ,outfile "~a~%" ,line)))
			   (delete-file ,root-script)))))
	 ,(if styles `(princ ,(format nil "~%Generating CSS via Gulp and Webpack.~%")))
	 ,@(loop for style in styles
	      append (let* ((style-package-name (intern (package-name
							 (trace-symbol style (package-name *package*)))
							"KEYWORD"))
			    (style-path (asdf:system-relative-pathname style-package-name "./"))
			    (style-assets-path (asdf:system-relative-pathname style-package-name
									      "./style-assets"))
			    (output-path style-path)
			    (style-build-file (asdf:system-relative-pathname style-package-name "./gulpfile.js"))
			    (style-output-filename "main"))
		       (flet ((gulp-build-style ()
				(if style `((chain gulp
						   (src (list ,@(mapcar #'namestring
									(macroexpand (list style)))))
						   (pipe (concat ,(format nil "~a.css" style-output-filename)))
						   (pipe (chain gulp (dest ,(namestring output-path)))))))))
			 `((with-open-file (,stream ,(namestring style-build-file)
						    :direction :output :if-exists :supersede
						    :if-does-not-exist :create)
			     (format ,stream (ps (let ((gulp (require "gulp"))
						       (concat (require "gulp-concat")))
						   (chain gulp (task "dev" (lambda () ,@(gulp-build-style))))))))
			   ,@(if (probe-file (asdf:system-relative-pathname style-package-name "./style-assets"))
				 (list `(if (not (probe-file ,output-style-assets-path))
					    (uiop:run-program ,(format nil "mkdir ~a" output-style-assets-path)
							      :output *standard-output*))
				       `(uiop:run-program ,(format nil "cp -rfH ~a/* ~a" style-assets-path
								   output-style-assets-path))))
			   ,@(if style-path
				 (list `(princ ,(format nil "~%Synchronizing source files for CSS generation.~%"))
				       (macroexpand (list 'synchronize-npm-modules style-path
							  (if nvm-found nvm-prefix "")))))
			   ;; run Gulp build process
			   (uiop:run-program ,(format nil "~agulp --gulpfile ~agulpfile.js dev"
						      (if nvm-found nvm-prefix "")
						      (namestring style-path))
					     :output *standard-output*)
			   ;; erase gulpfile and root Javascript source file when done
			   (delete-file ,style-build-file)))))
	 (with-open-file (,outfile ,output-style-path :direction :output :if-exists :append
				   :if-does-not-exist :create)
	   ,@(loop for style in styles
		append (let* ((style-package-name (intern (package-name
							   (trace-symbol style (package-name *package*)))
							  "KEYWORD"))
			      (root-style (asdf:system-relative-pathname style-package-name "./main.css")))
			 `((with-open-file (,infile ,root-style)
			     (loop :for ,line := (read-line ,infile nil)
				:while ,line :do (format ,outfile "~a~%" ,line)))
			   (delete-file ,root-style)))))
	 ,(if (and scripts styles)
	      `(progn (princ ,(format nil "~%Browser interface foundation build complete.~%~%"))
		      :success)))
       (if (and (fboundp (quote ,(intern "FOUND-INTERFACE" (package-name *package*))))
		(or (not (probe-file ,output-script-path))
		    ;; (not (probe-file ,style-output-path))
		    ))
	   ,(list (intern "FOUND-INTERFACE" (package-name *package*)))))
      ("Foundation provisioning failed."))))

(defmacro synchronize-npm-modules (script-path &optional prefix)
  "Installs and/or updates required NPM modules in a Javascript package."
  (let ((prefix (if prefix prefix "")))
    `(progn (princ "Processing NPM modules... ")
	    (uiop:run-program ,(format nil "~anpm install --prefix \"~a\"" prefix (namestring script-path)))
	    (princ ,(format nil "done.~%")))))

(defmacro build-browser-markup (&rest form)
  "Render interface HTML to file. Assumes a flat structure for file storage; the portal directory is assumed to be one directory upstream from the current package directory."
  `(with-open-file (stream ,(asdf:system-relative-pathname (make-symbol (package-name *package*))
							   "index.html")
			   :direction :output :if-exists :supersede :if-does-not-exist :create)
     (cl-who:with-html-output (stream) (:html ,@form))))

(defmacro build-browser-script (&rest items)
  "Render interface JavaScript to file."
  (let ((script-content nil) (prepend-content nil))
    (loop :for item :in items :do (let ((expanded (macroexpand (if (listp item)
								   item (list item)))))
				    (if (keywordp (first expanded))
					(setf script-content (append (getf expanded :content)
								     script-content)
					      prepend-content (append (getf expanded :prepend)
								      prepend-content))
					(setf script-content (append expanded script-content)))))
    `(with-open-file (stream (asdf:system-relative-pathname (make-symbol (package-name *package*))
							    "portal.js")
			     :direction :output :if-exists :supersede :if-does-not-exist :create)
       ,@prepend-content
       (let ((data (ps ,@script-content)))
	 (format stream (if (stringp data)
			    data (write-to-string data)))))))

(defmacro build-browser-style (&rest items)
  "Render interface CSS to file."
  `(with-open-file (stream (asdf:system-relative-pathname (make-symbol (package-name *package*))
							  "portal.css")
			   :direction :output :if-exists :supersede :if-does-not-exist :create)
     (let ((data (apply #'concatenate
			(cons 'string (mapcar (lambda (item)
						(if (listp item)
						    (lass:compile-and-write item)
						    (if (stringp item)
							item)))
					      (append ,@(loop :for item :in items
							   :collect (macroexpand (if (listp item)
										     item (list item))))))))))
       (format stream (if (stringp data)
       			  data (write-to-string data))))))

(defmacro html-stream-to-string (form)
  "Render HTML to string."
  `(let ((stream (make-string-output-stream)))
     (cl-who:with-html-output (stream) (:html ,@form))
     (get-output-stream-string stream)))
