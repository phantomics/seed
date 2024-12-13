;;;; seed.lisp

(in-package #:portal.demo1)

(seed2 :portal.demo1
       (:bind :package package :of-system of-system :to-grow grow)
       (:contacts :demo.sheet) ;; :demo-image)
       (:contactor . #'of-contacts)
       (:branches
        :view
        (lambda (session input)
          (let ((key-input (rest (assoc :key input :test #'eq))))
            (when (and key-input (string= "demo" (string-downcase key-input)))
              (funcall session :user :hello)))

          (when (and session (assoc :point input))
            ;; when a point is selected, assign it
            (funcall session :branch-point (intern (string-upcase (rest (assoc :point input)))
                                                   "KEYWORD")))

          (when (and session (assoc "point" input :test #'string=))
            ;; when a system is selected, assign it - case of new selector controls
            (let ((epsym (intern (string-upcase (rest (assoc "point" input :test #'string=)))
                                 "KEYWORD")))
              (of-system :point epsym)
              ;; (instantiate-priority-macro-reader (asdf:load-system epsym))
              (load-seed-system epsym)))
          ;; (print (list :bbb session input (package-name package) package))

          ;; (when (and session (not (funcall session :portal-name)))
          ;;   (funcall session :portal-name :portal.demo1))

          (let* ((this-stream (make-string-output-stream))
                 (medium (make-instance 'uim-web :stream this-stream
                                                 :portal (intern (package-name package)
                                                                 "KEYWORD"))))

            ;; (print (of-system :point))
            
            ;; (print (list :aa (grow (of-system :point) :view nil (list (list :info :summary)))))
            
            (render
             medium
             (authorize (funcall session :user)
               (fx ((uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
                                :maps '(((:type :sidebar)) ((:type :main)))))
                   (fx ((uic-series :type '(:ui :column)))
                       :portal.demo1
                       '(:h3 :|x-on:click| "fetchContact2(context, $el, { point: 'demo.sheet' })"
                         "demo.sheet")

                       (if (of-system :point)
                           (fx ((uic-series :type '(:ui :column)))
                               (mapcar #'second (grow (of-system :point)
                                                     :view session (list (list :info :summary))))))
                       ;; (if nil ; (of-system :point)
                       ;;     (fx (seed.generate::derive-nav-menu (grow (of-system :point) :view))
                       ;;         (:each uic-anchor :link (:send :view :point :self))
                       ;;         (uic-series :type (:ui :column))))
                       )
                   ;; (render-html-interface
                   ;;  (encode (uic ((:type :form :branch-navigation)
                   ;;                (:app :set-nav-point)
                   ;;                (:target . :view)
                   ;;                (:point (funcall session :branch-point)))
                   ;;               (if (not (of-system :point))
                   ;;                   "" (render-nav-menu (grow (of-system :point)
                   ;;                                             :view))))))
                   (if (not (of-system :point))
                       ""

                       ;; (render-html-interface (encode (print (grow (of-system :point) :view session))))
                       
                       ;; (-<> (grow (of-system :point) :view session)
                       ;;   ;; (in-system-context <> (package-name package))
                       ;;   (render-html-interface (encode <>)))
                       
                       (grow (of-system :point) :view session)
                       
                       ))

               (fx ((uic-series-form :type (:ui :column)
                                     :cast t))
                   (list (fx ((uicc-text-line :key "key")) "")))))
            
            (get-output-stream-string this-stream)))
        :systems
        (lambda (session input)
          (if input (let ((epsym (intern input "KEYWORD")))
                      (of-system :point (intern input "KEYWORD"))
                      ;; (instantiate-priority-macro-reader (asdf:load-system epsym))
                      (load-seed-system epsym)
                      )
              (-<> (with-meta (of-system :contacts)
                     :type (:form))
                (encode <>))))))



;; (-<> (Uic ((:type :group :stack :main)
;;            (:members :heading :main))
;;           (uic ((:type :heading))
;;                (string-downcase (package-name package)))
;;           (let ((out (make-string-output-stream)))
;;             (spinneret:interpret-html-tree
;;              (htrender '(meta ((meta "Key" (:type :label))
;;                                (meta "" (:name :key)
;;                                 (:type :field :text)))
;;                          (:type :set :form))
;;                        :params '(:system :portal.demo1 :branch :view))
;;              :stream out)
;;             (get-output-stream-string out)))
;;   (in-system-context <> (package-name package))
;;   (interface-format-form input)
;;   (render-html-interface (encode <>)))
