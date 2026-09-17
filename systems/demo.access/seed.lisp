(defpackage #:seed.branch.demo.access
  (:use #:cl)
  ;; Philo replaces from-system-file for reading the catalog data file.
  (:shadowing-import-from #:seed.generate #:seed #:branch
                          #:adapt-from-alist #:adapt-from-json
                          #:philo)
  (:shadowing-import-from #:seed.modulate #:dx #:express #:render
                          #:uic-series #:uic-frame
                          #:uicc-button #:uicc-field
                          #:aspect #:amake
                          #:uia-based-pane-series #:uia-primal-dual-bank-pane
                          #:uir-patching #:uir-pro-form
                          #:uir-call-refreshing #:uir-contact-refreshing)
  ;; Classic CMS API — the portal depends on classic.models.common so these
  ;; packages exist by the time load-system-directory processes this file.
  (:shadowing-import-from #:classic.models.common
                          #:write-article #:get-articles #:edit-article)
  (:shadowing-import-from #:classic.schema.alpha
                          #:headline #:body #:current-state #:date-created)
  (:import-from #:demo.access #:*blog* #:*default-account*))

(in-package :seed.branch.demo.access)

(defparameter *system* :demo.access)

;; Philo is pathname-first: resolve the catalog file's location ourselves,
;; rather than passing an ASDF system designator.
(defvar *catalog-path*
  (asdf:system-relative-pathname :demo.access "catalog.lisp"))

;; CodeMirror token for the CMS text editor.  Must match the token that
;; uicc-field :type (:code) generates from (list *system* :cms).
(defvar *cms-cm-token* "cm-texteditor-demo.access-cms")

(seed :seed.branch.demo.access
  (:linking . :demo.access)
  (:access :systems systems :to-grow grow :staccess (state of-state state-accessor)))

;;; ---------------------------------------------------------------------------
;;; :summary — portal navigation tabs
;;; ---------------------------------------------------------------------------

(branch :summary
  (lambda (state input)
    (declare (ignore state input))
    (symbol-macrolet ((header-controls (grow *system* name nil (list :uimod :header-controls)))
                      (footer-controls (grow *system* name nil (list :uimod :footer-controls))))
      (list
       ;; Tab 1 — existing Philo catalog demo (unchanged)
       (aspect pane-series (:name :catalog :role (patching))
         (let ((name :catalog) (title :catalog-view))
           (list (aspect dual-bank-pane :name name :title title :role (pro-form)
                   :system *system* :controls (list header-controls footer-controls)))))
       ;; Tab 2 — Classic CMS
       (aspect pane-series (:name :cms :role (patching))
         (let ((name :cms) (title :classic-cms))
           (list (aspect dual-bank-pane :name name :title title :role (pro-form)
                   :system *system* :controls (list header-controls footer-controls)))))))))

;;; ---------------------------------------------------------------------------
;;; :view — route to the active tab (unchanged)
;;; ---------------------------------------------------------------------------

(branch :view
  (adapt-from-json :path :session)
  (lambda (state input)
    (declare (ignore input))
    (let ((summary (grow *system* :summary))
          (branch-point (or (of-state :- :view-point) 0)))
      (amake (nth branch-point summary)))))

;;; ---------------------------------------------------------------------------
;;; :catalog — Philo file-access demo (unchanged)
;;; ---------------------------------------------------------------------------

;; The :catalog branch is the demonstration. On a normal render it reads the
;; catalog file through Philo four different ways, builds one new-grammar fx
;; sequence from the results, and expresses it. Because the wrapper fx form
;; carries :by (and no :fx), seed.modulate:express detects the new grammar and
;; delegates to seed.modulate2, producing a manifestation tree. The legacy
;; uic-frame container wrapping that manifestation exercises the modulate/
;; modulate2 bridge.
(branch :catalog
  (adapt-from-alist :system :branch :face)
  (adapt-from-json :height :width)
  (lambda (state input)
    (destructuring-bind (&key identity uimod height width &allow-other-keys) input
      (when (or height width)
        (print (list :hh height width)))
      (cond
        (identity :meta-code-form)
        ((eq uimod :header-controls) (dx (uic-series :type (:ui :controls)) (list :one)))
        ((eq uimod :footer-controls) (dx (uic-series :type (:ui :controls)) (list :one)))
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

;;; ---------------------------------------------------------------------------
;;; :cms — Classic CMS integration
;;; ---------------------------------------------------------------------------

;;; Helper: render the article list view.

(defun render-cms-list (state)
  "Build the article list view with edit buttons and a 'no articles' fallback."
  (let* ((medium (funcall state nil :medium))
         (articles (get-articles *blog*))
         (items
           (loop :for article :in articles
                 :for ix :from 0
                 :collect (dx (uic-series :type (:series))
                              (list (or (headline article) "(untitled)")
                                    (or (current-state article) "draft")
                                    (make-instance
                                     'uicc-button :base "edit"
                                     :role (list (make-instance
                                                  'uir-contact-refreshing
                                                  :a (list :action "edit"
                                                           :index ix)))))))))
    (render medium
            (dx (uic-frame :type (:meta-code))
                (if items
                    (dx (uic-series :type (:ui :list)) items)
                    "No articles yet. Click 'new' to create one.")))))

;;; Helper: render the create-article form.

(defun render-cms-create (state)
  "Build a form with title field, body textarea, and create/cancel buttons."
  (let ((medium (funcall state nil :medium))
        ;; Inline JS for the create button: query field values by name and
        ;; send them to the branch via fetchContact, then trigger a refresh.
        (create-js
          (format nil "~@{~a~}"
                  "var f=$event.target.closest('.series');"
                  "if(f){"
                  "var ti=f.querySelector('[name=title]');"
                  "var bo=f.querySelector('[name=body]');"
                  "fetchContact($event.target,mode,"
                  "{action:'create',title:ti?ti.value:'',body:bo?bo.value:''},"
                  "{next:'refresh'})}")))
    (render medium
            (dx (uic-frame :type (:meta-code))
                (dx (uic-series :type (:series))
                    (list "New Article"
                          (dx (uicc-field :name :title) "")
                          (dx (uicc-field :name :body :type (:area)) "")
                          `(:button :class "button" :|x-on:click| ,create-js "Create")
                          (make-instance
                           'uicc-button :base "back"
                           :role (list (make-instance
                                        'uir-call-refreshing :n :action)))))))))

;;; Helper: render the edit view with CodeMirror.

(defun render-cms-edit (state)
  "Build the edit view: article title as a heading, body in a CodeMirror editor,
   and save/back buttons."
  (let* ((medium   (funcall state nil :medium))
         (idx      (of-state :- :cms-edit-index))
         (articles (get-articles *blog*))
         (article  (and idx (nth idx articles)))
         (title    (if article (or (headline article) "(untitled)") "(no article)"))
         ;; Inline JS for the save button: read CodeMirror content from
         ;; window.seedData and send it via fetchContact.
         (save-js
           (format nil "~@{~a~}"
                   "var t='" *cms-cm-token* "';"
                   "if(seedData[t]){"
                   "fetchContact($event.target,mode,"
                   "{text:[seedData[t].state.doc.toString()]},"
                   "{next:'refresh'})}")))
    (render medium
            (dx (uic-frame :type (:meta-code))
                (dx (uic-series :type (:series))
                    (list (format nil "Editing: ~a" title)
                          ;; CodeMirror editor — fetches body text via the text
                          ;; protocol: sends {text:[0]} to this branch on init.
                          (dx (uicc-field :name :text :type (:code))
                              (list *system* :cms))
                          `(:button :class "button" :|x-on:click| ,save-js "Save")
                          (make-instance
                           'uicc-button :base "back"
                           :role (list (make-instance
                                        'uir-call-refreshing :n :action)))))))))

;;; The :cms branch.
;;;
;;; Handles three kinds of requests:
;;;   1. /contact/ with text protocol — CodeMirror load ({text:[0]}) and
;;;      save ({text:["content"]}).
;;;   2. /contact/ with action params — state updates (new, create, edit, back)
;;;      that return JSON; the subsequent "refresh" event triggers a full
;;;      page re-render via /render/.
;;;   3. /render/ with no action/text — renders the current view (list, create,
;;;      or edit) based on session state.

(branch :cms
  (adapt-from-alist :system :branch :face)
  (adapt-from-json :action :title :body :text :index :height :width)
  (lambda (state input)
    (destructuring-bind (&key identity uimod action title body text index
                         &allow-other-keys)
        input
      (cond
        ;; ----- Standard system metadata -----
        (identity :meta-code-form)

        ((eq uimod :header-controls)
         (dx (uic-series :type (:ui :controls))
             (list (make-instance
                    'uicc-button :base "new"
                    :role (list (make-instance
                                 'uir-call-refreshing :n :action))))))

        ((eq uimod :footer-controls)
         (dx (uic-series :type (:ui :controls)) (list :one)))

        ;; ----- CodeMirror text protocol (via /contact/) -----
        (text
         (let ((edit-idx (of-state :- :cms-edit-index)))
           (cond
             ;; Load: text = (0)
             ((and (listp text) (numberp (first text)) (zerop (first text)))
              (let* ((articles (get-articles *blog*))
                     (article  (and edit-idx (nth edit-idx articles))))
                (list :text (or (and article (body article)) ""))))
             ;; Save: text = ("content-line" ...)
             (t
              (when edit-idx
                (let ((content (if (listp text)
                                   (apply #'concatenate 'string text)
                                   (princ-to-string text))))
                  (edit-article *blog* (1+ edit-idx)
                                 :account *default-account*
                                 :text content)))
              (list :text "saved")))))

        ;; ----- Actions (via /contact/, followed by refresh) -----

        ;; Show the create form
        ((and action (string-equal action "new"))
         (of-state :- :cms-mode :create)
         (of-state :- :cms-edit-index nil)
         (list :ok t))

        ;; Create an article from the form data
        ((and action (string-equal action "create"))
         (when (and title (plusp (length title)))
           (write-article *blog* :account *default-account*
                          :title title :text (or body "")))
         (of-state :- :cms-mode nil)
         (list :ok t))

        ;; Switch to the edit view for a specific article
        ((and action (string-equal action "edit"))
         (let ((idx (etypecase index
                      (integer index)
                      (string  (parse-integer index :junk-allowed t))
                      (null    0))))
           (of-state :- :cms-edit-index idx)
           (of-state :- :cms-mode :edit))
         (list :ok t))

        ;; Return to the list from create or edit
        ((and action (string-equal action "back"))
         (of-state :- :cms-mode nil)
         (of-state :- :cms-edit-index nil)
         (list :ok t))

        ;; ----- Default render (via /render/) -----
        (t (case (of-state :- :cms-mode)
             (:create (render-cms-create state))
             (:edit   (render-cms-edit state))
             (t       (render-cms-list state))))))))
