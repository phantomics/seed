;;;; seed.access.lisp

(in-package #:seed.access)

;; (login (list :|username| username :|password| password)
;;        (redirect-to "/")
;;        (present-login-interface (cons '("message" . "Wrong username or password.")
;; 				      original-params))
;;        (present-login-interface (cons '("message" . "Wrong username or password.")
;; 				      original-params)))

(defmacro register (&rest args)
  (cons 'read-keys-from-file args))

(defun read-keys-from-file (file-path session)
  (with-open-file (input file-path)
    (let ((in-form (read input)))
      (print in-form)
      (loop :for item :in in-form :do (setf (gethash (first item) session) (rest item))))))

(defmacro authorize (condition &body clauses)
  (destructuring-bind (confirmed denied) clauses
    (let ((session (gensym)))
      `(let ((,session ,condition))
         (if ,session ,confirmed ,denied)))))

;; (defmacro defauth (to-authorize to-admit session-sym)
;;   (let ((pass-hash (gensym)) (account (gensym)))
;;     `(setf (symbol-value ,session-sym)
;;            (make-hash-table :test #'string=)
;;            (symbol-function ,to-authorize)
;;            (lambda (password)
;;              (let ((,pass-hash (cl-pass:hash password))
;;                    (,account))
;;                (loop :for key :being :each :hash-key :of ,session-sym :when (string= key ,pass-hash)
;;                      :do (setf ,account (gethash key ,session-sym)))
;;                (when ,account )
;;                ,account))
;;            (symbol-function ,to-admit)
           
;;            )))

;; (defmacro auth-setup (session-symbol getter)
;;   (let ((user (gensym "USER")))
;;     `(hermetic:setup :user-p     (lambda (,user) (funcall ,getter ,user))
;;                      :user-pass  (lambda (,user) (funcall ,getter ,user :pass))
;;                      :user-roles (lambda (,user) (funcall ,getter ,user :roles))
;;                      :session    ,session-symbol)))

;; (cl-pass:hash new-pass :type :pbkdf2-sha256 :iterations 10000)
