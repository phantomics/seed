;;;; seed.lisp

(in-package #:seed)

(router base
	(grammar-check :host "https://grammar-service.seed"
		       :system :grammar-check)
	(spell-check :host "https://spelling-service.seed"
		     :system :spell-check))

(contact-create main-contact :port 8055 :root "./")
