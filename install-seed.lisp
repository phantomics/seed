;;;; install-seed.lisp
;;; A discrete program to install Seed. If dependencies aren't met, it fails and gives instructions to remedy.

(asdf:load-system 'uiop)

(if (not (probe-file #P"~/quicklisp"))
    (princ (format nil "~%~%Seed installation failed.~%~%I couldn't find a /quicklisp directory in your home directory; please install Quicklisp. See https://www.quicklisp.org/beta/ for instructions on setting up Quicklisp.~%"))
    (let* ((criteria (list '("npm" "Command \"npm\" is not available. Please install Node.js and NPM. Note that a system-level installation of Node.js is needed; an nvm-installed Node.js system is not compatible with Seed's build process.")
			   '("node" "Command \"node\" is not available. Please install the legacy Node.js package.")
			   '("gulp" "Command \"gulp\" is not available. Please install Gulp. You should be able to do this by entering \"npm install -g gulp\" with root/administrator privileges.")))
	   (command-exists (lambda (command-string)
			     (= 0 (multiple-value-bind (1st 2nd error-code)
				      (uiop:run-program (format nil "command -v ~a" command-string)
							:ignore-error-status t)
				    (declare (ignore 1st 2nd))
				    error-code))))
	   (lacks-required (apply #'append (mapcar (lambda (criterion)
						     (if (not (funcall command-exists (first criterion)))
							 (list (second criterion))))
						   criteria)))
	   (success-message (format nil "~%~%Congratulations, Seed is installed and ready to use. ~%~%If you would like to automatically load Seed whenever you load your Common Lisp REPL, please add the following line to your Common Lisp implementation's init file:~%~%(asdf:load-system 'seed)~%~%For example, for SBCL this file is usually located at ~~/.sbclrc.~%~%If you would like Seed to automatically open its Web interface whenever you load your REPL, you should add both of these lines to your init file:~%~%(asdf:load-system 'seed)~%(seed:contact-open)~%~%If you wish to close the Web connection, you can do so by entering (seed:contact-close), and reopen it by entering (seed:contact-open) again.~%~%")))
      (if lacks-required
	  (progn (princ (format nil "~%~%Seed installation failed. ~%~%The browser interface cannot be built because ~a missing. Correct the following problems and try again: ~{~%  ~a~}~%~%"
				(if (< 1 (length lacks-required))
				    "necessary tools are" "a necessary tool is")
				lacks-required))
		 (exit))
	  (if (not (probe-file #P"~/quicklisp/local-projects/seed"))
	      (multiple-value-bind (1st 2nd error-code)
		  (uiop:run-program (format nil "ln -s \"~a\" ~~/quicklisp/local-projects/seed"
					    (namestring (probe-file "./")))
				    :ignore-error-status t)
		(declare (ignore 1st 2nd))
		(if (not (= 0 error-code))
		    (princ (format nil "~%~%Seed installation failed. ~%~%I couldn't create a link to this directory in the ~~/quicklisp/local-projects directory. This is needed in order to fetch Seed's dependencies using Quicklisp. Please check the permissions of your ~~/quicklisp and ~~/quicklisp/local-projects folders.~%~%"))
		    (progn (ql:quickload 'seed)
			   (princ success-message))))
	      (progn (ql:quickload 'seed)
		     (princ success-message))))))

(exit)

