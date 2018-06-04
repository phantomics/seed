(IN-PACKAGE #:DEMO-SHEET)
(DEFVAR GEN-SPACE-APL)
(SETQ GEN-SPACE-APL "addWalls←{⍺,(⍵[;;1+⍳(3⌷⍴⍵)-2]),⍺}
addFloor←{⍵[;⍳(2⌷⍴⍵)-1;],[2]⍺}

field←16 16 16⍴0
field←1 addWalls (2 addFloor field)
field[;5 6;4]←3
field[8;4;6]←4
field[8;8;]←1
field")
(DEFVAR GENERATED-SPACE)
(SETQ GENERATED-SPACE (ARRAY-TO-NESTED-VECTOR (APRIL GEN-SPACE-APL)))
(DEFVAR DOCUMENT-CONTENT)
(SETQ DOCUMENT-CONTENT
        (SEED.APP-MODEL.DOCUMENT-SLATE.BASE:DOCUMENT-AS-HTML
         (:DOCUMENT
          (:NODES
           ((:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Line 2." :KIND "leaf")) :KIND
               "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:LEAVES
               ((:MARKS NIL :TEXT "Another line altered again." :KIND "leaf"))
               :KIND "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Test." :KIND "leaf")) :KIND "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Hello" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "section" :KIND "block")
              (:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Testing 123" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "section" :KIND "block")
              (:NODES
               ((:LEAVES
                 ((:MARKS NIL :TEXT "Hello " :KIND "leaf")
                  (:MARKS ((:DATA NIL :TYPE "bold" :KIND "mark")) :TEXT
                   "again 3" :KIND "leaf")
                  (:MARKS NIL :TEXT "." :KIND "leaf"))
                 :KIND "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "section" :KIND "block"))
             :DATA NIL :IS-VOID :FALSE :TYPE "quote" :KIND "block")
            (:NODES
             ((:LEAVES
               ((:MARKS NIL :TEXT "Back " :KIND "leaf")
                (:MARKS ((:DATA NIL :TYPE "bold" :KIND "mark")) :TEXT "to"
                 :KIND "leaf")
                (:MARKS NIL :TEXT " normal again." :KIND "leaf"))
               :KIND "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Test 123, hello." :KIND "leaf"))
                 :KIND "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Test again." :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Tested" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Test" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block"))
             :DATA NIL :IS-VOID :FALSE :TYPE "count" :KIND "block")
            (:NODES
             ((:LEAVES
               ((:MARKS ((:DATA NIL :TYPE "italic" :KIND "mark")) :TEXT
                 "Testing" :KIND "leaf"))
               :KIND "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Hello" :KIND "leaf")) :KIND "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Testing 123" :KIND "leaf")) :KIND
               "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Point test" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES
                 ((:MARKS ((:DATA NIL :TYPE "bold" :KIND "mark")) :TEXT
                   "Tested again" :KIND "leaf"))
                 :KIND "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES
                 ((:MARKS NIL :TEXT "Hello " :KIND "leaf")
                  (:MARKS ((:DATA NIL :TYPE "italic" :KIND "mark")) :TEXT "123"
                   :KIND "leaf"))
                 :KIND "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES
                 ((:MARKS ((:DATA NIL :TYPE "bold" :KIND "mark")) :TEXT
                   "Tested" :KIND "leaf"))
                 :KIND "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block"))
             :DATA NIL :IS-VOID :FALSE :TYPE "points" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "At the end." :KIND "leaf")) :KIND
               "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Another paragraph." :KIND "leaf"))
               :KIND "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Paragraph 2." :KIND "leaf")) :KIND
               "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "List." :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Item 2" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block")
              (:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Item 3" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "member" :KIND "block"))
             :DATA NIL :IS-VOID :FALSE :TYPE "points" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Paragraph" :KIND "leaf")) :KIND
               "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block")
            (:NODES
             ((:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Quote 1" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "section" :KIND "block")
              (:NODES
               ((:LEAVES ((:MARKS NIL :TEXT "Quote 2" :KIND "leaf")) :KIND
                 "text"))
               :DATA NIL :IS-VOID :FALSE :TYPE "section" :KIND "block"))
             :DATA NIL :IS-VOID :FALSE :TYPE "quote" :KIND "block")
            (:NODES
             ((:LEAVES ((:MARKS NIL :TEXT "Continued" :KIND "leaf")) :KIND
               "text"))
             :DATA NIL :IS-VOID :FALSE :TYPE "paragraph" :KIND "block"))
           :DATA NIL :KIND "document")
          :KIND "value")))
