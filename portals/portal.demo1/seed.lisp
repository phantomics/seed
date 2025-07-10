;;;; seed.lisp

(in-package #:portal.demo1)

(seed :portal.demo1
  (:contacts :demo.sheet)
  (:access :to-join join :to-grow grow :to-branch branch :of-system of-system))

(defvar *seed-templates* '(:template.chart))

(branch :portal.demo1 :view
  (adapt-from-json :key :point)
  (adapt-from-alist :system :branch :key :point)
  (lambda (context input)
    (destructuring-bind (&key key point &allow-other-keys) input
      (when (and key (string= "demo" (string-downcase key)))
        (funcall context :user :hello))

      ;; (print (list :po point))
      ;; (print (list :aabb (of-system :config)))
      (if (and (stringp point) (loop :for i :across point :always (digit-char-p i)))
          (when (and context point)
            ;; when a point is selected, assign it
            (funcall context :branch-point (read-from-string point)))

          (when (and context point)
            ;; when a system is selected, assign it - case of new selector controls
            (let ((epsym (intern (string-upcase point) "KEYWORD")))
              (of-system :point epsym)
              (instantiate-priority-macro-reader (asdf:load-system epsym)
                (load-seed-system epsym)))))

      (let ((medium (make-instance 'uim-web :portal (intern (package-name *package*) "KEYWORD"))))

        (funcall context :medium medium)

        (render medium
                (authorize (funcall context :user)
                  (dx ((uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
                                   :maps '(((:type :sidebar)) ((:type :main)))))
                      (dx ((uic-series :type '(:ui :column  :portal-summary)))
                          (dx ((uic-series :type '(:ui :list)))
                              (list :portal.demo1
                                    ;; (dx ((uicc-button :call (:@fetch (:point :@base) (:next :refresh))))
                                    ;;     "demo.sheet")
                                    
                                    (dx ((uicc-select :type :default-blank
                                                      :options (list :demo.sheet :demo.other)
                                                      :call (:@fetch (:point :@base) (:next :refresh))))
                                        (of-system :point))))
                          
                          (and (of-system :point)
                               (dx ((:each uic-anchor :type '(:branch))
                                    (uic-series :type  '(:ui :navigation)
                                                :point (funcall context :branch-point)))
                                   (mapcar #'second (grow (of-system :point) :summary))))
                          
                          (dx ((uic-series :type '(:ui :list)))
                              (dx ((uicc-field  :name "key")) "")
                              (dx ((uicc-button :call t)) "enter")))
                      
                      (if (of-system :point)
                          (grow (of-system :point) :view context)
                          (grow :portal.demo1 :base context)))

                  (dx ((uic-series :type (:ui :main :placard)))
                      (list (dx ((uic-series :type (:ui :column :short) :call t)) ;; should this be :cast?
                                (list "please input your key"
                                      (dx ((uicc-field  :name "key")) "")
                                      (dx ((uicc-button :call t))
                                          "enter")))))))))))

(defun manifest-template-interface (template-list template-point)
  (loop :for item :in template-list :for ix :from 0
        :append (cons (dx ((uicc-button :call (:@fetch (:point ix) (:next :refresh))))
                          item)
                      (and template-point (= ix template-point)
                           (list (dx ((uic-series :layout (:groups :rows (2))
                                                  :type (:series :enum)))
                                     (dx ((uicc-field :name "new system name" :type (:string))) "")
                                     (dx ((uicc-button :call (:abc))) "create")))))))

(branch :portal.demo1 :base
  (adapt-from-json :point)
  (lambda (context input)
    (when (getf input :point)
      (funcall context :template-point (getf input :point)))
    (print (list :iii input (funcall context :template-point)))
    (dx ((uic-series :layout (:horizontal :even) :type (:workspace :even)))
        (list (dx ((uic-series :layout (:vertical :of 12 1 10 1)
                               :type   (:column)))
                  (dx ((uic-series :type (:ui :header)))
                      :header
                      (list "aaa"))
                  "Hello."
                  (dx ((uic-series :type (:ui :footer)))
                      (list "bbb")))
              (dx ((uic-series :layout (:vertical :of 12 1 10 1)
                               :type   (:column)
                               :join   (list :portal.demo1 :base)
                               ;; :mode   (grow :demo.sheet (first l)
                               ;;               context (list :state (second l)))
                               ))
                  (dx ((uic-series :type (:ui :header)))
                      :header
                      (list "aaa"))
                  (dx ((uic-series :type (:ui :list-table)
                                   :call (:@fetch (:point :@base) (:next :refresh))))
                      (manifest-template-interface *seed-templates* (funcall context :template-point)))
                  (dx ((uic-series :type (:ui :footer)))
                      (list "bbb")))))))

;; (branch :demo.sheet :view
;;   (adapt-from-json :path :session)
;;   (lambda (context input)
;;     (destructuring-bind (&key session &allow-other-keys) input
;;       ;; (print (list :bp package (funcall context :branch-point)))
;;       (let ((context (first session))
;;             (summary (grow :demo.sheet :summary))
;;             (branch-point (or (funcall context :branch-point) 0))
;;             (start-point 0) (interval-found) (search-complete))
        
;;         (loop :for s :in summary :for sx :from 0 :until search-complete 
;;               :do (unless s (if interval-found (setf search-complete t)
;;                                 (setf start-point (1+ sx))))
;;                   (when (= sx branch-point) (setf interval-found t)))

;;         (dx ((uic-series :layout (:horizontal :even) :type (:workspace :even)))
;;             (loop :for l :in (nthcdr start-point summary) :while l
;;                   :collect (dx ((uic-series :layout (:vertical :of 12 1 10 1)
;;                                             :join   (list :demo.sheet (first l))
;;                                             :type   (:column)
;;                                             :mode   (grow :demo.sheet (first l)
;;                                                           context (list :state (second l)))))
;;                                (dx ((uic-series :type (:ui :header)))
;;                                    (second l)
;;                                    (grow :demo.sheet (first l)
;;                                          context (list :ifmod-head t)))
;;                                (dx ((uic-frame :name (second l) :type (:body)
;;                                                :access :demo.sheet))
;;                                    (first l))
;;                                (dx ((uic-series :type (:ui :footer)))
;;                                    (list (grow :demo.sheet (first l)
;;                                                context (list :ifmod-foot t)))))))))))

(branch :portal.demo1 :systems
  (adapt-from-alist :system :branch)
  (lambda (context input)
    (if input (let ((epsym (intern input "KEYWORD")))
                (of-system :point (intern input "KEYWORD"))
                (instantiate-priority-macro-reader (asdf:load-system epsym)
                  (load-seed-system epsym)))
        (-<> (with-meta (of-system :contacts)
               :type (:form))
          (encode <>)))))

;; (seed :portal.demo1
;;       (:bind :package package :of-system of-system :to-grow grow)
;;       (:contacts :demo.sheet) ;; :demo-image)
;;       (:contactor . #'of-contacts)
;;       (:branches
;;        :view
;;        (lambda (context input)
;;          (let ((key-input (rest (assoc :key input :test #'eq))))
;;            (when (and key-input (string= "demo" (string-downcase key-input)))
;;              (funcall context :user :hello)))

;;          (when (and context (assoc :point input))
;;            ;; when a point is selected, assign it
;;            (funcall context :branch-point (read-from-string (rest (assoc :point input)))))

;;          (when (and context (assoc "point" input :test #'string=))
;;            ;; when a system is selected, assign it - case of new selector controls
;;            (let ((epsym (intern (string-upcase (rest (assoc "point" input :test #'string=)))
;;                                 "KEYWORD")))
;;              (of-system :point epsym)
;;              (instantiate-priority-macro-reader (asdf:load-system epsym)
;;                (load-seed-system epsym))))

;;          (let ((medium (make-instance 'uim-web :portal (intern (package-name package) "KEYWORD"))))

;;            (funcall context :medium medium)

;;            (render
;;             medium
;;             (authorize (funcall context :user)
;;               (dx ((uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
;;                                :maps '(((:type :sidebar)) ((:type :main)))))
;;                   (dx ((uic-series :type '(:ui :column  :portal-summary)))
;;                       :portal.demo1
;;                       '(:h3 :|x-on:click| "fetchContact2(context, $el, { point: 'demo.sheet' })"
;;                         "demo.sheet")
;;                       (if (of-system :point)
;;                           (dx ((:each uic-anchor :type '(:branch))
;;                                (uic-series :type '(:ui :navigation)
;;                                            :point (funcall context :branch-point)))
;;                               (mapcar #'second (grow (of-system :point) :summary)))))
                  
;;                   (if (not (of-system :point))
;;                       "" (grow (of-system :point) :view context)))

;;               (dx ((uic-series :type (:ui :column) :cast t))
;;                   (list (dx ((uicc-field :key "key")) "")))))))
;;        :systems
;;        (lambda (context input)
;;          (if input (let ((epsym (intern input "KEYWORD")))
;;                      (of-system :point (intern input "KEYWORD"))
;;                      (instantiate-priority-macro-reader (asdf:load-system epsym)
;;                        (load-seed-system epsym)))
;;              (-<> (with-meta (of-system :contacts)
;;                     :type (:form))
;;                (encode <>))))))
