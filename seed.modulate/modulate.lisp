;;;; seed.modulate.lisp

(in-package #:seed.modulate)

;; (defun get-type)

;; (defun encode (form &optional meta)
;;   (if (listp form)
;;       (if (eql 'meta (first form))
;;           (encode (second form) (cddr form))
;;           (append (if meta (list :mt meta))
;;                   (list :ty "list"                
;;                         :ct (apply #'vector (mapcar #'encode form)))))
;;       (append (if meta (list :mt meta))
;;               (list :ty (type-of form)
;;                     :ct (write-to-string form)))))

(defun encode (form &optional meta)
  (if (listp form)
      (if (and (symbolp (first form))
               (string= "META" (string-upcase (first form))))
          (if (listp (second form))
              (cons (list :meta (encode (cddr form)))
                    (loop :for item :in (second form) :collect (encode item)))
              (encode (second form) (cddr form)))
          (loop :for item :in form :collect (encode item)))
      (if (arrayp form)
          form (append (if meta (list :mt meta))
                       `(:ty ,(typecase form (symbol :sy) (number :nm) (array :ar))
                         :ct ,(typecase form (symbol (string form))
                                        (t (write-to-string form)))
                         ,@(if (symbolp form)
                               `(:pk ,(package-name (symbol-package form)))))))))
