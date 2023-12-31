;;;; seed.lisp

(in-package #:seed)

(seed-instance :portals-path "./portals")

(defvar *output-stream*)

(defun interface-interact (interface-key branch-key &optional input)
  (interact (of-interfaces interface-key) branch-key input))

;; (manifest-portal-contact-web)
