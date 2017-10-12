;;;; test-load.lisp

; The code in this file is loaded by test.lisp to test the priority macro reader.

(princ (format nil "~%  Collapse of meta forms in read phase:~%"))
(is (META (+ 1 2)) 
    3)

(princ (format nil "~%  Applying format macros during meta form collapse:~%"))
(is (META (2 2) :FORMAT FORMAT-ADD)
    (format-add (2 2)))

(is (META (+ 1 2) :FORMAT FORMAT-INCREMENT-NUMBERS)
    (format-increment-numbers (+ 1 2)))

