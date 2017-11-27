;;;; ui-model.html.lisp

(in-package #:seed.ui-model.html)

(defmacro browser-interface (&key (foundation nil) (markup nil) (script nil) (style nil))
  "Top-level macro to generate a browser interface."
  `(progn ,@(if foundation (list (macroexpand (cons 'dig-foundation foundation))))
	  ,@(if markup (list (macroexpand (cons 'build-browser-markup markup))))
	  ,@(if script (list (macroexpand (cons 'build-browser-script script))))
	  ,@(if style (list (macroexpand (cons 'build-browser-style style))))))

(defmacro dig-foundation (&key (script nil) (style nil))
  "Compiles JavaScript and CSS to create the foundation for a Seed portal interface. Because this is time-consuming, it is only done by default if the main.js and main.css files are not present in the portal's package directory. If they are present, a rebuild of the JS and CSS can be done by evaluating the function foundInterface, which is declared in this macro."
  (let* ((script-package-name (if script (intern (string-upcase (first script)) "KEYWORD")))
	 (style-package-name (if style (intern (string-upcase (first style)) "KEYWORD")))
	 (local-package-name (intern (package-name *package*) "KEYWORD"))
	 (script-path (if script (asdf:system-relative-pathname script-package-name "./")))
	 (style-path (if style (asdf:system-relative-pathname style-package-name "./")))
	 (output-path (asdf:system-relative-pathname local-package-name "./"))
	 (script-build-file (if script (asdf:system-relative-pathname script-package-name "./gulpfile.js")))
	 (style-build-file (if script (asdf:system-relative-pathname style-package-name "./gulpfile.js")))
	 (root-script (if script (asdf:system-relative-pathname script-package-name "./src.js")))
	 (script-output-filename "main")
	 (script-output-path (format nil "~a/~a.js" output-path script-output-filename))
	 (style-output-filename "main")
	 (style-output-path (format nil "~a/~a.js" output-path style-output-filename))
	 (stream (gensym)))
    (flet ((gulp-build-script ()
	     (if script `((chain gulp (src ,(namestring root-script))
				 (pipe (gulp-webpack webpack-config))
				 (pipe (chain gulp (dest ,(namestring output-path))))))))
	   (gulp-build-style ()
	     (if style `((chain gulp (src (list ,@(mapcar #'namestring
							  (macroexpand `(,(intern "CORNERSTONE"
										  (string-upcase
										   (first style))))))))
				(pipe (concat ,(format nil "~a.css" style-output-filename)))
				(pipe (chain gulp (dest ,(namestring output-path)))))))))
      `(qualify-build
	 ((defun ,(intern "FOUND-INTERFACE" (package-name *package*)) ()
	    (with-open-file (,stream ,(namestring script-build-file)
				     :direction :output :if-exists :supersede :if-does-not-exist :create)
	      (format ,stream (ps (let ((gulp (require "gulp"))
					(webpack (require "webpack"))
					(gulp-webpack (require "gulp-webpack"))
					(webpack-config (create context ,(namestring script-path)
								entry (create ,script-output-filename
									      "./src.js")
								resolve (create extensions (list "" ".js"))
								output (create filename "./[name].js"))))
				    (chain gulp (task "dev" (lambda () ,@(gulp-build-script))))))))
				    ;; invoke cornerstone macro from script package to create root source file
	    ,(if script `(with-open-file (,stream ,(namestring root-script)
						  :direction :output :if-exists :supersede 
						  :if-does-not-exist :create)
			   (format ,stream (macroexpand (list (quote ,(intern "CORNERSTONE"
									      (string-upcase (first script)))))))))
	    ,@(if script-path (list `(princ
				      ,(format nil "~%Synchronizing source files for Javascript generation.~%"))
				    (macroexpand (list 'synchronize-npm-modules script-path))))
	    (princ ,(format nil "~%Generating foundational Javascript via Gulp and Webpack.~%"))
	    ;; run Gulp build process
	    (uiop:run-program ,(format nil "gulp --gulpfile ~agulpfile.js dev" (namestring script-path))
			      :output *standard-output*)
	                      ;; invoke cornerstone macro from style package to save compiled style file
			      ;; TODO: reenable once character format issue with bootstrap CSS files is figured out
	    (delete-file ,script-build-file)
	    (delete-file ,root-script)

	    (with-open-file (,stream ,(namestring style-build-file)
	    			     :direction :output :if-exists :supersede :if-does-not-exist :create)
	      (format ,stream (ps (let ((gulp (require "gulp"))
	    				(concat (require "gulp-concat")))
	    			    (chain gulp (task "dev" (lambda () ,@(gulp-build-style))))))))
	    ,@(if style-path (list `(princ ,(format nil "~%Synchronizing source files for CSS generation.~%"))
				   (macroexpand (list 'synchronize-npm-modules style-path))))
	    (princ ,(format nil "~%Generating CSS via Gulp and Webpack.~%"))
	    ;; run Gulp build process
	    (uiop:run-program ,(format nil "gulp --gulpfile ~agulpfile.js dev" (namestring style-path))
			      :output *standard-output*)
	    ;; erase gulpfile and root Javascript source file when done
	    (delete-file ,style-build-file)
	    
	    (princ ,(format nil "~%Browser interface foundation build complete.~%~%")))

	  ;; automatically invoke foundInterface if the interface files are not present
	  (if (and (fboundp (quote ,(intern "FOUND-INTERFACE" (package-name *package*))))
		   (or (not (probe-file ,script-output-path))
		       (not (probe-file ,style-output-path))))
	      ,(list (intern "FOUND-INTERFACE" (package-name *package*)))))
	 ("Foundation provisioning failed.")))))

