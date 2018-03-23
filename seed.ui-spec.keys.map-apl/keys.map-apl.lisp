;;;; keys.map-apl.lisp

(in-package #:seed.ui-spec.keys.map-apl)

(specify-key-ui
 key-ui-map-apl
 ;; This is an orthodox APL keymap. It is unsuitable for use when using the meta key (ctrl on PC systems and
 ;; command on Apple systems) as the modifier because most browsers do not allow the reassignment of the
 ;; meta-N, meta-T and meta-W key combinations.
 :keymap
 ((write cmd (\` nil nil \◊)
	 (1 nil ! \¨ ⌶) (2 nil @ \¯ ⍫) (3 nil \# < ⍒) (4 nil $ ≤ ⍋) (5 nil % = ⌽) (6 nil ^ ≥ ⍉)
	 (7 nil & > ⊖) (8 nil * ≠ ⍟) (9 nil \( ∨ ⍱) (0 nil \) ∧ ⍲) (- nil _ × !) (= nil + ÷ ⌹)
         (q nil nil ?) (w nil nil ⍵ ⍹) (e nil nil ∊ ⍷) (r nil nil ⍴) (t nil nil \∼ ⍨) (y nil nil ↑ ¥)
	 (u nil nil ↓) (i nil nil ⍳ ⍸) (o nil nil ○ ⍥) (p nil nil ⋆ ⍣) ([ nil { ← ⍞) (] nil } → ⍬)
	 (\\ nil \| ⊢ ⊣) (a nil nil ⍺ ⍶) (s nil nil ⌈) (d nil nil ⌊) (f nil nil _ ⍫) (g nil nil ∇)
	 (h nil nil ∆ ⍙) (j nil nil ∘ ⍤) (k nil nil \' ⌺) (l nil nil ⎕ ⌷) (\; nil \: ⍎ ≡) (\' nil \" ⍕ ≢)
	 (z nil nil ⊂) (x nil nil ⊃ χ) (c nil nil ∩ ⍧) (v nil nil ∪) (b nil nil ⊥ £) (n nil nil ⊤)
	 (m nil nil \|) (\, nil < ⍝ ⍪) (\. nil > nil ⍀) (/ nil ? ⌿ ⍠))))

(specify-key-ui
 key-ui-map-apl-meta-specialized
 ;; This is an APL keymap specialized for use with the meta key in current browsers. Important characters
 ;; assigned to the N and W keys have been moved elsewhere. The tilde character assigned to T has simply been
 ;; removed since it is already present on most modern keyboards, and the commute operator ⍨ accessed by
 ;; pressing shift-meta-T has been reassigned to shift-meta-R.
 :keymap
 ((write meta (\` nil nil \◊)
	 (1 nil ! \¨ ⌶) (2 nil @ \¯ ⍫) (3 nil \# < ⍒) (4 nil $ ≤ ⍋) (5 nil % = ⌽) (6 nil ^ ≥ ⍉)
	 (7 nil & > ⊖) (8 nil * ≠ ⍟) (9 nil \( ∨ ⍱) (0 nil \) ∧ ⍲) (- nil _ × !) (= nil + ÷ ⌹)
         (q nil nil ?) (w nil nil nil ⍹) (e nil nil ∊ ⍷) (r nil nil ⍴ ⍨) (y nil nil ↑ ¥)
	 (u nil nil ↓) (i nil nil ⍳ ⍸) (o nil nil ○ ⍥) (p nil nil ⋆ ⍣) ([ nil { ← ⍞) (] nil } → ⍬)
	 (\\ nil \| ⊢ ⊣) (a nil nil ⍺ ⍶) (s nil nil ⌈) (d nil nil ⌊) (f nil nil ⍵ ⍫) (g nil nil ∇ _)
	 (h nil nil ∆ ⍙) (j nil nil ∘ ⍤) (k nil nil \' ⌺) (l nil nil ⎕ ⌷) (\; nil \: ⍎ ≡) (\' nil \" ⍕ ≢)
	 (z nil nil ⊂) (x nil nil ⊃ χ) (c nil nil ∩ ⍧) (v nil nil ∪) (b nil nil ⊥ £)
	 (m nil nil ⊤ \|) (\, nil < ⍝ ⍪) (\. nil > nil ⍀) (/ nil ? ⌿ ⍠))))
