;;;; test/test-modulate2.lisp
;;;;
;;;; Tests for seed.modulate2: IS inference and resolution, expression of fx
;;;; forms into manifestation trees, dx construction, Tier-1 defaults,
;;;; rendering for uim-web, and the modulate ↔ modulate2 bridge.
;;;;
;;;; Tests check manifestation trees and generated HTML trees (Spinneret lists),
;;;; not rendered strings, so they survive changes of markup.

(in-package #:seed.modulate2.test)

;;; =======================================================================
;;; IS inference and resolution
;;; =======================================================================

(in-suite m2-is)

(def-test infer-integer ()
  "An integer infers as :integer."
  (is (eq :integer (infer-data-character 42))))

(def-test infer-string ()
  "A string infers as :string."
  (is (eq :string (infer-data-character "hello"))))

(def-test infer-nil ()
  "NIL infers as :null."
  (is (eq :null (infer-data-character nil))))

(def-test infer-boolean ()
  "T infers as :boolean."
  (is (eq :boolean (infer-data-character t))))

(def-test infer-keyword ()
  "A keyword infers as :keyword."
  (is (eq :keyword (infer-data-character :foo))))

(def-test infer-symbol ()
  "A plain symbol infers as :symbol."
  (is (eq :symbol (infer-data-character 'foo))))

(def-test infer-float ()
  "A float infers as :float."
  (is (eq :float (infer-data-character 3.14))))

(def-test infer-list ()
  "A cons cell infers as :list."
  (is (eq :list (infer-data-character '(a b c)))))

(def-test resolve-is-explicit ()
  "An explicit IS without the :- sentinel is used as given."
  (is (equal '(:pathname) (resolve-is "foo" '(:pathname)))))

(def-test resolve-is-sentinel ()
  "The :- sentinel prepends the inferred type to the asserted specializers."
  (is (equal '(:string :pathname) (resolve-is "foo" '(:- :pathname)))))

(def-test resolve-is-nil ()
  "A nil explicit IS falls back to pure inference."
  (is (equal '(:integer) (resolve-is 42 nil))))

;;; =======================================================================
;;; Expression: fx → manifestation
;;; =======================================================================

(in-suite m2-expression)

(def-test express-atom-string ()
  "A bare string fx form becomes an mfn-atom with inferred :string IS."
  (let ((m (express-new '(fx "hello" (:by :observing)))))
    (is (typep m 'mfn-atom))
    (is (equal "hello" (mfn-value m)))
    (is (equal '(:string) (mfn-is m)))
    (is (equal '(:observing) (mfn-by m)))))

(def-test express-atom-integer ()
  "An integer fx form with :as :counter keeps its AS role."
  (let ((m (express-new '(fx 42 (:as :counter) (:by :observing)))))
    (is (typep m 'mfn-atom))
    (is (equal 42 (mfn-value m)))
    (is (equal '(:integer) (mfn-is m)))
    (is (member :counter (mfn-as m)))))

(def-test express-sequence ()
  "An fx list with sub-fx forms becomes an mfn-sequence with mfn-atom members."
  (let ((m (express-new '(fx ((fx "a" (:by :observing))
                              (fx "b" (:by :observing)))
                             (:by :observing)))))
    (is (typep m 'mfn-sequence))
    (is (= 2 (length (mfn-members m))))
    (is (every (lambda (c) (typep c 'mfn-atom)) (mfn-members m)))))

(def-test express-is-sentinel ()
  "The :- sentinel in fx metadata produces inferred + asserted IS."
  (let ((m (express-new '(fx "foo" (:is :- :pathname) (:by :observing)))))
    (is (typep m 'mfn-atom))
    (is (equal '(:string :pathname) (mfn-is m)))))

(def-test express-named-atom ()
  "A named fx form carries its name in the manifestation."
  (let ((m (express-new '(fx "x" (:name . :title) (:by :entering)))))
    (is (eq :title (mfn-name m)))))

;;; =======================================================================
;;; Construction: dx spec → manifestation
;;; =======================================================================

(in-suite m2-construct)

(def-test construct-atom ()
  "A dx spec with a single non-list child builds an mfn-atom."
  (let ((m (construct '(:by :observing :name :title) "hello")))
    (is (typep m 'mfn-atom))
    (is (equal "hello" (mfn-value m)))
    (is (eq :title (mfn-name m)))
    (is (equal '(:observing) (mfn-by m)))))

(def-test construct-nil-child ()
  "A dx spec with nil children builds an mfn-atom."
  (let ((m (construct '(:by :observing) nil)))
    (is (typep m 'mfn-atom))
    (is (null (mfn-value m)))))

(def-test construct-sequence ()
  "A dx spec with a list of children builds an mfn-sequence."
  (let ((m (construct '(:as :workspace :by :observing) (list "a" "b"))))
    (is (typep m 'mfn-sequence))
    (is (= 2 (length (mfn-members m))))
    (is (member :workspace (mfn-as m)))))

(def-test construct-layout ()
  "A (:layout ...) sub-form in :as is extracted into the layout slot."
  (let ((m (construct '(:as :workspace (:layout :horizontal :even) :by :observing)
                      (list "a" "b"))))
    (is (equal '(:horizontal :even) (mfn-layout m)))))

(def-test construct-valence ()
  "A (:valence ...) sub-form in :by is extracted into the valence slot."
  (let ((m (construct '(:by :observing (:valence (-2 4)))
                      (list "h1" "h2" "b1" "b2" "b3" "b4"))))
    (is (equal '(-2 4) (mfn-valence m)))))

(def-test construct-is-sentinel ()
  "The :- sentinel in a dx spec resolves IS through resolve-is."
  (let ((m (construct '(:is :- :pathname :by :observing) "/tmp/foo")))
    (is (typep m 'mfn-atom))
    (is (equal '(:string :pathname) (mfn-is m)))))

(def-test construct-is-inferred-when-absent ()
  "When no :is is given, IS is inferred from the value."
  (let ((m (construct '(:by :observing) 42)))
    (is (equal '(:integer) (mfn-is m)))))

(def-test construct-default-by ()
  "When no :by is given, the default is (:observing)."
  (let ((m (construct '(:name :x) "test")))
    (is (equal '(:observing) (mfn-by m)))))

(def-test construct-mixed-children ()
  "Manifestation and non-manifestation children mix in a sequence."
  (let* ((child (make-instance 'mfn-atom :value "pre-built" :by '(:observing)))
         (m (construct '(:by :observing) (list child "plain"))))
    (is (typep m 'mfn-sequence))
    (is (= 2 (length (mfn-members m))))
    (is (eq child (first (mfn-members m))))
    (is (typep (second (mfn-members m)) 'mfn-atom))))

;;; =======================================================================
;;; Controls and Tier-1 defaults
;;; =======================================================================

(in-suite m2-controls)

(def-test make-control-structure ()
  "make-control builds an mfn-atom with :activating modality and :controls AS."
  (let ((c (make-control :edit "Edit" '(0 1))))
    (is (typep c 'mfn-atom))
    (is (equal '(:activating) (mfn-by c)))
    (is (member :controls (mfn-as c)))
    (is (equal :edit (getf (mfn-value c) :action)))
    (is (equal "Edit" (getf (mfn-value c) :label)))
    (is (equal '(0 1) (getf (mfn-value c) :target)))))

(def-test reducing-injects-controls ()
  "The :reducing default injects a remove control into each member's controls."
  (let* ((m1 (make-instance 'mfn-atom :value "a" :by '(:observing)))
         (m2 (make-instance 'mfn-atom :value "b" :by '(:observing)))
         (seq (make-instance 'mfn-sequence
                             :value '("a" "b")
                             :by '(:reducing)
                             :members (list m1 m2))))
    (apply-modality-defaults (make-web-medium) seq)
    (is (= 1 (length (mfn-controls m1))))
    (is (= 1 (length (mfn-controls m2))))
    (is (eq :remove (getf (mfn-value (first (mfn-controls m1))) :action)))))

(def-test bare-suppresses-defaults ()
  "A sequence with :bare does not get Tier-1 affordances."
  (let* ((m1 (make-instance 'mfn-atom :value "a" :by '(:observing)))
         (seq (make-instance 'mfn-sequence
                             :value '("a")
                             :by '(:reducing :bare)
                             :members (list m1))))
    (apply-modality-defaults (make-web-medium) seq)
    (is (null (mfn-controls m1)))))

;;; =======================================================================
;;; Rendering: generate for uim-web
;;; =======================================================================

(in-suite m2-rendering)

(def-test render-observing-atom ()
  "An :observing atom renders as a span with the value."
  (let* ((m (make-instance 'mfn-atom :value "hello" :by '(:observing)))
         (tree (generate (make-web-medium) m)))
    (is (eq :span (tree-tag tree)))
    (is (search "observing" (tree-class tree)))
    (is (member "hello" (tree-children tree) :test #'equal))))

(def-test render-entering-atom ()
  "An :entering atom renders as a div containing a label and an input."
  (let* ((m (make-instance 'mfn-atom :value "val" :by '(:entering) :name :title))
         (tree (generate (make-web-medium) m)))
    (is (eq :div (tree-tag tree)))
    (is (search "entering" (tree-class tree)))))

(def-test render-activating-atom ()
  "An :activating control renders as a button with data-action."
  (let* ((m (make-control :save "Save" nil))
         (tree (generate (make-web-medium) m)))
    (is (eq :button (tree-tag tree)))
    (is (search "mfn-control" (tree-class tree)))
    (is (equal "save" (tree-attr tree :data-action)))))

(def-test render-sequence ()
  "A sequence renders as a div with mfn-item children."
  (let* ((m1 (make-instance 'mfn-atom :value "a" :by '(:observing)))
         (m2 (make-instance 'mfn-atom :value "b" :by '(:observing)))
         (seq (make-instance 'mfn-sequence
                             :value '("a" "b")
                             :by '(:observing)
                             :members (list m1 m2)))
         (tree (generate (make-web-medium) seq)))
    (is (eq :div (tree-tag tree)))
    (is (search "mfn-sequence" (tree-class tree)))))

(def-test render-provision-text-server ()
  "A :provision-text atom with a (system branch) value renders a div with x-init."
  (let* ((m (make-instance 'mfn-atom
                           :value '(:demo.access :cms)
                           :by '(:provision-text)
                           :name :text))
         (tree (generate (make-web-medium) m)))
    (is (eq :div (tree-tag tree)))
    (is (search "provision-text" (tree-class tree)))
    (is (tree-attr tree :x-init))))

(def-test render-provision-text-direct ()
  "A :provision-text atom with a string value renders a div with data-content."
  (let* ((m (make-instance 'mfn-atom
                           :value "some text"
                           :by '(:provision-text)
                           :name :editor))
         (tree (generate (make-web-medium) m)))
    (is (eq :div (tree-tag tree)))
    (is (search "provision-text" (tree-class tree)))
    (is (equal "some text" (tree-attr tree :data-content)))))

(def-test render-provision-form-stub ()
  "A :provision-form atom renders a form element (currently a stub)."
  (let* ((m (make-instance 'mfn-atom
                           :value nil
                           :by '(:provision-form)
                           :name :article))
         (tree (generate (make-web-medium) m)))
    (is (eq :form (tree-tag tree)))
    (is (search "provision-form" (tree-class tree)))))

(def-test render-with-controls ()
  "An atom with injected controls gets wrapped with a header."
  (let* ((m (make-instance 'mfn-atom :value "x" :by '(:observing)))
         (c (make-control :remove "×" nil)))
    (push c (mfn-controls m))
    (let ((tree (generate (make-web-medium) m)))
      (is (eq :div (tree-tag tree)))
      (is (search "mfn-item-wrap" (tree-class tree))))))

;;; =======================================================================
;;; Bridge: modulate ↔ modulate2
;;; =======================================================================

(in-suite m2-bridge)

(def-test bridge-express-hook-set ()
  "The *express-foreign* hook is a function after modulate2 loads."
  (is (functionp seed.modulate::*express-foreign*)))

(def-test bridge-generate-hook-set ()
  "The *generate-foreign* hook is a function after modulate2 loads."
  (is (functionp seed.modulate::*generate-foreign*)))

(def-test bridge-dx-hook-set ()
  "The *dx-foreign* hook is a function after modulate2 loads."
  (is (functionp seed.modulate::*dx-foreign*)))

(def-test bridge-generate-delegates-to-modulate ()
  "A string passed to modulate2's generate delegates to modulate's generate."
  (let ((result (generate (make-web-medium) "plain string")))
    (is (equal "plain string" result))))

(def-test bridge-dx-new-grammar ()
  "The dx macro with keyword specs produces a manifestation via the bridge."
  (let ((m (seed.modulate::dx (:by :observing :name :test) "hello")))
    (is (typep m 'mfn-atom))
    (is (equal "hello" (mfn-value m)))
    (is (eq :test (mfn-name m)))))
