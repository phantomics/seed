;;;; seed.lisp 

(in-package #:portal.demo1)

(seed2 :portal.demo1
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
              (load-seed-system epsym)))

          ;; (when (and context (not (funcall context :portal-name)))
          ;;   (funcall context :portal-name :portal.demo1))

          ;; (when (and context (not (funcall context :medium)))
          ;;   (let ((this-stream (make-string-output-stream)))
          ;;     (funcall context :medium (make-instance 'uim-web :stream this-stream
          ;;                                                      :portal (intern (package-name package)
          ;;                                                                      "KEYWORD")))))

          (let* ((this-stream (make-string-output-stream))
                 (medium (make-instance 'uim-web :stream this-stream
                                                 :portal (intern (package-name package)
                                                                 "KEYWORD"))))

            (funcall context :medium medium)
            
            (render
             medium
             (authorize (funcall context :user)
               (fx ((uic-series :type '(:ui :grid-layout :linear :main :split :left-sidebar)
                                :maps '(((:type :sidebar)) ((:type :main)))))
                   (fx ((uic-series :type '(:ui :column)))
                       :portal.demo1
                       '(:h3 :|x-on:click| "fetchContact2(context, $el, { point: 'demo.sheet' })"
                         "demo.sheet")
                       (if (of-system :point)
                           (fx ((:each uic-anchor :type '(:branch))
                                (uic-series :type '(:ui :navigation)))
                               (mapcar #'second (grow (of-system :point) :summary)))))
                   
                   (if (not (of-system :point))
                       "" (grow (of-system :point) :view context)))

               (fx ((uic-series-form :type (:ui :column) :cast t))
                   (list (fx ((uicc-text :key "key")) "")))))
            
            (get-output-stream-string this-stream)))
        :systems
        (lambda (context input)
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