(DEFVAR GRAPH-CONTENT)
(SETQ GRAPH-CONTENT
        '(GRAPH-STEPS
          (#:G1573 :TYPE :OPTION :CONTENT "Hello" :LINKS
           ((#:G1574 :CONTENT "To Next")))
          (#:G1574 :TYPE :OPTION :CONTENT "Next" :LINKS
           ((#:G1573 :CONTENT "Go Back")))))
(DEFVAR MAIN-TABLE)
(SETQ MAIN-TABLE
        #2A((NIL NIL (:DATA-COM (16) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            ((:DATA-COM (35) :TYPE :NUMBER) (:DATA-INP 11 :TYPE :NUMBER) NIL
             NIL NIL NIL (:DATA-COM (3) :TYPE :NUMBER)
             (:DATA-COM (3) :TYPE :NUMBER) NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL (:TYPE :NUMBER :DATA-INP 95)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (10 7) :TYPE :NUMBER) (:DATA-COM (10 7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (14 7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER) NIL
             NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:TYPE :NUMBER :DATA-INP 5) NIL NIL
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (10 7) :TYPE :NUMBER) (:DATA-COM (10 7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (14 7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER) NIL
             NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL (:DATA-COM (3) :TYPE :NUMBER)
             (:DATA-COM (3) :TYPE :NUMBER) (:DATA-COM (13.75 3) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (39.25 36.25 13) :TYPE :NUMBER)
             (:DATA-COM (10 7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (14 7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:TYPE :NUMBER :DATA-INP 2)
             (:DATA-COM (5) :DATA-INP 2 :TYPE :NUMBER)
             (:DATA-COM (6) :DATA-INP 3 :TYPE :NUMBER)
             (:DATA-COM (13.75 3) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (10 7) :TYPE :NUMBER) (:DATA-COM (10 7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (14 7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER) NIL
             NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:DATA-COM ("function") :ARGS-COUNT 1 :TYPE :FUNCTION)
             (:DATA-COM (3) :TYPE :NUMBER) (:DATA-COM (3) :TYPE :NUMBER)
             (:DATA-COM (13.75 3) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (14 7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER) NIL
             NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL (:DATA-COM (3) :TYPE :NUMBER)
             (:DATA-COM (3) :TYPE :NUMBER) (:DATA-COM (13.75 3) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (14 7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL (:DATA-COM (3) :TYPE :NUMBER)
             (:DATA-COM (3) :TYPE :NUMBER) (:DATA-COM (13.75 3) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (16 4) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (14 7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (14 7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL)
            ((:DATA-COM (2) :TYPE :NUMBER) (:DATA-COM (2) :TYPE :NUMBER)
             (:DATA-COM (2) :TYPE :NUMBER) (:DATA-COM (2) :TYPE :NUMBER)
             (:DATA-COM (9 7) :TYPE :NUMBER) (:DATA-COM (9 7) :TYPE :NUMBER)
             (:DATA-COM (9 7) :TYPE :NUMBER) (:DATA-COM (9 7) :TYPE :NUMBER)
             (:DATA-COM (9 7) :TYPE :NUMBER) (:DATA-COM (9 7) :TYPE :NUMBER)
             (:DATA-COM (18 9 7) :TYPE :NUMBER) (:DATA-COM (9 7) :TYPE :NUMBER)
             (:DATA-COM (2) :TYPE :NUMBER) (:DATA-COM (2) :TYPE :NUMBER)
             (:DATA-COM (2) :TYPE :NUMBER) (:DATA-COM (2) :TYPE :NUMBER)
             (:DATA-COM (2) :TYPE :NUMBER) (:DATA-COM (2) :TYPE :NUMBER)
             (:DATA-COM (2) :TYPE :NUMBER) (:DATA-COM (2) :TYPE :NUMBER))
            (NIL NIL (:TYPE :NUMBER :DATA-INP 5) (:DATA-COM (4) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER)
             (:DATA-COM (14 7) :TYPE :NUMBER) (:DATA-COM (7) :TYPE :NUMBER) NIL
             NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:TYPE "STRING" :DATA-INP "Hello") NIL
             (:DATA-COM (4) :TYPE :NUMBER) NIL NIL NIL
             (:DATA-COM (10) :TYPE :NUMBER) NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL (:TYPE :STRING) NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL (:DATA-COM (8) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL NIL)
            (NIL NIL NIL NIL NIL NIL NIL NIL NIL NIL
             (:DATA-COM (0) :TYPE :NUMBER) NIL NIL NIL NIL NIL NIL NIL NIL
             NIL)))
(IN-TABLE MAIN-TABLE (CELL "a2" 32) (CELL "g9" (/ 6 2))
 (CELL "c1" (+ 8 (META 3 :COMMENT "This is a test comment.") 5)) (CELL "g5" 13)
 (CELL "d12" (- 20 6 (EXPT 2 3) 2)) (CELLS "c5" "e9" (+ 3 VAL-NUMBER))
 (CELL "b7" (LAMBDA (C) (+ 4 C)))
 (CELLS "e3" "l12" (+ 7 (* 1.25 VAL-NUMBER) VAL-NUMBER))
 (CELLS "g2" "h6" (+ 1 2 VAL-NUMBER)) (CELL "d13" (CELL-UP))
 (CELL "h13" (CELL-UP 8)) (ROW 11 (+ 1 (+ 1 VAL-NUMBER)))
 (COL "k" (* 2 VAL-NUMBER)) (CELL "d16" (FUNCALL (CELL "b7") (CELL "d12"))))
