;;;; seed.lisp

(in-package #:portal.demo1)

(seed2 :portal.demo1
       (:bind :package package :of-system of-system :to-grow grow)
       (:contacts :demo.sheet) ;; :demo-image)
       (:contactor . #'of-contacts)
       (:branches
        :view
        (lambda (session input)
          ;; (print (list :aaa session input))
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
          ;;; (print (list :bbb session input (package-name package)))

          (authorize (funcall session :user)

            (let ((this-stream (make-string-output-stream)))
              (render (make-instance 'uim-web :stream this-stream) 
                      (fx (list (fx (list :portal.demo1 
                                          "<h3 x-on:click=\" fetchContact2(context, $el, { point: 'demo.sheet' })\">demo.sheet</h3>"
                                          (render-html-interface
                                           (encode (uic ((:type :form :branch-navigation)
                                                         (:app :set-nav-point)
                                                         (:target . :view)
                                                         (:point (funcall session :branch-point)))
                                                        (if (not (of-system :point))
                                                            "" (render-nav-menu (grow (of-system :point)
                                                                                      :view)))))))
                                    (uic-series :type '(:ui :column)))
                                (if (not (of-system :point))
                                    "" (-<> (grow (of-system :point) :view session)
                                          ;; (in-system-context <> (package-name package))
                                          (render-html-interface (encode <>)))))
                          (uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
                                      :maps '(((:type :sidebar)) ((:type :main))))))
              (get-output-stream-string this-stream))
            
            
            ;; (render-web
            ;;  (uispec (:series
            ;;           :type (:ui :grid-layout :linear :main :split :left-sidebar)
            ;;           :layout (list :sidebar :main)
            ;;           (:frame :type (:group :stack :form)
            ;;                   (:head (string-downcase (package-name package)))
            ;;                   ;; (-<> (uic ((:type :form) (:app :set-endpoint))
            ;;                   ;;           (of-system :contacts))
            ;;                   ;;   (in-system-context <> (package-name package))
            ;;                   ;;   (render-html-interface (encode <>)))
            ;;                   (:expr ;; (xform (print (of-system :contacts))
            ;;                          ;;        (:type :form :bla) (:app :set-endpoint))
            ;;                          )
            ;;                   "<h3 x-on:click=\" fetchContact2(context, $el, { point: 'demo.sheet' })\">demo.sheet</h3>"
            ;;                   ;; (:expr (uic ((:type :form) (:app :set-endpoint))
            ;;                   ;;             (portal-contacts portal)))
            ;;                   (render-html-interface
            ;;                    (encode (uic ((:type :form :branch-navigation)
            ;;                                  (:app :set-nav-point)
            ;;                                  (:target . :view)
            ;;                                  (:point (funcall session :branch-point)))
            ;;                                 (if (not (of-system :point))
            ;;                                     "" (render-nav-menu (grow (of-system :point)
            ;;                                                               :view)))))))
                      
            ;;           (if (not (of-system :point))
            ;;               nil (-<> (grow (of-system :point) :view session)
            ;;                     ;; (in-system-context <> (package-name package))
            ;;                     (render-html-interface (encode <>)))))))
            
            (-<> (uic ((:type :group :stack :main)
                       (:members :heading :main))
                      (uic ((:type :heading))
                           (string-downcase (package-name package)))
                      (let ((out (make-string-output-stream)))
                        (spinneret:interpret-html-tree
                         (htrender '(meta ((meta "Key" (:type :label))
                                           (meta "" (:name :key)
                                            (:type :field :text)))
                                     (:type :set :form))
                                   :params '(:system :portal.demo1 :branch :view))
                         :stream out)
                        (get-output-stream-string out)))
              (in-system-context <> (package-name package))
              (interface-format-form input)
              (render-html-interface (encode <>)))
            ))
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
