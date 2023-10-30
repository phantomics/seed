;;; lib.lisp

(in-package #:demo.sheet)

(defvar *cell-matrix*)

(april (with (:space sheet-space))
       "cellRange ← {
  cols ← 26∘⊤⍣¯1¨{⍵⊆⍨×⍵}{⍵×27>⍵}     ⎕A⍳⍵
  rows ← 10∘⊤⍣¯1¨{⍵⊆⍨×⍵}{⍵×10>⍵}⎕IO-⍨⎕D⍳⍵
  {(⊂⊃¨⍵)+¨⎕IO-⍨⍳1+|-/¨⍵} rows cols
}")

(defmacro for-cells (cells function)
  `(setf *cell-matrix*
         (april-c (with (:space sheet-space))
                  ,(format nil "{X←⍵ ⋄ X[cellRange '~a']←~a X[cellRange '~a'] ⋄ X}"
                           cells function cells)
                  *cell-matrix*)))

;; (for-cells "C2.G8" "{5+⍵}")

;; (april-c "{X←⍵ ⋄ X[cellRange 'C2.G8']←{5+⍵} X[cellRange 'C2.G8'] ⋄ X}" *cell-matrix*)
