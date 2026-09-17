;;; setup.lisp
;;;
;;; Workspace setup for demo.access. Initializes:
;;;  - The Philo catalog (catalog.lisp, read at runtime by branches)
;;;  - A Classic blog imprint with an in-memory persistence backend
;;;    and a default writer account for the CMS demo

(in-package #:demo.access)

;;; ---------------------------------------------------------------------------
;;; Classic CMS setup
;;; ---------------------------------------------------------------------------

(defvar *blog*
  (classic.models.common:make-blog
   :name "Demo Blog"
   :authority "seed-demo.local"
   :authority-date "2026")
  "The Classic blog imprint backing the CMS demo. Uses in-memory persistence.")

(defvar *default-account*
  (classic.models.common:create-account
   *blog* :name "Demo Author" :role :writer)
  "Default writer account for the CMS demo.")
