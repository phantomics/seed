;;;; seed.admit.lisp

(in-package #:seed.admit)

;; (login (list :|username| username :|password| password)
;;        (redirect-to "/")
;;        (present-login-interface (cons '("message" . "Wrong username or password.")
;; 				      original-params))
;;        (present-login-interface (cons '("message" . "Wrong username or password.")
;; 				      original-params)))

(defmacro authorize (list env-api &body clauses)
  (destructuring-bind (confirmed denied) clauses
    (let ((session (gensym)) (user-info (gensym)))
      `(let ((,session (funcall ,env-api)))
         (print (list :ss ,session))
         (let ((,user-info (gethash :remote-user ,session)))
           (if ,user-info ,confirmed ,denied))))))

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
;;   (let ((user (gensym)))
;;     `(hermetic:setup :user-p     (lambda (,user) (funcall ,getter ,user))
;;                      :user-pass  (lambda (,user) (funcall ,getter ,user :pass))
;;                      :user-roles (lambda (,user) (funcall ,getter ,user :roles))
;;                      :session    ,session-symbol)))

;; (cl-pass:hash new-pass :type :pbkdf2-sha256 :iterations 10000)
