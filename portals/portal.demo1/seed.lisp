;;;; seed.lisp 

(in-package #:portal.demo1)

(seed :portal.demo1
      (:bind :package package :of-system of-system :to-grow grow)
      (:contacts :demo.sheet) ;; :demo-image)
      (:contactor . #'of-contacts)
      (:branches
       :view
       (lambda (context input)
         (let ((key-input (rest (assoc :key input :test #'eq))))
           (when (and key-input (string= "demo" (string-downcase key-input)))
             (funcall context :user :hello)))

         (when (and context (assoc :point input))
           ;; when a point is selected, assign it
           (funcall context :branch-point (read-from-string (rest (assoc :point input)))))

         (when (and context (assoc "point" input :test #'string=))
           ;; when a system is selected, assign it - case of new selector controls
           (let ((epsym (intern (string-upcase (rest (assoc "point" input :test #'string=)))
                                "KEYWORD")))
             (of-system :point epsym)
             ;; (instantiate-priority-macro-reader (asdf:load-system epsym))
             ;; (load-seed-system epsym) ;; TEMPORARY -- RESTORE THIS
             ))

         (let ((medium (make-instance 'uim-web :portal (intern (package-name package) "KEYWORD"))))

           (funcall context :medium medium)
           
           (render
            medium
            (authorize (funcall context :user)
              (fx ((uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
                               :maps '(((:type :sidebar)) ((:type :main)))))
                  (fx ((uic-series :type '(:ui :column  :portal-summary)))
                      :portal.demo1
                      '(:h3 :|x-on:click| "fetchContact2(context, $el, { point: 'demo.sheet' })"
                        "demo.sheet")
                      (if (of-system :point)
                          (fx ((:each uic-anchor :type '(:branch))
                               (uic-series :type '(:ui :navigation)
                                           :point (funcall context :branch-point)))
                              (mapcar #'second (grow (of-system :point) :summary)))))
                  
                  (if (not (of-system :point))
                      "" (grow (of-system :point) :view context)))

              (fx ((uic-series-form :type (:ui :column) :cast t))
                  (list (fx ((uicc-text :key "key")) "")))))))
       :systems
       (lambda (context input)
         (if input (let ((epsym (intern input "KEYWORD")))
                     (of-system :point (intern input "KEYWORD"))
                     ;; (instantiate-priority-macro-reader (asdf:load-system epsym))
                     ;; (load-seed-system epsym) ;; TEMPORARY - RESTORE
                     )
             (-<> (with-meta (of-system :contacts)
                    :type (:form))
               (encode <>))))))
