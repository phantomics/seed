(IN-PACKAGE #:TEST-TABLE)
(DEFVAR MAIN-TABLE NIL)
(SETQ MAIN-TABLE
        #2A((NIL NIL (:DATA-COM (13) :TYPE "number") NIL NIL NIL NIL NIL NIL
             NIL (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            ((:DATA-COM (31) :TYPE "number") NIL NIL NIL NIL NIL
             (:DATA-COM (3) :TYPE "number") (:DATA-COM (3) :TYPE "number") NIL
             NIL (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (10 7) :TYPE "number")
             (:DATA-COM (10 7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:TYPE "NUMBER" :DATA-INP 1) NIL NIL
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (10 7) :TYPE "number")
             (:DATA-COM (10 7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL (:DATA-COM (3) :TYPE "number")
             (:DATA-COM (3) :TYPE "number") (:DATA-COM (55/4 3) :TYPE "number")
             (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (65/2 59/2 10) :TYPE "number")
             (:DATA-COM (10 7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:TYPE "NUMBER" :DATA-INP 1)
             (:DATA-COM (5) :DATA-INP 2 :TYPE "number")
             (:DATA-COM (6) :DATA-INP 3 :TYPE "number")
             (:DATA-COM (55/4 3) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (10 7) :TYPE "number")
             (:DATA-COM (10 7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:ARGS-COUNT 1 :DATA-COM ("function") :TYPE "function")
             (:DATA-COM (3) :TYPE "number") (:DATA-COM (3) :TYPE "number")
             (:DATA-COM (55/4 3) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (14 7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL (:DATA-COM (3) :TYPE "number")
             (:DATA-COM (3) :TYPE "number") (:DATA-COM (55/4 3) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL (:DATA-COM (3) :TYPE "number")
             (:DATA-COM (3) :TYPE "number") (:DATA-COM (55/4 3) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (16 4) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            ((:TYPE "number" :DATA-COM (2)) (:TYPE "number" :DATA-COM (2))
             (:TYPE "number" :DATA-COM (2)) (:TYPE "number" :DATA-COM (2))
             (:DATA-COM (9 7) :TYPE "number") (:DATA-COM (9 7) :TYPE "number")
             (:DATA-COM (9 7) :TYPE "number") (:DATA-COM (9 7) :TYPE "number")
             (:DATA-COM (9 7) :TYPE "number") (:DATA-COM (9 7) :TYPE "number")
             (:DATA-COM (18 9 7) :TYPE "number")
             (:DATA-COM (9 7) :TYPE "number") (:TYPE "number" :DATA-COM (2))
             (:TYPE "number" :DATA-COM (2)) (:TYPE "number" :DATA-COM (2))
             (:TYPE "number" :DATA-COM (2)) (:TYPE "number" :DATA-COM (2))
             (:TYPE "number" :DATA-COM (2)) (:TYPE "number" :DATA-COM (2))
             (:TYPE "number" :DATA-COM (2)))
            (NIL NIL (:DATA-INP-OVR "5" :TYPE "NUMBER" :DATA-INP 2)
             (:DATA-COM (24) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") (:DATA-COM (14 7) :TYPE "number")
             (:DATA-COM (7) :TYPE "number") NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:TYPE "STRING" :DATA-INP "Hello") NIL
             (:DATA-COM (24) :TYPE "number") NIL NIL NIL
             (:DATA-COM (10) :TYPE "number") NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL (:TYPE "string" :DATA-COM ("HELLO")) NIL NIL NIL NIL NIL NIL
             NIL NIL (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL
             NIL NIL)
            (NIL NIL NIL (:DATA-COM (28) :TYPE "number") NIL NIL NIL NIL NIL
             NIL (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:TYPE "number" :DATA-COM (0)) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)))
(IN-TABLE MAIN-TABLE (CELL "a2" 31) (CELL "g9" 4)
 (CELL "c1" (+ 8 (META 3 :COMMENT "This is a test comment.") 5)) (CELL "g5" 10)
 (CELL "d12" (+ 4 6 8 2)) (CELLS "c5" "e9" (+ 3 VAL-NUMBER))
 (CELL "b7" (LAMBDA (C) (+ 4 C)))
 (CELLS "e3" "l12" (+ 7 (* 1.25 VAL-NUMBER) VAL-NUMBER))
 (CELLS "g2" "h6" (+ 1 2 VAL-NUMBER)) (CELL "d13" (CELL-UP))
 (CELL "h13" (CELL-UP 8)) (CELL "b15" (STRING-UPCASE (CELL-UP 2)))
 (ROW 11 (+ 1 (+ 1 VAL-NUMBER))) (COL "k" (* 2 VAL-NUMBER))
 (CELL "d16" (FUNCALL (CELL "b7") (CELL "d12"))))
