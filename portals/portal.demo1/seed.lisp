;;;; seed.lisp

(in-package #:portal.demo1)

(seed :portal.demo1
  (:contacts :demo.sheet :abcd)
  (:access :to-join join :to-grow grow :to-branch branch :of-system of-system))

(defvar *seed-templates* '((:template.chart . "../templates/template.charts/")))

(branch :portal.demo1 :view
  (adapt-from-json :key :point)
  (adapt-from-alist :system :branch :key :point)
  (lambda (context input)
    (destructuring-bind (&key key point &allow-other-keys) input
      (when (and key (string= "demo" (string-downcase key)))
        (funcall context :user :hello))

      ;; (print (list :inp input))
      (if (and (stringp point) (loop :for i :across point :always (digit-char-p i)))
          (when (and context point)
            ;; when a point is selected, assign it
            (funcall context :branch-point (read-from-string point)))

          (when (and context point)
            (if (string= "BASE" (string-upcase point))
                (of-system :point nil)
                ;; when a system is selected, assign it - case of new selector controls
                (let ((epsym (intern (string-upcase point) "KEYWORD")))
                  (of-system :point epsym)
                  (instantiate-priority-macro-reader (asdf:load-system epsym)
                    (load-seed-system epsym))))))

      (let ((medium (make-instance 'uim-web :portal (intern (package-name *package*) "KEYWORD"))))

        (funcall context :medium medium)

        ;; (print (list :cccc (package-name *package*)))

        (render medium
                (authorize (funcall context :user)
                  (dx ((uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
                                   :maps '(((:type :sidebar)) ((:type :main)))))
                      (dx ((uic-series :type '(:ui :column  :portal-summary)))
                          (dx ((uic-series :type '(:ui :list)))
                              (list :portal.demo1
                                    (dx ((uicc-select :options (list :base :demo.sheet :abcd)
                                                      :call (:.fetch (:point :.base) (:next :refresh))))
                                        (of-system :point))))
                          
                          (and (of-system :point)
                               (dx ((:each uic-anchor :type '(:branch))
                                    (uic-series :type  '(:ui :navigation)
                                                :point (funcall context :branch-point)))
                                   (mapcar #'second (grow (of-system :point) :summary))))
                          
                          (dx ((uic-series :type '(:ui :list)))
                              (dx ((uicc-field  :name "key")) "")
                              (dx ((uicc-button)) "enter")))
                      
                      (if (of-system :point)
                          (grow (of-system :point) :view context)
                          (grow :portal.demo1 :base context)))

                  (dx ((uic-series :type (:ui :main :placard)))
                      (list (dx ((uic-series :type (:ui :column :short) :call t)) ;; should this be :cast?
                                (list "please input your key"
                                      (dx ((uicc-field  :name "key")) "")
                                      (dx ((uicc-button)) "enter")))))))))))

(defun manifest-template-interface (template-list template-point)
  (loop :for item :in template-list :for ix :from 0
        :append (destructuring-bind (tname &rest tpath) item
                  (multiple-value-bind (tname tdescription) (get-template-metadata tpath)
                    (cons (dx ((uic-series :type (:series)))
                              (list (dx ((uicc-button :call (:.fetch (:point ix) (:next :refresh))))
                                        (first item))
                                    tdescription))
                          (and template-point (= ix template-point)
                               (list (dx ((uic-series :layout (:groups :rows '(2))
                                                      :type (:series :enum :table-interstitial :enum)
                                                      :call t))
                                         (dx ((uicc-field :name :system-name :type (:string))) "")
                                         (dx ((uicc-button :call (:@ :form-input)))
                                             "create")))))))))

(branch :portal.demo1 :base
  (adapt-from-json :point :system-name)
  (lambda (context input)
    (when (getf input :point)
      (funcall context :template-point (getf input :point)))
    ;; (print (list :iii input (funcall context :template-point)))
    (let ((template-point (funcall context :template-point)))
      (destructuring-bind (&key system-name &allow-other-keys) input
        (when system-name ;; a new system is being created from a template
          (destructuring-bind (tname &rest tpath) (nth template-point *seed-templates*)
            ;; (print (list :create system-name))
            (make-project (asdf:system-relative-pathname
                           :portal.demo1 (format nil "../../systems/~a" (string-downcase system-name)))
                          :template-directory (asdf:system-relative-pathname
                                               :portal.demo1 (concatenate 'string "../" tpath))
                          :name (string-downcase system-name))))
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
                                       :call (:.fetch (:point :@base) (:next :refresh))))
                          (manifest-template-interface *seed-templates* (funcall context :template-point)))
                      (dx ((uic-series :type (:ui :footer)))
                          (list "bbb")))))))))

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

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(61 116 182)
;;                              10 ;; :ldeltas (april "24×2○○0.12×⍳4")
;;                              :lfactors (april "⎕←1+0.8×2○○0.08×⍳10"))
;;                             "/tmp/palOut.png")

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(61 116 182)
;;                              8 ;; :ldeltas (april "24×2○○0.12×⍳4")
;;                              :lfactors (april "⎕←1+1.4×0.5×2○○0.1×1+⍳8"))
;;                             "/tmp/palOut.png")

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(92 99 132)
;;                              8 ;; :ldeltas (april "24×2○○0.12×⍳4")
;;                              :lfactors (april "⎕←1+2×0.5×2○○0.1×0+⍳8"))
;;                             "/tmp/palOut.png" 100)

;; (emote::write-palette-image (emote::linear-pal-transform
;;                              #(92 99 132)
;;                              10 :lfactors (april "⎕←1+3×0.26×1○○0.1×4+⍳10"))
;;                             "/tmp/palOut.png" 100)

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
