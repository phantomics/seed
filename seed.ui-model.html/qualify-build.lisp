;;;; qualify-build.lisp
;;; This macro is broken out in a separate file so it can easily be used in the install-seed program.

(in-package #:seed.ui-model.html)

;; (defmacro qualify-build (success failure)
;;   "Ensure that the necessary components are in place to build the libraries needed by the frontend interface."
;;   `(let* ((criteria (list '("npm" "Command \"npm\" is not available. Please install Node.js and NPM. Note that a system-level installation of Node.js is needed; an nvm-installed Node.js system is not compatible with Seed's build process.")
;; 			  '("node" "Command \"node\" is not available. Please install Node.js.")
;; 			  '("gulp" "Command \"gulp\" is not available. Please install Gulp. You should be able to do this by entering \"npm install -g gulp\" with root/administrator privileges.")))
;; 	  (command-exists (lambda (command-string)
;; 			    (= 0 (multiple-value-bind (1st 2nd error-code)
;; 				     (uiop:run-program (format nil "command -v ~a" command-string)
;; 						       :ignore-error-status t)
;; 				   (declare (ignore 1st 2nd))
;; 				   error-code))))
;; 	  (lacks-required (loop :for criterion :in criteria
;; 			     :append (if (not (funcall command-exists (first criterion)))
;; 					 (list (second criterion))))))
;;      (if lacks-required
;; 	 (progn (princ (format nil "~%~%~a ~%~%The browser interface cannot be built because ~a missing. Correct the following problems and try again: ~{~%  ~a~}~%~%"
;; 			       ,(first failure)
;; 			       (if (< 1 (length lacks-required))
;; 				   "necessary tools are" "a necessary tool is")
;; 			       lacks-required))
;; 		,@(rest failure))
;; 	 (progn ,@success))))


(defmacro qualify-build (success failure)
  "Ensure that the necessary components are in place to build the libraries needed by the frontend interface."
  `(flet ((command-exists (command-string &optional prefix)
	    (let ((prefix (if prefix prefix "")))
	      (= 0 (multiple-value-bind (1st 2nd error-code)
		       (uiop:run-program (format nil "~acommand -v ~a" prefix command-string)
					 :ignore-error-status t)
		     (declare (ignore 1st 2nd))
		     error-code)))))
     (let ((nvm-found (and (probe-file "~/.nvm")
			   (probe-file "~/.nvm/nvm.sh")))
	   (nvm-prefix "export NVM_DIR=$HOME/.nvm && [ -s \"$NVM_DIR/nvm.sh\" ] && . $NVM_DIR/nvm.sh && "))
       (cond ((and (not (and (command-exists "npm")
			     (command-exists "node")))
		   (or (not nvm-found)
		       (not (and (command-exists "npm" nvm-prefix)
				 (command-exists "node" nvm-prefix)))))
	      (progn (princ (format nil "~%~%~a ~%~%The browser interface cannot be built because Node.js and NPM are missing. Please install Node.js, either at the system level or locally using a node version manager like nvm."
				    ,(first failure)))
		     ,@(rest failure)))
	     ((not (command-exists "gulp" (if nvm-found nvm-prefix "")))
	      (progn (princ (format nil "~%~%~a ~%~%The browser interface cannot be built because Node.js and NPM are missing. Please install Node.js, either at the system level or locally using a node version manager like nvm."
				    ,(first failure)))
		     ,@(rest failure)))
	     (t ,@success)))))
	       
