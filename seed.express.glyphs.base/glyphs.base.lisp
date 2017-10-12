;;;; glyphs.base.lisp

(in-package #:seed.express.glyphs.base)

(specify-glyphs
 glyphs-base
 :default
 (((0 7)) ((2 14) (2 4) (0 2)))
 :type-is
 (("car"
   (((0 12)) ((4 13) (4 4)) ((2 13) (2 10) (0 8))))
  ("cdr"
   (((0 7)) ((4 13) (4 4)) ((2 10) (2 4) (0 2))))
  ("+" 
   (((0 7)) ((8 12) (8 8)) ((6 10) (6 6)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("-" 
   (((0 7)) ((8 10) (8 6)) ((6 12) (6 8)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("*" 
   (((0 7)) ((8 14) (8 8)) ((6 10) (6 6)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("/"
   (((0 7)) ((8 10) (8 4)) ((6 12) (6 8)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("expt" 
   (((0 7)) ((12 13) (12 9)) ((10 14) (10 8)) 
    ((8 14) (8 8)) ((6 10) (6 6)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("log"
   (((0 7)) ((12 9) (12 5)) ((10 10) (10 4)) 
    ((8 10) (8 4)) ((6 12) (6 8)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("sqrt"
   (((0 7)) ((10 10) (10 4)) ((8 10) (8 4)) ((6 12) (6 8)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("blank"
   (((0 8)) ((0 8) (0 0))))
  ("number"
   (((0 8)) ((2 10) (2 5) (0 3))))
  ("t"
   (((0 8)) ((0 7 17/2) (0 9) nil) ((4 10) (4 6)) ((2 10) (2 6) (0 4))))
  ("nil"
   (((0 8)) ((2 4) (0 2))))
  ("keyword"
   (((0 9)) ((0 9/2 19/2) (0 8) nil) ((3 0 4) (0 5) nil)))
  ("symbol"
   (((0 10)) ((3 0 5) (0 5) nil)))
  ("character"
   (((0 8)) ((0 5 15/2) (0 8) nil) ((2 10) (2 6) (0 4))))
  ("string"
   (((0 7)) ((4 14) (4 12)) ((4 11) (4 9)) ((4 8) (4 4))
    ((0 7 6) (0 10) nil) ((2 14) (2 4) (0 2))))
  ("form-function"
   (((0 7)) ((4 14) (4 6)) ((2 12) (2 4) (0 2))))
  ("form-macro"
   (((0 7)) ((4 12) (4 6)) ((2 14) (2 4) (0 2))))
  ("form-list"
   (((0 7)) ((0 5 5) (0 8) nil) ((2 14) (2 4) (0 2))))
  ("form-keyword-list"
   (((0 7)) ((0 5 15/2) (0 8) nil) ((0 5 5) (0 8) nil)
    ((2 14) (2 4) (0 2))))))