(defmacro synchronize-npm-modules (script-path)
  "Installs and/or updates required NPM modules in a Javascript package."
  `(progn (princ "Processing NPM modules... ")
	  (uiop:run-program ,(format nil "npm install --prefix \"~a\"" (namestring script-path)))
	  (princ ,(format nil "done.~%"))))

(defmacro build-browser-markup (&rest form)
  "Render interface HTML to file. Assumes a flat structure for file storage; the portal directory is assumed to be one directory upstream from the current package directory."
  `(with-open-file (stream ,(asdf:system-relative-pathname (make-symbol (package-name *package*))
							   "index.html")
			   :direction :output :if-exists :supersede :if-does-not-exist :create)
     (cl-who:with-html-output (stream) (:html ,@form))))

(defmacro build-browser-script (&rest items)
  "Render interface JavaScript to file."
  `(with-open-file (stream (asdf:system-relative-pathname (make-symbol (package-name *package*))
							  "portal.js")
			   :direction :output :if-exists :supersede :if-does-not-exist :create)
     (let ((data (ps ,@(loop :for item :in items :append (macroexpand (if (listp item)
									  item (list item)))))))
       (format stream (if (stringp data)
			  data (write-to-string data))))))

(defmacro build-browser-style (&rest items)
  "Render interface CSS to file."
  `(with-open-file (stream (asdf:system-relative-pathname (make-symbol (package-name *package*))
							  "portal.css")
			   :direction :output :if-exists :supersede :if-does-not-exist :create)
     (let ((data (concatenate 'string ,@(mapcar (lambda (css-module)
						  (if (listp css-module)
						      (lass:compile-and-write css-module) 
						      (if (stringp css-module)
							  css-module)))
						(loop :for item :in items 
						   :append (macroexpand (if (listp item)
									    item (list item))))))))
       (format stream (if (stringp data)
			  data (write-to-string data))))))

(defmacro html-stream-to-string (form)
  "Render HTML to string."
  `(let ((stream (make-string-output-stream)))
     (cl-who:with-html-output (stream) (:html ,@form))
     (get-output-stream-string stream)))
