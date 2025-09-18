;; (seed :demo.sheet (:join-by join))
;; (seed :portal.demo1
;;   ;; (:contacts :demo.sheet :abcd)
;;   (:contacts :abcd)
;;   (:access :to-join join :to-grow grow :to-branch branch :of-system of-system :systems systems))

(defpackage #:seed.branch.demo.sheet
  (:use #:cl)
  (:shadowing-import-from #:seed.generate #:seed
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

(in-package :seed.branch.demo.sheet)

(seed :seed.branch.demo.sheet
  (:linking . :demo.sheet)
  (:access :systems systems :to-grow grow :to-branch branch :of-system of-system :to-join join))

(branch :summary
  (let ((layout '((:main :code-view) (:cells :cells-view) nil
                  (:graph :graph-overview) (:graph :graph-node))))
    (lambda (context input)
      (declare (ignore context input))
      layout)))

(branch :view
  (adapt-from-json :path :session)
  (lambda (context input)
    (destructuring-bind (&key session &allow-other-keys) input
      ;; (print (list :bp package (funcall context :branch-point)))
      (let ((context (first session))
            (summary (grow :demo.sheet :summary))
            (branch-point (or (funcall context *portal* :branch-point) 0))
            (start-point 0) (interval-found) (search-complete))
        
        (loop :for s :in summary :for sx :from 0 :until search-complete 
              :do (unless s (if interval-found (setf search-complete t)
                                (setf start-point (1+ sx))))
                  (when (= sx branch-point) (setf interval-found t)))

        (dx ((uic-series :layout (:horizontal :even) :type (:workspace :even)))
            (loop :for l :in (nthcdr start-point summary) :while l
                  :collect (dx ((uic-series :layout (:vertical :of 3 1 1 1)
                                            :join   (list :demo.sheet (first l))
                                            :type   (:column)
                                            :mode   (grow :demo.sheet (first l)
                                                          context (list :state (second l)))))
                               (dx ((uic-series :type (:ui :header)))
                                   (second l)
                                   (grow :demo.sheet (first l)
                                         context (list :ifmod-head t)))
                               (dx ((uic-frame :name (second l) :type (:body)
                                               :access :demo.sheet))
                                   (first l))
                               (dx ((uic-series :type (:ui :footer)))
                                   (list (grow :demo.sheet (first l)
                                               context (list :ifmod-foot t)))))))))))

;; (branch :demo.sheet :build
;;   (lambda (context input)
;;     (cbind input item
;;       ("state" :chart)
;;       ("ifmod-head" (dx ((:each uicc-button :type (:local)) ; :call :.base)
;;                          (uic-series :type (:ui :controls)))
;;                         (list :select :draw :retrace-x :retrace-y)))
;;       ("ifmod-foot" (dx ((:each uicc-button :type (:local))
;;                          (uic-series :type (:ui :controls)))
;;                         (list :save :zoom-actual)))
;;       (t (let ((context (second (assoc :session input)))
;;                (summary (grow :demo.sheet :summary))
;;                (start-point 0) (interval-found) (search-complete))

;;            (dx ((uic-series :layout (:horizontal :even) :type (:workspace :even)))
;;                (list (dx ((uicc-button :type (:local)))
;;                          "addItem"))))))))

;; (branch :demo.sheet :chart
;;   ;; (adapt-from-json :entities :action :mode)
;;   (lambda (context input)
;;     ;; (print (list :in input))
;;     (cbind input item
;;       ("state" :chart)
;;       ("ifmod-head" (dx ((:each uicc-button :type (:local)) ; :call :.base)
;;                          (uic-series :type (:ui :controls)))
;;                         (list :select :draw :retrace-x :retrace-y)))
;;       ("ifmod-foot" (dx ((:each uicc-button :type (:local))
;;                          (uic-series :type (:ui :controls)))
;;                         (list :save :zoom-actual)))
;;       ("entities"
;;        (let ((collected))
;;          (dolist (espec (rest (assoc "entities" input :test #'string=)))
;;            (destructuring-bind (x-start y-start x-end y-end)
;;                (reduce #'append (rest (assoc "points" espec :test #'string=)))
;;              ;; (print (list :in2 input chart-entities))
;;              (let ((points (rest (assoc "points" espec :test #'string=)))
;;                    (name   (rest (assoc "name"   espec :test #'string=)))
;;                    (type   (rest (assoc "type"   espec :test #'string=)))
;;                    (ratios (rest (assoc "ratios" espec :test #'string=))))
;;                (let ((index)
;;                      (item (list :points points :name name :type type :points-in-flux nil
;;                                  :in-flux :true :ratios ratios)))
;;                  (loop :for ent :in entity-data :for i :from 0
;;                        :do (if (string= name (getf ent :name))
;;                                (setf index i)
;;                                (setf (getf ent :in-flux) :false)))
;;                  ;; (print (list :ent entity-data))
;;                  (if index (setf (nth index entity-data) item)
;;                      (progn (push item entity-data)
;;                             (push (funcall line-templater :x-start x-start :y-start y-start
;;                                                           :x-end x-end :y-end y-end :type type)
;;                                   collected)))))))
;;          (setf (second chart-entities)
;;                (append (second chart-entities) (reverse collected)))
;;          entity-data))
;;       ("action"
;;        ;; (print (list :it item))
;;        (case (intern (string-upcase (rest item)) "KEYWORD")
;;          (:save (let ((output))
;;                   (setf output (format nil "(progn~%~{~a~%~})" chart-entities))
;;                   (setf (from-system-file :demo.sheet "sheet.lisp" :chart-entities :as-string t)
;;                         output)))))
;;       (t (case (intern (string-upcase (rest (assoc "mode" input :test #'string=)))
;;                        "KEYWORD")
;;            (:chart-data (system-file-to-string :demo.sheet "price.csv"))
;;            (t (render (funcall context :medium)
;;                       (dx ((uich-candle :type (:green-red)))
;;                           :demo.sheet :chart))))))))

;; (branch :demo.sheet :chentity
;;   (lambda (context input)
;;     (cbind input item
;;       ("state" :meta-code-form)
;;       ("ifmod-head" (dx ((:each uicc-button)
;;                          (uic-series :type (:ui :controls)))
;;                         (list :save)))
;;       ("ifmod-foot" (dx ((:each uicc-button)
;;                          (uic-series :type (:ui :controls)))
;;                         (list :save)))
;;       ("path"
;;        (let ((path (mapcar #'read-from-string (cl-ppcre:split "[ ]" (rest item)))))
;;          (cbind input argument
;;            ("sort" (destructuring-bind (index move-to) (rest argument)
;;                      (symbol-macrolet ((elist (second chart-entities)))
;;                        (let ((moved (nth index elist)))
;;                          ;; (print (list :en index move-to elist :mm moved))
;;                          (if (zerop index) (setf elist (rest elist))
;;                              (rplacd (nthcdr (1- index) elist)
;;                                      (rest (nthcdr index elist))))
;;                          ;; (print (list :en2 index move-to elist :mov moved))
;;                          (if (zerop move-to) (setf elist (cons moved elist))
;;                              (rplacd (nthcdr (1- move-to) elist)
;;                                      (cons moved (nthcdr move-to elist)))))))
;;                    (print :complete)))))
;;       (t (unless chart-entities
;;            ;; (setf entities (fourth (from-system-file :demo.sheet "sheet.lisp" :chart-entities)))
;;            (setf chart-entities (from-system-file :demo.sheet "sheet.lisp" :chart-entities))
;;            )
;;          ;; (print (list :ccc context))
;;          (when context
;;            ;; (print (list :con (funcall context :medium)))
;;            (render (funcall context :medium)
;;                    (dx ((uic-frame :type (:meta-code)))
;;                        (seed.modulate::express chart-entities))))))))

(branch :main
  (adapt-from-json :text)
  (lambda (context input)
    (destructuring-bind (&key state ifmod-head ifmod-foot text &allow-other-keys) input
      (cond (state)
            (ifmod-head (dx ((:each uicc-button)
                             (uic-series :type (:ui :controls)))
                            (list :save :abc)))
            (ifmod-foot (dx ((:each uicc-button)
                             (uic-series :type (:ui :controls)))
                            (list :save)))
            (t (if text
                   (if (zerop (first text))
                       (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
                                                                :main :as-string t)
                                              :unwrap t :syntax :progn :trailing-newlines 2))
                       (let ((input (apply #'concatenate 'string
                                           (loop :for i :in text :append (list i '(#\Newline))))))
                         (setf (from-system-file :demo.sheet "sheet.lisp" :main :as-string t)
                               (text-wrap input :syntax :progn))
                         (load-seed-system package)
                         (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
                                                                  :main :as-string t)
                                                :unwrap t :syntax :progn))))
                   (render (funcall context nil :medium)
                           (dx ((uicc-field :type (:code)))
                               :demo.sheet :main))))))))
  
(branch :cells
  (adapt-from-json :cells)
  (lambda (context input)
    (destructuring-bind (&key state ifmod-head ifmod-foot cells &allow-other-keys) input
      (cond (state)
            (ifmod-head (dx ((:each uicc-button)
                             (uic-series :type (:ui :controls)))
                            (list :save :abc)))
            (ifmod-foot (dx ((:each uicc-button)
                             (uic-series :type (:ui :controls)))
                            (list :save)))
            (cells (let ((display-baseline))
                     (if (not (zerop (first cells)))
                         (if (symbolp (first input))
                             (cond ((eq :toggle-baseline (first input))
                                    (setf display-baseline (not display-baseline))))
                             (let ((original (from-system-file :demo.sheet "sheet.lisp" :cells)))
                               (setf (of-array-spec :initial-contents (setf-value original))
                                     `(quote ,(loop :for row :in input
                                                    :collect (loop :for cell :in row
                                                                   :collect (parse-number:parse-number
                                                                             cell))))
                                     (from-system-file :demo.sheet "sheet.lisp" :cells) original)
                               ;; (instantiate-priority-macro-reader (asdf:load-system package))
                               (load-seed-system :demo.sheet)))
                         (if display-baseline
                             (encode (symbol-value (intern "*CELL-MATRIX*" (string :demo.sheet))))
                             (list :ty :ar :ct
                                   (second (of-array-spec :initial-contents
                                                          (setf-value
                                                           (from-system-file
                                                            :demo.sheet "sheet.lisp" :cells)))))))))
            (t (render (funcall context nil :medium)
                       (dx ((uic-grid :type (:code)))
                           :demo.sheet :cells)))))))

;; (branch :demo.sheet :cells
;;   #'seed.generate::common-json-intake
;;   (lambda (context input)
;;     (cbind input item
;;       ("state")
;;       ("ifmod-head"
;;        (dx ((:each uicc-button)
;;             (uic-series :type (:ui :controls)))
;;            (list :save :abc)))
;;       ("ifmod-foot" (dx ((:each uicc-button)
;;                          (uic-series :type (:ui :controls)))
;;                         (list :save)))
;;       ("cells"
;;        (let ((display-baseline))
;;          (print (list :ci input))
;;          (if (/= 0 (second item))
;;              (if (and (listp input) (listp (first input))
;;                       (stringp (caar input)))
;;                  (cond ((string= "toggleBaseline" (caar input))
;;                         (setf display-baseline (not display-baseline))))
;;                  (let ((original (from-system-file :demo.sheet "sheet.lisp" :cells)))
;;                    (setf (of-array-spec :initial-contents (setf-value original))
;;                          `(quote ,(loop :for row :in input
;;                                         :collect (loop :for cell :in row
;;                                                        :collect (parse-number:parse-number
;;                                                                  cell))))
;;                          (from-system-file :demo.sheet "sheet.lisp" :cells) original)
;;                    ;; (instantiate-priority-macro-reader (asdf:load-system package))
;;                    (load-seed-system :demo.sheet)))
;;              (if display-baseline
;;                  (encode (symbol-value (intern "*CELL-MATRIX*" (string :demo.sheet))))
;;                  (list :ty :ar :ct
;;                        (second (of-array-spec :initial-contents
;;                                               (setf-value
;;                                                (from-system-file
;;                                                 :demo.sheet "sheet.lisp" :cells)))))))))
;;       (t (render (funcall context :medium)
;;                  (dx ((uic-grid :type (:code)))
;;                      :demo.sheet :cells))))))
  
;; (branch :demo.sheet :code
;;   #'seed.generate::common-json-intake
;;   (lambda (context input)
;;     (seed.generate::form-as-vectors
;;      (seed.generate::form-span (encode '((+ 1 (* 3 4)) (* 8 5)))))))
       
;; (branch :demo.sheet :form
;;   #'seed.generate::common-json-intake
;;   (lambda (context input)
;;     (when (third input)
;;       ;; only process input if fields apart form system/branch are present
;;       (let ((original (from-system-file :demo.sheet "sheet.lisp" :form)))
;;         (meta-revise (second (third original)) input)
;;         (setf (from-system-file :demo.sheet "sheet.lisp" :form) original)))

;;     (render (funcall context :medium)
;;             (seed.modulate::express (second (third (from-system-file :demo.sheet "sheet.lisp" :form)))))))

;; (branch :demo.sheet :table
;;   #'seed.generate::common-json-intake
;;   (let ((original (from-system-file :demo.sheet "sheet.lisp" :table)))
;;     (lambda (context input)
;;       (when (fourth input)
;;         ;; only process input if fields apart form system/branch are present
;;         (meta-revise (second (third original)) input)
;;         ;; (setf (from-system-file :demo.sheet "sheet.lisp" :table) original)
;;         (let ((val-key :t) (unit-key) (count 0)
;;               (vout (make-string-output-stream))
;;               (uout (make-string-output-stream)))
;;           (format vout "#~%") (format uout "~%#~%")
;;           (loop :while val-key :for ix :from 0
;;                 :do (setf  val-key (intern (format nil "V-~a" ix) "KEYWORD")
;;                           unit-key (intern (format nil "U-~a" ix) "KEYWORD"))
;;                     (if (assoc val-key input)
;;                         (progn (when (= 5 count)
;;                                  (setf count 0)
;;                                  (format vout "~%#~%")
;;                                  (format uout "~%#~%"))
;;                                (format vout "  ~a  |" (rest (assoc val-key  input)))
;;                                (format uout " ~a |" (or (rest (assoc unit-key input))
;;                                                         "nounit"))
;;                                (incf count))
;;                         (setf val-key nil)))
;;           ;; (print (list :st (concatenate 'string
;;           ;;                               (get-output-stream-string vout)
;;           ;;                               (get-output-stream-string uout))))
;;           (with-open-file (in-file "/tmp/input.txt"
;;         		           :direction :output :if-exists :supersede
;;                                    :if-does-not-exist :create)
;;             (format in-file (get-output-stream-string vout))
;;             (format in-file (get-output-stream-string uout))
;;             ;; (loop :for char := (read-char vout) :while char :do (write-char char in-file))
;;             ;; (loop :for char := (read-char uout) :while char :do (write-char char in-file))
;;             )
;;           (uiop:run-program
;;            (format nil "faketime 15-11-05 ~a ~a solve /tmp/input.txt /tmp/out.txt"
;;                    "~/src/old/dpneo/ecalc/app/ecalc"
;;                    "~/src/old/dpneo/ecalc/app/uc.json"))
;;           ))
;;       (let ((out (make-string-output-stream)))
;;         ;; TODO: REPLACE THIS
        
;;         ;; (spinneret:interpret-html-tree
;;         ;;  (htrender (second (third original))
;;         ;;            :params (list :system :demo.sheet :branch :table))
;;         ;;  :stream out)
;;         (get-output-stream-string out)))))

;; (branch :demo.sheet :esgraph
;;   ;; #'seed.generate::common-json-intake
;;   (spec-graph-interface
;;    :package :demo.sheet :file-name "sheet.lisp" 
;;    :holder-id "esgraphOverview" :associated-node-ids #("graphNode")
;;    :node-template-key :esgraph-node-template :link-template-key :esgraph-link-template
;;    :graph-key :esgraph :node-indices-key :esgraph-node-indices))

(let ((interactor
        (spec-graph-interface
         :package :demo.sheet :file-name "sheet.lisp" :holder-id "graphOverview"
         :associated-node-ids #("graphNode") :node-template-key :graph-node-template
         :link-template-key :graph-link-template :graph-key :graph
         :node-indices-key :graph-node-indices)))
  (branch :graph
    (adapt-from-json :action :index :target :width :height :path :face
                     :title :image :dialog)
    (adapt-from-alist :system :branch :face)
    (lambda (context input)
      (destructuring-bind (&key state ifmod-head ifmod-foot
                             action index target width height path face &allow-other-keys)
          input
        (cond (state (when state (case state
                                   (:graph-overview :graph-breadth)
                                   (:graph-node     :meta-code-form))))
              (ifmod-head (dx ((:each uicc-button :type (:remote) :call :.base)
                               (uic-series :type (:ui :controls)))
                              (list :add-node :add-link)))
              (ifmod-foot (dx ((:each uicc-button :call :.base)
                               (uic-series :type (:ui :controls)))
                              (list :save)))
              (t (funcall interactor (funcall context nil :medium) input)))))))

;; (let ((interactor
;;         (spec-graph-interface
;;          :package :demo.sheet :file-name "sheet.lisp" :holder-id "graphOverview"
;;          :associated-node-ids #("graphNode") :node-template-key :graph-node-template
;;          :link-template-key :graph-link-template :graph-key :graph
;;          :node-indices-key :graph-node-indices)))
;;   (branch :demo.sheet :graph
;;     #'seed.generate::common-json-intake
;;     (lambda (context input)
;;       (cbind input item
;;         ("state" (when (assoc "state" input :test #'string=)
;;                    (case (second (assoc "state" input :test #'string=))
;;                      (:graph-overview :graph-breadth)
;;                      (:graph-node     :meta-code-form))))
;;         ("ifmod-head" (dx ((:each uicc-button :type (:remote) :call :.base)
;;                            (uic-series :type (:ui :controls)))
;;                           (list :add-node :add-link)))
;;         ("ifmod-foot" (dx ((:each uicc-button :call :.base)
;;                            (uic-series :type (:ui :controls)))
;;                           (list :save)))
;;         (t (funcall interactor context input))))))

(branch :play
  (adapt-from-json :index)
  (let ((state) (node) (selector))
    (lambda (context input)
      (destructuring-bind (&key index &allow-other-keys) input
        ;; (print (list :inx input))
        (unless (and (find-package 'demo.sheet)
                     (boundp (intern "*GRAPH-NODES*" "DEMO.SHEET")))
          (instantiate-priority-macro-reader (asdf:load-system :demo.sheet)))
        (unless node (multiple-value-bind (this-node selector-out)
                         (seed.generate::graph-walker
                          (first (symbol-value (intern "*GRAPH-NODES*" "DEMO.SHEET"))))
                       ;; (print (list :tn1 this-node input))
                       (setf node this-node selector selector-out)))
        ;; (print (list :in input))
        (when index
          (multiple-value-bind (this-node selector-out)
              (funcall selector (read-from-string index))
            (setf node this-node selector selector-out)))
        (let* ((out (make-string-output-stream))
               (dialog (rest (assoc :dialog (first node))))
               (image (rest (assoc :image (first node))))
               (imsym (intern (string-upcase image) "KEYWORD"))
               (responses (mapcar (lambda (item) (rest (assoc :dialog item)))
                                  (second node))))
          ;; (print (list :dia dialog node responses
          ;;              :image image))
          (spinneret:interpret-html-tree
           `(:div :class "scenario-frame"
                  ,@(unless (eq imsym :none)
                      `(:style ,(format nil "background-image: url(./static/characters/~a.jpg); background-size: 500px; background-position-y: top; background-position-x: right; background-repeat: no-repeat;"
                                        image)))
                  (:div :class "setting"
                        (:div :class "dialog" ,dialog)
                        (:ol :class "responses"
                             ,@(loop :for response :in responses :for ix :from 0
                                     :collect
                                     (list :li :|hx-on:click|
                                           (parenscript:ps (parenscript:chain
                                                            htmx (trigger this "reload"
                                                                          (parenscript:create
                                                                           index (parenscript:lisp ix))))
                                             (parenscript:chain console (log "hello")))
                                           :hx-vals (seed.generate::json-convert-to (list :index ix))
                                           response)))))
           :stream out)
          (get-output-stream-string out))))))

;; (branch :demo.sheet :main
;;   #'seed.generate::common-json-intake
;;   (lambda (context input)    
;;     (cbind input item
;;       ("state")
;;       ("ifmod-head" (dx ((:each uicc-button)
;;                          (uic-series :type (:ui :controls)))
;;                         (list :save :abc)))
;;       ("ifmod-foot" (dx ((:each uicc-button)
;;                          (uic-series :type (:ui :controls)))
;;                         (list :save)))
;;       (t (if (assoc "text" input :test #'string=)
;;              (if (zerop (second (assoc "text" input :test #'string=)))
;;                  (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
;;                                                           :main :as-string t)
;;                                         :unwrap t :syntax :progn :trailing-newlines 2))
;;                  (let ((input (apply #'concatenate 'string
;;                                      (loop :for i :in (rest (assoc "text" input :test #'string=))
;;                                            :append (list i '(#\Newline))))))
;;                    (setf (from-system-file :demo.sheet "sheet.lisp" :main :as-string t)
;;                          (text-wrap input :syntax :progn))
;;                    (load-seed-system package)
;;                    (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
;;                                                             :main :as-string t)
;;                                           :unwrap t :syntax :progn))))
;;              (render (funcall context :medium)
;;                      (dx ((uicc-field :type (:code)))
;;                          :demo.sheet :main)))))))

;; (branch :demo.sheet :play
;;   (let ((state) (node) (selector))
;;     (lambda (context input)
;;       (unless (and (find-package 'demo.sheet)
;;                    (boundp (intern "*GRAPH-NODES*" "DEMO.SHEET")))
;;         (instantiate-priority-macro-reader (asdf:load-system :demo.sheet)))
;;       (unless node (multiple-value-bind (this-node selector-out)
;;                        (seed.generate::graph-walker
;;                         (first (symbol-value (intern "*GRAPH-NODES*" "DEMO.SHEET"))))
;;                      ;; (print (list :tn1 this-node input))
;;                      (setf node this-node selector selector-out)))
;;       (when (assoc :index input :test #'eq)
;;         (multiple-value-bind (this-node selector-out)
;;             (funcall selector (read-from-string (rest (assoc :index input :test #'eq))))
;;           (setf node this-node selector selector-out)))
;;       (let* ((out (make-string-output-stream))
;;              (dialog (rest (assoc :dialog (first node))))
;;              (image (rest (assoc :image (first node))))
;;              (imsym (intern (string-upcase image) "KEYWORD"))
;;              (responses (mapcar (lambda (item) (rest (assoc :dialog item)))
;;                                 (second node))))
;;         ;; (print (list :dia dialog node responses
;;         ;;              :image image))
;;         (spinneret:interpret-html-tree
;;          `(:div :class "scenario-frame"
;;                 ,@(unless (eq imsym :no-image)
;;                     `(:style ,(format nil "background-image: url(./static/~a.png); background-size: 1500px; background-position-y: -~apx;"
;;                                       image (case imsym (:image-active 400)
;;                                                   (:image-resting 200)))))
;;                 (:div :class "setting"
;;                       (:div :class "dialog" ,dialog)
;;                       (:ol :class "responses"
;;                            ,@(loop :for response :in responses :for ix :from 0
;;                                    :collect
;;                                    (list :li :|hx-on:click|
;;                                          (parenscript:ps (parenscript:chain
;;                                                           htmx (trigger this "reload"
;;                                                                         (parenscript:create
;;                                                                          index (parenscript:lisp ix))))
;;                                            (parenscript:chain console (log "hello")))
;;                                          :hx-vals (seed.generate::json-convert-to (list :index ix))
;;                                          response))))
;;                 ;; ,@(unless (string= image "no-image")
;;                 ;;     `((:div :class "background-image"
;;                 ;;             :style
;;                 ;;             ,(format nil " position: absolute; top: 0; left: 0;
;;                 ;;                                           margin-top: ~a; pointer-events: none;"
;;                 ;;                      (if (string= image "image-resting")
;;                 ;;                          "-200px" "-600px"))
;;                 ;;             (:img :src ,(format nil "./static/~a.png" image)))))
;;                 )
;;          :stream out)
;;         (get-output-stream-string out)))))

;; (seed :demo.sheet
;;       (:bind :package package :of-system of-system :to-grow grow)
;;       (:joiner . #'add-contact)
;;       (:branches
;;        :summary
;;        (let ((layout '((:main :code-view) (:cells :cells-view) nil
;;                        (:graph :graph-overview) (:graph :graph-node) nil
;;                        (:chart :chart-candle)  (:chentity :entities-view))))
;;          (lambda (context input)
;;            (declare (ignore context input))
;;            layout))
;;        :view
;;        (lambda (context input)
;;          ;; (print (list :bp package (funcall context :branch-point)))
;;          (let ((context (second (assoc :session input)))
;;                (summary (grow :demo.sheet :summary))
;;                (branch-point (or (funcall context :branch-point) 0))
;;                (start-point 0) (interval-found) (search-complete))
           
;;            (loop :for s :in summary :for sx :from 0 :until search-complete 
;;                  :do (unless s (if interval-found (setf search-complete t)
;;                                    (setf start-point (1+ sx))))
;;                      (when (= sx branch-point) (setf interval-found t)))
           
;;            (dx ((uic-series :layout (:horizontal :even) :type (:workspace :even)))
;;                (loop :for l :in (nthcdr start-point summary) :while l
;;                      :collect (dx ((uic-series :layout (:vertical :of 12 1 10 1)
;;                                                :join   (list :demo.sheet (first l))
;;                                                :type   (:column)
;;                                                :mode   (grow :demo.sheet (first l)
;;                                                              context (list (list "state" 100)))))
;;                                   (dx ((uic-series :type (:ui :header)))
;;                                       (second l)
;;                                       (grow :demo.sheet (first l)
;;                                             context (list (list "ifmod-head" 100))))
;;                                   (dx ((uic-frame :name (second l) :type (:body)
;;                                                   :access :demo.sheet))
;;                                       (first l))
;;                                   (dx ((uic-series :type (:ui :footer)))
;;                                       (list (grow :demo.sheet (first l)
;;                                                   context (list (list "ifmod-foot" 100))))))))))
;;        :chart
;;        (let ((chart-data)
;;              (entities (rest (from-system-file :demo.sheet "sheet.lisp" :chart-entities))))
;;          (lambda (context input)
;;            ;; (print (list :in input))
;;            (cbind input item
;;              ("state" :chart)
;;              ("ifmod-head" (dx ((:each uicc-button :type (:trigger :local))
;;                                 (uic-series :type (:ui :controls)))
;;                                (list :select :draw :retrace-x :retrace-y)))
;;              ("ifmod-foot" (dx ((:each uicc-button :type (:trigger :local))
;;                                 (uic-series :type (:ui :controls)))
;;                                (list :save :zoom-actual)))
;;              ("entities"
;;               (loop :for entity :in (rest item)
;;                     :do (push (reduce #'append (cons (list 'draw :line) (astr :points entity)))
;;                               entities)))
;;              ("action"
;;               ;; (print (list :it item))
;;               (case (intern (string-upcase (rest item)) "KEYWORD")
;;                 (:save (let ((output))
;;                          (setf output (format nil "(progn~%~{~a~%~})" entities))
;;                          (setf (from-system-file :demo.sheet "sheet.lisp" :chart-entities :as-string t)
;;                                (print output))))))
;;              (t (case (intern (string-upcase (rest (assoc "mode" input :test #'string=)))
;;                               "KEYWORD")
;;                   (:chart-data (system-file-to-string :demo.sheet "price.csv"))
;;                   (t (render (funcall context :medium)
;;                              (dx ((uich-candle :type (:green-red)))
;;                                  :demo.sheet :chart))))))))
;;        :chentity
;;        (let ((entities))
;;          (lambda (context input)
;;            (cbind input item
;;              ("ifmod-head" (dx ((:each uicc-button)
;;                                 (uic-series :type (:ui :controls)))
;;                                (list :save)))
;;              ("ifmod-foot" (dx ((:each uicc-button)
;;                                 (uic-series :type (:ui :controls)))
;;                                (list :save)))
;;              ("path"
;;               (let ((path (mapcar #'read-from-string (cl-ppcre:split "[ ]" (rest item)))))
;;                 (cbind input argument
;;                   ("sort" (destructuring-bind (index move-to) (rest argument)
;;                             (symbol-macrolet ((elist (second entities)))
;;                               (let ((moved (nth index elist)))
;;                                 ;; (print (list :en index move-to elist :mm moved))
;;                                 (if (zerop index) (setf elist (rest elist))
;;                                     (rplacd (nthcdr (1- index) elist)
;;                                             (rest (nthcdr index elist))))
;;                                 ;; (print (list :en2 index move-to elist :mov moved))
;;                                 (if (zerop move-to) (setf elist (cons moved elist))
;;                                     (rplacd (nthcdr (1- move-to) elist)
;;                                             (cons moved (nthcdr move-to elist)))))))
;;                           (print :complete)))))
;;              (t (unless entities
;;                   (setf entities (second (from-system-file :demo.sheet "sheet.lisp" :chart-entities))))
;;                 (when context
;;                   (render (funcall context :medium)
;;                           (dx ((uic-frame :type (:meta-code)))
;;                               (seed.modulate::express entities))))))))
;;        :main
;;        (lambda (context input)
;;          (cbind input item
;;            ("state")
;;            ("ifmod-head" (dx ((:each uicc-button)
;;                               (uic-series :type (:ui :controls)))
;;                              (list :save :abc)))
;;            ("ifmod-foot" (dx ((:each uicc-button)
;;                               (uic-series :type (:ui :controls)))
;;                              (list :save)))
;;            (t (if (assoc "text" input :test #'string=)
;;                   (if (zerop (second (assoc "text" input :test #'string=)))
;;                       (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
;;                                                                :main :as-string t)
;;                                              :unwrap t :syntax :progn :trailing-newlines 2))
;;                       (let ((input (apply #'concatenate 'string
;;                                           (loop :for i :in (rest (assoc "text" input :test #'string=))
;;                                                 :append (list i '(#\Newline))))))
;;                         (setf (from-system-file :demo.sheet "sheet.lisp" :main :as-string t)
;;                               (text-wrap input :syntax :progn))
;;                         (load-seed-system package)
;;                         (list :text (text-wrap (from-system-file :demo.sheet "sheet.lisp"
;;                                                                  :main :as-string t)
;;                                                :unwrap t :syntax :progn))))
;;                   (render (funcall context :medium)
;;                           (dx ((uicc-field :type (:code)))
;;                               :demo.sheet :main))))))
;;        :cells
;;        (lambda (context input)
;;          ;; (print (list :aa input))
;;          (cbind input item
;;            ("state")
;;            ("ifmod-head"
;;             (dx ((:each uicc-button)
;;                  (uic-series :type (:ui :controls)))
;;                 (list :save :abc)))
;;            ("ifmod-foot" (dx ((:each uicc-button)
;;                               (uic-series :type (:ui :controls)))
;;                              (list :save)))
;;            ("cells"
;;             (let ((display-baseline))
;;               (if (/= 0 (second item))
;;                   (if (and (listp input) (listp (first input))
;;                            (stringp (caar input)))
;;                       (cond ((string= "toggleBaseline" (caar input))
;;                              (setf display-baseline (not display-baseline))))
;;                       (let ((original (from-system-file :demo.sheet "sheet.lisp" :cells)))
;;                         (setf (of-array-spec :initial-contents (setf-value original))
;;                               `(quote ,(loop :for row :in input
;;                                              :collect (loop :for cell :in row
;;                                                             :collect (parse-number:parse-number
;;                                                                       cell))))
;;                               (from-system-file :demo.sheet "sheet.lisp" :cells) original)
;;                         ;; (instantiate-priority-macro-reader (asdf:load-system package))
;;                         (load-seed-system :demo.sheet)))
;;                   (if display-baseline
;;                       (encode (symbol-value (intern "*CELL-MATRIX*" (string :demo.sheet))))
;;                       (list :ty :ar :ct
;;                             (second (of-array-spec :initial-contents
;;                                                    (setf-value
;;                                                     (from-system-file
;;                                                      :demo.sheet "sheet.lisp" :cells)))))))))
;;            (t (render (funcall context :medium)
;;                       (dx ((uic-grid :type (:code)))
;;                           :demo.sheet :cells)))))
;;        :code
;;        (lambda (context input)
;;          (seed.generate::form-as-vectors
;;           (seed.generate::form-span (encode '((+ 1 (* 3 4)) (* 8 5))))))
       
;;        :form
;;        (lambda (context input)
;;          (when (third input)
;;            ;; only process input if fields apart form system/branch are present
;;            (let ((original (from-system-file :demo.sheet "sheet.lisp" :form)))
;;              (meta-revise (second (third original)) input)
;;              (setf (from-system-file :demo.sheet "sheet.lisp" :form) original)))

;;          (render (funcall context :medium)
;;                  (express (second (third (from-system-file :demo.sheet "sheet.lisp" :form)))))
         
         
;;          ;; (let ((out (make-string-output-stream)))
;;          ;;   (spinneret:interpret-html-tree
;;          ;;    ;; (render-fieldset (second (third (from-system-file :demo.sheet "sheet.lisp" :form))))
;;          ;;    (htrender (second (third (from-system-file :demo.sheet "sheet.lisp" :form)))
;;          ;;              :params (list :system :demo.sheet :branch :form))
;;          ;;    :stream out)
;;          ;;   (get-output-stream-string out))

;;          )
;;        :table
;;        (let ((original (from-system-file :demo.sheet "sheet.lisp" :table)))
;;          (lambda (context input)
;;            (when (fourth input)
;;              ;; only process input if fields apart form system/branch are present
;;              (meta-revise (second (third original)) input)
;;              ;; (setf (from-system-file :demo.sheet "sheet.lisp" :table) original)
;;              (let ((val-key :t) (unit-key) (count 0)
;;                    (vout (make-string-output-stream))
;;                    (uout (make-string-output-stream)))
;;                (format vout "#~%") (format uout "~%#~%")
;;                (loop :while val-key :for ix :from 0
;;                      :do (setf val-key  (intern (format nil "V-~a" ix) "KEYWORD")
;;                                unit-key (intern (format nil "U-~a" ix) "KEYWORD"))
;;                          (if (assoc val-key input)
;;                              (progn (when (= 5 count)
;;                                       (setf count 0)
;;                                       (format vout "~%#~%")
;;                                       (format uout "~%#~%"))
;;                                     (format vout "  ~a  |" (rest (assoc val-key  input)))
;;                                     (format uout " ~a |" (or (rest (assoc unit-key input))
;;                                                              "nounit"))
;;                                     (incf count))
;;                              (setf val-key nil)))
;;                ;; (print (list :st (concatenate 'string
;;                ;;                               (get-output-stream-string vout)
;;                ;;                               (get-output-stream-string uout))))
;;                (with-open-file (in-file "/tmp/input.txt"
;;         		                :direction :output :if-exists :supersede
;;                                         :if-does-not-exist :create)
;;                  (format in-file (get-output-stream-string vout))
;;                  (format in-file (get-output-stream-string uout))
;;                  ;; (loop :for char := (read-char vout) :while char :do (write-char char in-file))
;;                  ;; (loop :for char := (read-char uout) :while char :do (write-char char in-file))
;;                  )
;;                (uiop:run-program
;;                 (format nil "faketime 15-11-05 ~a ~a solve /tmp/input.txt /tmp/out.txt"
;;                         "~/src/old/dpneo/ecalc/app/ecalc"
;;                         "~/src/old/dpneo/ecalc/app/uc.json"))
;;                ))
;;            (let ((out (make-string-output-stream)))
;;              ;; TODO: REPLACE THIS
             
;;              ;; (spinneret:interpret-html-tree
;;              ;;  (htrender (second (third original))
;;              ;;            :params (list :system :demo.sheet :branch :table))
;;              ;;  :stream out)
;;              (get-output-stream-string out))))
;;        :esgraph
;;        (spec-graph-interface
;;         :package :demo.sheet :file-name "sheet.lisp" 
;;         :holder-id "esgraphOverview" :associated-node-ids #("graphNode")
;;         :node-template-key :esgraph-node-template :link-template-key :esgraph-link-template
;;         :graph-key :esgraph :node-indices-key :esgraph-node-indices)
;;        :graph
;;        (let ((interactor
;;                (spec-graph-interface
;;                 :package :demo.sheet :file-name "sheet.lisp"
;;                 :holder-id "graphOverview" :associated-node-ids #("graphNode")
;;                 :node-template-key :graph-node-template :link-template-key :graph-link-template
;;                 :graph-key :graph :node-indices-key :graph-node-indices)))
;;          (lambda (context input)
;;            (cbind input item
;;              ("state" :graph-breadth)
;;              ("ifmod-head" (dx ((:each uicc-button :type (:trigger :remote))
;;                                 (uic-series :type (:ui :controls)))
;;                                (list :add-node :add-link)))
;;              ("ifmod-foot" (dx ((:each uicc-button)
;;                               (uic-series :type (:ui :controls)))
;;                              (list :save)))
;;              (t (funcall interactor context input)))))
;;        :play
;;        (let ((state) (node) (selector))
;;          (lambda (context input)
;;            (unless (and (find-package 'demo.sheet)
;;                         (boundp (intern "*GRAPH-NODES*" "DEMO.SHEET")))
;;              (instantiate-priority-macro-reader (asdf:load-system :demo.sheet)))
;;            (unless node (multiple-value-bind (this-node selector-out)
;;                             (seed.generate::graph-walker
;;                              (first (symbol-value (intern "*GRAPH-NODES*" "DEMO.SHEET"))))
;;                           ;; (print (list :tn1 this-node input))
;;                           (setf node this-node selector selector-out)))
;;            (when (assoc :index input :test #'eq)
;;              (multiple-value-bind (this-node selector-out)
;;                  (funcall selector (read-from-string (rest (assoc :index input :test #'eq))))
;;                ;; (print (list :oo this-node))
;;                (setf node this-node selector selector-out)))
;;            ;; (print (list :bc input node))
;;            (let ((out (make-string-output-stream))
;;                  (dialog (rest (assoc :dialog (first node))))
;;                  (image (rest (assoc :image (first node))))
;;                  (responses (mapcar (lambda (item) (rest (assoc :dialog item)))
;;                                     (second node))))
;;              ;; (print (list :dia dialog node responses
;;              ;;              :image image))
;;              (spinneret:interpret-html-tree
;;               `(:div :class "scenario-frame"
;;                      (:div :class "setting" (:div :class "dialog" ,dialog))
;;                      (:ol :class "responses"
;;                           ,@(loop :for response :in responses :for ix :from 0
;;                                   :collect
;;                                   (list :li :|x-on:click|
;;                                         (psl (chain htmx (trigger $el "reload")))
;;                                         :hx-trigger "reload" :hx-post "/render/"
;;                                         :hx-vals (seed.generate::json-convert-to
;;                                                   (list :index ix))
;;                                         response)))
;;                      ,@(unless (string= image "no-image")
;;                          `((:div :class "background-image"
;;                                  :style
;;                                  ,(format nil " position: absolute; top: 0; left: 0;
;;                                                           margin-top: ~a; pointer-events: none;"
;;                                           (if (string= image "image-resting")
;;                                               "-200px" "-600px"))
;;                                  (:img :src ,(format nil "./static/~a.png" image)))))
;;                      )
;;               :stream out)
;;              (get-output-stream-string out))))

;;        ))

;; (-<> (uic ((:type :set :linear :columnar :workspace :even)
;;            (:members :column :column)
;;            (:point (if (not context) nil (funcall context :branch-point)))
;;            (:layout ((:row ((:column) (:column)))
;;                      (:row ((:column))
;;                            (:span . 2))
;;                      :divide
;;                      (:column)))
;;            (:faces ((:format :dual-bank))
;;                    ((:format :dual-bank))
;;                    ((:format :single-bank))))
;;          ;; (uic ((:type :form :elem) (:access :esgraph)
;;          ;;       (:name . :esgraph-overview)
;;          ;;       (:controls (:header :save :add-node :add-link :delete-item)
;;          ;;                  (:footer :save))))
;;          ;; (uic ((:type :form :elem) (:access :esgraph)
;;          ;;       (:name . :graph-node)
;;          ;;       (:controls (:header :save)
;;          ;;                  (:footer :save))))
;;          ;; :partition
;;          ;; (uic ((:type :form :text) (:access :main) (:name . :code)
;;          ;;       (:controls (:header :save)
;;          ;;                  (:footer :save))))
;;          ;; (uic ((:type :form :cells) (:access :cells) (:name . :cells)
;;          ;;       (:controls (:header :save :toggle-baseline)
;;          ;;                  (:footer :save))))
;;          ;; :partition
;;          ;; (uic ((:type :form :tree) (:access :code)
;;          ;;       (:controls (:header :save)
;;          ;;                  (:footer :save))))
;;          ;; (uic ((:type :form :vector) (:access :code) ;; what's this?
;;          ;;       (:controls (:header :save)
;;          ;;                  (:footer :save))))
;;          ;; (uic ((:type :form :vector) (:access :graph)
;;          ;;       (:controls (:header :save)
;;          ;;                  (:footer :save))))
;;          (uic ((:type :form :elem) (:access :graph)
;;                (:name . :graph-overview)
;;                (:controls (:header :save :add-node :add-link :delete-item)
;;                           (:footer :save))))
;;          (uic ((:type :form :elem) (:access :graph)
;;                (:name . :graph-node)
;;                (:controls (:header :save)
;;                           (:footer :save))))
;;          ;; (uic ((:type :form :elem) (:access :form)
;;          ;;       (:controls (:header :save)
;;          ;;                  (:footer :save))))
;;          ;; (uic ((:type :form :elem) (:access :table)
;;          ;;       (:name . :solver-input)
;;          ;;       (:controls (:header :submit)
;;          ;;                  (:footer :submit))))
;;          )
;;   (in-system-context <> :demo.sheet))
