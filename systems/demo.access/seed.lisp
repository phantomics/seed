(defpackage #:seed.branch.demo.access
  (:use #:cl)
  ;; Philo replaces from-system-file for reading the catalog data file.
  (:shadowing-import-from #:seed.generate #:seed #:branch
                          #:adapt-from-alist #:adapt-from-json
                          #:philo)
  (:shadowing-import-from #:seed.modulate #:dx #:express #:render
                          #:uic-series #:uic-frame
                          #:aspect #:amake
                          #:uia-based-pane-series #:uia-primal-dual-bank-pane
                          #:uir-patching #:uir-pro-form))

(in-package :seed.branch.demo.access)

(defparameter *system* :demo.access)

;; Philo is pathname-first: resolve the catalog file's location ourselves,
;; rather than passing an ASDF system designator.
(defvar *catalog-path*
  (asdf:system-relative-pathname :demo.access "catalog.lisp"))

(seed :seed.branch.demo.access
  (:linking . :demo.access)
  (:access :systems systems :to-grow grow :staccess (state of-state state-accessor)))

(branch :summary
  (lambda (state input)
    (declare (ignore state input))
    (symbol-macrolet ((header-controls (grow *system* name nil (list :uimod :header-controls)))
                      (footer-controls (grow *system* name nil (list :uimod :footer-controls))))
      (list (aspect pane-series (:name :catalog :role (patching))
              (let ((name :catalog) (title :catalog-view))
                (aspect dual-bank-pane :name name :title title :role (pro-form)
                  :system *system* :controls (list header-controls footer-controls))))))))

(branch :view
  (adapt-from-json :path :session)
  (lambda (state input)
    (declare (ignore input))
    (let ((summary (grow *system* :summary))
          (branch-point (or (of-state :- :view-point) 0)))
      (amake (nth branch-point summary)))))

;; The :catalog branch is the demonstration. On a normal render it reads the
;; catalog file through Philo four different ways, builds one new-grammar fx
;; sequence from the results, and expresses it. Because the wrapper fx form
;; carries :by (and no :fx), seed.modulate:express detects the new grammar and
;; delegates to seed.modulate2, producing a manifestation tree. The legacy
;; uic-frame container wrapping that manifestation exercises the modulate/
;; modulate2 bridge.
(branch :catalog
  (adapt-from-alist :system :branch :face)
  (lambda (state input)
    (destructuring-bind (&key identity uimod &allow-other-keys) input
      (cond
        (identity :meta-code-form)
        ((eq uimod :header-controls) (dx (uic-series :type (:ui :controls)) (list)))
        ((eq uimod :footer-controls) (dx (uic-series :type (:ui :controls)) (list)))
        (t (let* ((path *catalog-path*)
                  (members
                    (append
                     ;; 1. Single read: the first form after :tools.
                     (list "Single  (philo path :tools):"
                           (philo path :tools))
                     ;; 2. Offset read: the third form after :tools.
                     (list "Offset  (philo path :tools :offset 2):"
                           (philo path :tools :offset 2))
                     ;; 3. Range read: forms [0,3) after :quantities (a list).
                     (list "Range   (philo path :quantities :range '(0 3)):")
                     (philo path :quantities :range '(0 3))
                     ;; 4. Region read: every form in the :colors region (a list).
                     (list "Region  (philo path :colors :region t):")
                     (philo path :colors :region t))))
             (render (funcall state nil :medium)
                     (dx (uic-frame :type (:meta-code))
                         (express (list 'fx members '(:by :observing)))))))))))
