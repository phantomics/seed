(defun build-script ()
  (build-script-element
   :path (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                        "./ui-browser.react/src/App.jsx")
   :imports '((-react "react")
              (j-query "jquery")
              (-react-d-o-m "react-dom/client")
              ((-c-container -c-spinner -c-row -c-col) "@coreui/react")
              "./main.scss"
              "./app.css")
   :constructors (list (lambda (stream)
                         (format stream (paren6::ps (define-fetch)
                                          (defvar |*__PS_MV_REG*|) ;; prevent crash
                                          (defvar components (create))
                                          (define-component-view)
                                          (defun -main-component ()
                                            (panic:jsl (:-seed-view)))))
                         (format stream "~%export default MainComponent")))))

;; (defun component-will-mount ()
;;   (let ((self this)
;;         (props (@ this props)))
;;     (transact "PORTAL.DEMO1" "VIEW"
;;               (create interface-spec (list "browser" "react"))
;;               (lambda (data)
;;                 (pcl :dt data)
;;                 (chain self (set-state (create data data)))))))

;; (defun component-did-update (next-props)
;;   (pcl :np next-props)
;;   )

;; (build-css "ui-browser.react")

;; (build-css "ui-browser")

;; Svelte utilities

;; to override spinneret's quoting behavior, change the definition of spinneret:needs-quotes?,
;; spinneret:must-quote? or spinneret:escape-value

;; (defmacro svbuild (&rest sections)
;;   `(with-html-string ,@(loop :for section :in sections
;;                              :append (case (first section)
;;                                        (:script `((:script (ps ,@(rest section)))))
;;                                        (:markup (rest section))))))

(defmacro svbuild (&rest sections)
  (let ((out-str (gensym)))
    `(let ((,out-str (make-string-output-stream)))
       (cl-who:with-html-output (,out-str)
         ,@(loop :for section :in sections
                 :append (case (first section)
                           (:script `((:script (ps ,@(rest section)))))
                           (:markup (rest section))))
         (get-output-stream-string ,out-str)))))

(defun without-last-semicolon (string)
  (if (not (char= #\; (aref string (1- (length string)))))
      string (subseq string 0 (1- (length string)))))

(defmacro svs (item) `(format nil "{~a}" (ps ,item)))

(defmacro psi (item) `(without-last-semicolon (ps ,item)))

(defmacro svi (item) `(format nil "{~a}" (without-last-semicolon (ps ,item))))

(defmacro sv-if (condition then)
  `(format nil "~%{#if ~a}~%~a~%{/if}" (psi ,condition) ,then))

(defmacro sv-if (&rest clauses)
  (let ((out-str (gensym)))
    `(let ((,out-str (make-string-output-stream)))
       ,@(loop :for clause :in clauses :for i :from 0
               :collect (destructuring-bind (condition &rest then) clause
                          (if condition `(format ,out-str "~%{~a ~a}~%~a"
                                                 ,(if (zerop i) "#if" ":else if")
                                                 (psi ,condition) ,@then)
                              `(format ,out-str "~%{:else}~%~a" ,@then))))
       (format ,out-str "~%{/if}~%")
       (get-output-stream-string ,out-str))))

(defmacro sv-each (vector as &rest do)
  (let ((out-str (gensym))
        (as (if (not (listp as)) as (first as)))
        (index (if (not (listp as)) nil (second as))))
    `(let ((,out-str (make-string-output-stream)))
       (format ,out-str "~%{#each ~a as ~a~a}~%~a~%{/each}"
               (psi ,vector) (psi ,as)
               (if (not index) "" (format " ,~a" index))
               ,@do)
       (get-output-stream-string ,out-str))))

(defmacro sv-await (&key expression waiting then catch)
  (let ((out-str (gensym)))
    (destructuring-bind (then-name &rest then) then
      (destructuring-bind (catch-name &rest catch) catch
        `(let ((,out-str (make-string-output-stream)))
           (format ,out-str "~%{#await ~a}~%~a~%{:then ~a}~%~a~%{:catch ~a}~%~a~%{/await}"
                   (psi ,expression) ,@waiting (psi ,then-name) ,@then
                   (psi ,catch-name) ,@catch)
           (format ,out-str "~%{/if}~%")
           (get-output-stream-string ,out-str))))))

;; Svelte build

(defun build-script-sv ()
  (with-open-file (stream (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
                                                         "./ui-browser.svelte/src/App2.svelte")
			  :direction :output :if-exists :supersede :if-does-not-exist :create)
    (format stream "<script>
  import svelteLogo from './assets/svelte.svg'
  import viteLogo from '/vite.svg'
  import Counter from './lib/Counter.svelte'
</script>
")

    (format stream
            (svbuild (:markup (:main
                               (:div (:a :href "https://vitejs.dev" :target "_blank" :rel "noreferrer"
                                         (:img :src (svi vite-logo) :class "logo"))
                                     (:a :href "https://svelte.dev" :target "_blank" :rel "noreferrer"
                                         (:img :src (svi svelte-logo) :class "logo svelte")))
                               (:h1 "Vite + Svelte")
                               (:div :class "card" (:|Counter|))
                               (:p "Check out " (:a :href "https://bloxl.co" "Stuff") " the official Svelte app stuff framework powered by Vite!")
                               (:p "Learn more.")))))))

;; (defun build-script-cmirror ()
;;   (with-open-file (stream (asdf:system-relative-pathname (intern (package-name *package*) "KEYWORD")
;;                                                          "./ui-browser/static/CM.js")
;; 			  :direction :output :if-exists :supersede :if-does-not-exist :create)
;;     (format stream "<script>
;; import {basicSetup, EditorView} from \"codemirror\"
;; import {EditorState, Compartment} from \"@codemirror/state\"
;; import {python} from \"@codemirror/lang-python\"
;; </script>
;; ")

;;     (format stream
;;             (svbuild (:markup (:main
;;                                (:div (:a :href "https://vitejs.dev" :target "_blank" :rel "noreferrer"
;;                                          (:img :src (svi vite-logo) :class "logo"))
;;                                      (:a :href "https://svelte.dev" :target "_blank" :rel "noreferrer"
;;                                          (:img :src (svi svelte-logo) :class "logo svelte")))
;;                                (:h1 "Vite + Svelte")
;;                                (:div :class "card" (:|Counter|))
;;                                (:p "Check out " (:a :href "https://bloxl.co" "Stuff") " the official Svelte app stuff framework powered by Vite!")
;;                                (:p "Learn more.")))))))
