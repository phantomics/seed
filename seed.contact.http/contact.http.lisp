;;;; seed.contact.http.lisp

(in-package #:seed.contact.http)

(defparameter *request-env* nil
  "*REQUEST-ENV* will be dynamically bound to the environment context of HTTP requests")

(defclass app (ningle:app)
  ()
  (:documentation "Custom application based on NINGLE:APP"))

;; http://dnaeon.github.io/common-lisp-web-dev-ningle-middleware/
(defmethod lack.component:call ((app app) env)
  ;; Dynamically bind *REQUEST-ENV* for each request, so that ningle
  ;; routes can access the environment.
  (let ((*request-env* env))
    (call-next-method)))

;; (defun auth (user pass)
;;   (when (and (string= user "bob")
;;              (string= pass "$ecret"))
;;     (values t "Bob The Admin")))

(defun match-static-path (path)
  (if (ppcre:scan "^(?:/contact/|/render/)" path)
      nil path))

;; (defun main (env)
;;   (let* ((session (getf env :lack.session))
;;          (login (gethash :login session)))
;;     (cond
;;       (login
;;        (list 200 (list :content-type "text/plain")
;;              (list (format nil "Welcome, ~A!"
;;                            login))))
;;       (t
;;        '(403 (:content-type "text/plain")
;;          ("Access denied"))))))

;; (defun testprint (env)
;;   (print env)
;;   (setf *test1* (getf env :lack.session)))

(defun http-contact-service-start (&key (port 8080) interactor-fetch renderer-fetch
                                     (package-name (intern (package-name *package*) "KEYWORD")))
  ;; (print (list :int interactor-fetch))
  (let* ((root-path (asdf:system-relative-pathname package-name "./ui-browser/"))
	 (service (make-instance 'app))
	 (handler (clack:clackup (lack.builder:builder :session (:static :path #'match-static-path
                                                                         :root root-path)
				                       service)
				 :port port :server :hunchentoot :address "0.0.0.0")))
    (setf (ningle:route service "/render/"  :method :POST)
          (lambda (value) (funcall renderer-fetch   value (getf *request-env* :lack.session)))
          (ningle:route service "/contact/" :method :POST)
          (lambda (value) (funcall interactor-fetch value (getf *request-env* :lack.session))))
    (values (lambda () (clack:stop handler)) ;; to stop
	    (lambda () (clack:stop handler)  ;; to restart
	      (clack:clackup (lack.builder:builder :session (:static :path #'match-static-path
                                                                     :root root-path)
			                           service)
			     :port port :server :hunchentoot :address "0.0.0.0")))))


;; (setf (ningle:route service "/" :accept '("text/html" "text/xml"))
;;       #'present-main-interface)
;; (setf (ningle:route service "/login" :method :POST)
;;       (lambda (params)
;;         ))
;; (setf (ningle:route service "/logout" :method :GET)
;;   (lambda (params)
;;     (handler-case
;;         (logout (present-login-interface (cons '("message" . "You are now logged out.") params))
;;     	    (present-login-interface (cons '("message" . "You are not logged in.") params)))
;;       (error (c)
;;         (format t "Caught a condition: ~&")
;;         (values (jonathan:to-json '(:|error| t))
;;     	    c)))))
;; (lambda (params)
;;   (let ((portal-sym (intern (string-upcase (rest (assoc :portal params))) "KEYWORD")))
;;     (handler-case
;;         (let* ((original-params params)
;;                (username (cdr (assoc "portal" params :test #'string=)))
;;                (password (cdr (assoc "branch" params :test #'string=))))
;;           (login (list :|username| username :|password| password)
;;       	   (redirect-to "/")
;;       	   (present-login-interface (cons '("message" . "Wrong username or password.")
;;       					  original-params))
;;       	   (present-login-interface (cons '("message" . "Wrong username or password.")
;;       					  original-params))))
;;       (error (c)
;;         (format t "Caught a condition: ~&")
;;         (values "error"
;;       	  c)))))
;; (setf (ningle:route service "/profile/" :method :GET)
;;       (lambda (params)
;;         ;; (handler-case
;;         ;;     (auth (:user)
;;         ;;           (with-open-stream (html-out (make-string-output-stream))
;;         ;;     	(with-html-output (html-out)
;;         ;;     	  (:html (:head (:meta :charset "utf-8")
;;         ;;     			(:meta :name "viewport" :content "width=device-width,initial-scale=1.0")
;;         ;;     			(:title "Selector Sounds")
;;         ;;     			(:link :rel "stylesheet" :href "./static/app.css"))
;;         ;;     		 (:body (:div :class "profile-editor"
;;         ;;     			      (:h2 "Edit User Data")
;;         ;;     			      (:form :action "/userdata/" :method "post"
;;         ;;     				     (:h4 "Original Password")
;;         ;;     				     (:input :type "password" :name :|oldpass|) (:br)
;;         ;;     				     (:h4 "New Password:")
;;         ;;     				     (:input :type "password" :name :|newpass|) (:br)
;;         ;;     				     (:h4 "New Password Again")
;;         ;;     				     (:input :type "password" :name :|newpass2|) (:br)
;;         ;;     				     (:input :class "sbutton" :type "submit" :value "Submit"))
;;         ;;     			      (:a :href "./" (:h2 "Go Back")))))
;;         ;;     	  (get-output-stream-string html-out)))
;;         ;;           (present-login-interface params))
;;         ;;   (error (c)
;;         ;;     (format t "Caught a condition: ~&")
;;         ;;     (values (jonathan:to-json '(:|error| t))
;;         ;;     	c)))
;;         ))
;; (setf (ningle:route service "/list/" :method :GET :accept "application/json")
;;       (lambda (params)
;;         (declare (ignore params))
;;         (handler-case
;;     	(with-open-stream (cmd-out (make-string-output-stream))
;;     	  (uiop:run-program (format nil "ls ~a/sound-records/"
;;     				    (asdf:system-relative-pathname *this-package-name* ""))
;;     			    :output cmd-out :ignore-error-status t)
;;     	  (let ((each-record (ppcre:split "[\\n]" (get-output-stream-string cmd-out))))
;;     	    (jonathan:to-json
;;     	     (let ((records-out
;;     		    (mapcar (lambda (item)
;;     			      (funcall (lambda (record)
;;     					 (append (list :date (first record))
;;     						 (list :ratings (getf (second record) :ratings)
;;     						       :max-ratings (getf (second record) :max-ratings)
;;     						       :genre (getf (second record) :genre)
;;     						       :comment (getf (second record) :comment)
;;     						       :uploader (getf (second record) :uploader))))
;;     				       (load-form-from-file
;;     					(asdf:system-relative-pathname
;;     					 *this-package-name* (concatenate 'string "sound-records/" item)))))
;;     			    each-record))
;;     		   (user-genres (or (if (member :admin (getf (gethash (user-name) *users*) :roles)) :all)
;;     				    (getf (gethash (user-name) *users*) :genres))))
;;     	       (loop :for r :in records-out
;;     		  :when (and (> (getf r :max-ratings) (length (getf r :ratings)))
;;     			     (not (string= (user-name) (getf r :uploader)))
;;     			     (loop :for rating :in (getf r :ratings)
;;     				:never (string= (getf rating :user) (user-name)))
;;     			     (or (eq :all user-genres)
;;     				 (member (intern (string-upcase (getf r :genre)) "KEYWORD")
;;     					 user-genres)))
;;     		  :collect r)))))
;;           (error (c)
;;     	(format t "Caught a condition: ~&")
;;     	(values (jonathan:to-json '(:|error| t))
;;     		c)))))
