(defpackage #:seed.branch.abcd
  (:use #:cl)
  (:shadowing-import-from #:seed.generate #:seed #:branch
                          #:interface-format-form #:load-seed-system
                          #:syspath #:file-to-string
                          #:system-file-to-string #:adapt-from-alist #:adapt-from-json
                          #:from-system-file #:build-templater #:get-template-metadata
                          #:astr #:setf-value #:abind #:cbind #:text-wrap #:of-array-spec)
  (:shadowing-import-from #:seed.modulate #:dx #:render #:uim-web #:uim-web-stream
                          #:uic-anchor #:uic-frame #:uic-series #:uic-grid
                          #:uicc-button #:uicc-field #:uicc-select #:uich-candle #:spec-graph-interface
                          #:role-cast #:uir-call #:uir-call-c #:uir-call-b #:uir-call-form
                          #:uir-actuatable #:uir-sortable #:uir-reducable #:uir-toggle)
  (:shadowing-import-from #:pla.browser.maple #:*flat-sources* #:retrieve-flat-source
                          #:implement-start-controls #:write-to-file
                          #:build-static-page #:concat-files #:build-styles #:build-script-pdnd
                          #:build-script-cmirror #:build-script-pmirror #:build-script-misc)
  (:shadowing-import-from #:seed.access #:authorize))

(in-package :seed.branch.abcd)

(seed :seed.branch.abcd ;; (:join-by join)
  (:linking . :abcd)
  (:access :systems systems :to-grow grow :to-branch branch :of-system of-system))

(branch :abcd :summary
  (lambda (context input)
    (declare (ignore context input))
    '((:create :create) (:nav :analyses) nil
      (:chart :chart-candle) (:chentity :entities-view))))

(branch :abcd :view
  (adapt-from-json :path :session)
  (lambda (context input)
    (destructuring-bind (&key session &allow-other-keys) input
      ;; (print (list :bp package (funcall context :branch-point)))
      (let ((context (first session))
            (summary (grow :abcd :summary))
            (branch-point (or (funcall context *portal* :branch-point) 0))
            (start-point 0) (interval-found) (search-complete))
        
        (loop :for s :in summary :for sx :from 0 :until search-complete 
              :do (unless s (if interval-found (setf search-complete t)
                                (setf start-point (1+ sx))))
                  (when (= sx branch-point) (setf interval-found t)))

        (dx ((uic-series :layout (:horizontal :even) :type (:workspace :even)))
            (loop :for l :in (nthcdr start-point summary) :while l
                  :collect (dx ((uic-series :layout (:vertical :of 3 1 1 1)
                                            :join   (list :abcd (first l))
                                            :type   (:column)
                                            :mode   (grow :abcd (first l)
                                                          context (list :state (second l)))))
                               (dx ((uic-series :type (:ui :header)))
                                   (second l)
                                   (grow :abcd (first l)
                                         context (list :ifmod-head t)))
                               (dx ((uic-frame :name (second l) :type (:body)
                                               :access :abcd))
                                   (first l))
                               (dx ((uic-series :type (:ui :footer)))
                                   (list (grow :abcd (first l)
                                               context (list :ifmod-foot t)))))))))))

;; (defvar *seed-templates* '((:template.chart . "../templates/template.charts/")))

(defun manifest-file-listing (path &optional is-creating)
  (append (list (dx ((uic-series :layout (:groups :rows '(2))
                                 :type (:series :enum :table-interstitial :enum)
                                 :call t))
                    (dx ((uicc-field :name :system-name :type (:string))) "")
                    (dx ((uicc-button :call (:@ :form-input)))
                        "create")))
          (loop :for ix :from 0 :for dir :in (uiop:subdirectories path)
                :append (let ((props (from-system-file :abcd (format nil "~a/chart.lisp" dir)
                                                       :properties)))
                          (destructuring-bind (&key name description) (rest props)
                            (and props (list (dx ((uic-series :type (:series)))
                                                 (list (dx ((uicc-button :call (:.fetch (:point ix)
                                                                                        (:next :refresh))))
                                                           name)
                                                       description)))))))))

;; (defun manifest-template-interface (template-list template-point)
;;   (loop :for item :in template-list :for ix :from 0
;;         :append (destructuring-bind (tname &rest tpath) item
;;                   (multiple-value-bind (tname tdescription) (get-template-metadata tpath)
;;                     (cons (dx ((uic-series :type (:series)))
;;                               (list (dx ((uicc-button :call (:.fetch (:point ix) (:next :refresh))))
;;                                         (first item))
;;                                     tdescription))
;;                           (and template-point (= ix template-point)
;;                                (list (dx ((uic-series :layout (:groups :rows '(2))
;;                                                       :type (:series :enum :table-interstitial :enum)
;;                                                       :call t))
;;                                          (dx ((uicc-field :name :system-name :type (:string))) "")
;;                                          (dx ((uicc-button :call (:@ :form-input)))
;;                                              "create")))))))))

(defun point-from-template (form &optional index)
  (let ((x-start (second (nth 3 (second form))))
        (y-start (second (nth 4 (second form))))
        (x-end   (second (nth 5 (second form))))
        (y-end   (second (nth 6 (second form)))))
    (list :type "line" :points (list (list x-start y-start) (list x-end y-end))
          :name (format nil "obj-~a" (or index 0)) :points-in-flux nil :in-flux :true :ratios nil)))

(branch :abcd :create
  (adapt-from-json :point)
  (lambda (context input)
    (destructuring-bind (&key state ifmod-head ifmod-foot &allow-other-keys) input
      (cond (ifmod-head (values nil t))
            (ifmod-foot (values nil t))
            (t "This is a financial chart analysis tool.")))))

;; (let ((line-templater (build-templater (from-system-file :abcd "sheet.lisp"
;;                                                          :chart-entity-template-line)
;;                                        :type :format :x-start :y-start :x-end :y-end)))

(defun init-chart-entities (context)
  (when (and context (funcall context :abcd :chart-point))
    (unless (funcall context :abcd :chart-entities)
      (let ((chart-path (namestring (nth (funcall context :abcd :chart-point)
                                         (funcall context :abcd :chart-paths)))))
        (funcall context :abcd :chart-entities
                 (from-system-file :abcd (format nil "~a/chart.lisp" chart-path) :chart-entities))))))

(branch :abcd :nav
  (adapt-from-json :point :action)
  (lambda (context input)
    (destructuring-bind (&key state action ifmod-head &allow-other-keys) input
      ;; (print (list :imm ifmod-head))
      (cond (state (values nil))
            (ifmod-head (dx ((:each uicc-button :type (:local) :call (:.fetch (:action :.base)))
                             (uic-series :type (:ui :controls)))
                            (list :create)))
            (action (case (intern (string-upcase action) "KEYWORD")
                      (:create (print (list :aa action)))))
            (context (when (getf input :point)
                       (funcall context :abcd :chart-point (getf input :point))
                       (funcall context :abcd :chart-point nil))
                     (let ((template-point (funcall context :abcd :template-point)))
                       (destructuring-bind (&key system-name &allow-other-keys) input
                         ;; (print (list :ccc input))
                         (render (funcall context nil :medium)
                                 (dx ((uic-series :type (:ui :list-table)
                                                  ;; :call (:.fetch (:point :@base) (:next :refresh))
                                                  ))
                                     (manifest-file-listing (asdf:system-relative-pathname
                                                             :abcd "./analyses/")))))))))))

(branch :abcd :chart
  (adapt-from-json :entities :action :mode ;; next line: entities properties
                             :name :type :in-flux :points :points-in-flux :ratios)
  (lambda (context input)
    (unless (or (not context) (funcall context :abcd :chart-paths)) ;; load list of analyses
      (funcall context :abcd :chart-paths
               (uiop:subdirectories (asdf:system-relative-pathname :abcd "./analyses/"))))

    (init-chart-entities context)

    (unless (or (not context) (funcall context :abcd :chart-point))
      (funcall context :abcd :chart-point 0))
    
    (destructuring-bind (&key state ifmod-head ifmod-foot action entities mode &allow-other-keys) input

      (unless (or (not context) (funcall context :abcd :entity-data)) ;; load existing entity data from file
        (funcall context :abcd :entity-data
                 (loop :for chent :in (cdddr (second (funcall context :abcd :chart-entities)))
                       :for ix :from 0 :collect (point-from-template chent ix))))

      ;; (print (list :ac action entities))
      
      (cond (state :chart) ;; TODO: change ifmod-head stuff to reference a :controls super-property
            (ifmod-head (dx ((:each uicc-button :type (:local)) ; :call :.base)
                             (uic-series :type (:ui :controls)
                                         :role (toggle)))
                            (list :select :draw :retrace-x :retrace-y)))
            (ifmod-foot (dx ((:each uicc-button :type (:local))
                             (uic-series :type (:ui :controls)))
                            (list :save :zoom-actual)))
            (entities
             (let ((collected))
               ;; (print (list :ent entities))
               (unless (funcall context :abcd :line-templater)
                 (funcall context :abcd :line-templater
                          (build-templater (from-system-file :abcd "sheet.lisp"
                                                             :chart-entity-template-line)
                                           :type :format :x-start :y-start :x-end :y-end)))
               
               (when (listp (first entities))
                 (dolist (espec entities)
                   (destructuring-bind (&key name type in-flux points points-in-flux ratios) espec
                     ;; (print (list :es espec points))
                     (destructuring-bind (x-start y-start x-end y-end) (reduce #'append points)
                       ;; (print (list :in2 entities name type points))
                       (let ((index)
                             (item (list :points points :name name :type type :points-in-flux nil
                                         :in-flux :true :ratios ratios)))
                         (loop :for i :from 0 :for ent :in (funcall context :abcd :entity-data)
                               :do (if (string= name (getf ent :name))
                                       (setf index i)
                                       (setf (getf ent :in-flux) :false)))
                         ;; (print (list :ent index (funcall context :abcd :entity-data)))
                         (let ((edata (funcall context :abcd :entity-data)))
                           (if index (setf (nth index edata) item)
                               (progn (push item edata)
                                      (push (funcall (funcall context :abcd :line-templater)
                                                     :x-start x-start :x-end x-end ;; :format format
                                                     :y-start y-start :y-end y-end :type type)
                                            collected)))
                           (funcall context :abcd :entity-data edata)))))))
               ;; (print (list :ce chart-entities))
               (let ((entities (funcall context :abcd :chart-entities)))
                 (setf (second entities) (append (second (funcall context :abcd :chart-entities))
                                                 (reverse collected)))
                 (funcall context :abcd :chart-entities entities)
                 (funcall context :abcd :entity-data))))
            (action
             (let ((chart-entities (funcall context :abcd :chart-point (getf input :point)))
                   (chart-path (namestring (nth (funcall context :abcd :chart-point)
                                                (funcall context :abcd :chart-paths)))))
               ;; (print (list :ce chart-entities (package-name *package*)))
               (case (intern (string-upcase (rest input)) "KEYWORD")
                 (:save (let ((output))
                          (setf output (format nil "(progn~%~{~a~%~})" chart-entities))
                          ;; (print (list :out putpu))
                          (setf (from-system-file :abcd (format nil "~a/chart.lisp" chart-path)
                                                  :chart-entities :as-string t)
                                output))))))
            (t (case (intern (string-upcase mode) "KEYWORD")
                 (:chart-data
                  ;; (print (list :cc (funcall context :abcd :chart-point)))
                  ;; (if (and context (funcall context :chart-point))
                  (let ((chart-path (namestring (nth (funcall context :abcd :chart-point)
                                                     (funcall context :abcd :chart-paths)))))
                    ;; (system-file-to-string :abcd data-path)
                    (file-to-string (second (third (second (from-system-file
                                                            :abcd (format nil "~a/chart.lisp" chart-path)
                                                            :chart-entities)))))))
                 (t (render (funcall context nil :medium)
                            (dx ((uich-candle :type (:green-red)))
                                :abcd :chart)))))))))

(branch :abcd :chentity
  (adapt-from-json :path :action :mode :sort :remove)
  (lambda (context input)
    (destructuring-bind (&key state path sort remove &allow-other-keys) input
      (when context
        (let ((entities (funcall context :abcd :chart-entities)))
          (symbol-macrolet ((elist (cdddr (second entities))))
            (if path (cond (sort (destructuring-bind (index move-to) sort
                                   (let ((moved (nth index elist)))
                                     ;; (print (list :en index move-to elist :mm moved))
                                     (if (zerop index) (pop elist)
                                         (rplacd (nthcdr (1- index) elist)
                                                 (rest (nthcdr index elist))))
                                     ;; (print (list :en2 index move-to elist :mov moved))
                                     (if (zerop move-to) (setf elist (cons moved elist))
                                         (rplacd (nthcdr (1- move-to) elist)
                                                 (cons moved (nthcdr move-to elist))))))
                                 (funcall context :abcd :chart-entities entities)
                                 (print :complete))
                           (remove (if (zerop remove) (pop elist)
                                       (rplacd (nthcdr (1- remove) elist)
                                               (rest (nthcdr remove elist))))
                                   (funcall context :abcd :chart-entities entities)
                                   (values :complete t)))
                input))))))
  (lambda (context input)
    (destructuring-bind (&key state ifmod-head ifmod-foot path sort remove action &allow-other-keys) input
      (cond (state :meta-code-form)
            (ifmod-head (dx ((:each uicc-button :type (:local) :call (:.fetch (:action :.base)))
                             (uic-series :type (:ui :controls)))
                            (list :save)))
            (ifmod-foot (dx ((:each uicc-button :type (:local) :call (:.fetch (:action :.base)))
                             (uic-series :type (:ui :controls)))
                            (list :save)))
            (action
             (let ((chart-entities (and context (funcall context :abcd :chart-entities)))
                   (chart-path (namestring (nth (funcall context :abcd :chart-point)
                                                (funcall context :abcd :chart-paths)))))
               ;; (print (list :ce chart-entities))
               (case (intern (string-upcase action) "KEYWORD")
                 (:save (let ((output))
                          ;; (setf output (format nil "(progn~%~{~a~%~})" chart-entities))
                          (setf output chart-entities
                                (from-system-file :abcd (format nil "~a/chart.lisp" chart-path)
                                                  :chart-entities)
                                (funcall context :abcd :chart-entities)))))))
            (t (init-chart-entities context)
               ;; (print (list :ccc context))
               (when context
                 ;; (print (list :con (funcall context :medium)))
                 ;; (print (list :nnn chart-entities))
                 (render (funcall context nil :medium)
                         (dx ((uic-frame :type (:meta-code)))
                             (seed.modulate::express (funcall context :abcd :chart-entities))))))))))

