;;;; seed.ui-spec.keys.map-apl.lisp

(in-package #:seed.ui-spec.keys.map-apl)

(specify-key-ui
 key-ui-map-apl
 :keymap
 ((write (` nil nil \◊)
	 (1 nil ! \¨ ⌶) (2 nil @ \¯ ⍫) (3 nil \# < ⍒) (4 nil $ ≤ ⍋) (5 nil % = ⌽) (6 nil ^ ≥ ⍉)
	 (7 nil & > ⊖) (8 nil * ≠ ⍟) (9 nil \( ∨ ⍱) (0 nil \) ∧ ⍲) (- nil _ × !) (= nil + ÷ ⌹)
         (q nil nil ?) (w nil nil ⍵ ⍹) (e nil nil ∊ ⍷) (r nil nil ⍴) (t nil nil \∼ ⍨) (y nil nil ↑ ¥)
	 (u nil nil ↓) (i nil nil ⍳ ⍸) (o nil nil ○ ⍥) (p nil nil ⋆ ⍣) ([ nil { ← ⍞) (] nil } → ⍬)
	 (\\ nil nil ⊢ ⊣) (a nil nil ⍺ ⍶) (s nil nil ⌈) (d nil nil ⌊) (f nil nil _ ⍫) (g nil nil ⍵ ∇)
	 (h nil nil ∆ ⍙) (j nil nil ∘ ⍤) (k nil nil \' ⌺) (l nil nil ⎕ ⌷) (\; nil \: ⍎ ≡) (\' nil \" ⍕ ≢)
	 (z nil nil ⊂) (x nil nil ⊃ χ) (c nil nil ∩ ⍧) (v nil nil ∪) (b nil nil ⊥ £) (n nil nil ⊤)
	 (m nil nil \|) (\, nil < ⍝ ⍪) (\. nil > nil ⍀) (/ nil ? ⌿ ⍠))))
