;;;; qualify-build.lisp
;;; This macro is broken out in a separate file so it can easily be used in the install-seed program.

(in-package #:seed.ui-model.html)

(defmacro qualify-build (success failure)
  "Ensure that the necessary components are in place to build the libraries needed by the frontend interface."
  `(flet ((command-exists (command-string prefix)
	    (= 0 (multiple-value-bind (1st 2nd error-code)
		     (uiop:run-program (format nil "~acommand -v ~a" prefix command-string)
				       :ignore-error-status t)
		   (declare (ignore 1st 2nd))
		   error-code))))
     (let ((nvm-found (and (probe-file "~/.nvm")
			   (probe-file "~/.nvm/nvm.sh")))
	   (nvm-prefix "export NVM_DIR=$HOME/.nvm && [ -s \"$NVM_DIR/nvm.sh\" ] && . $NVM_DIR/nvm.sh && "))
       ;; if an nvm installation if found, the nvm-prefix must come before all invocations of Node commands
       (cond ((and (not (and (command-exists "npm" "")
			     (command-exists "node" "")))
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
	       
