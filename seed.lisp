;;;; seed.lisp

(in-package #:seed)

;; the routes below are examples, routing will be fully implemented later
(router base
	(grammar-check :host "https://grammar-service.seed"
		       :system :grammar-check)
	(spell-check :host "https://spelling-service.seed"
		     :system :spell-check))

(let ((contact-list nil))
  (contact-create-in contact-list main-contact :port 8055 :root "./")

  (defun contact-open ()
    (contact-open-in contact-list))

  (defun contact-close ()
    (contact-close-in contact-list)))
