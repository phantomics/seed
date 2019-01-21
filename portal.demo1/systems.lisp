(META
 ((META :PORTAL.DEMO1 :MODE (:VIEW :PORTAL-NAME))
  (META "demo-sheet" :MODE
        (:VIEW :SELECT :OPTIONS
         ((:VALUE "demo-sheet" :TITLE "demoSheet")
          (:VALUE "demo-graph" :TITLE "demoGraph")
          (:VALUE "demo-image" :TITLE "demoImage")
          (:VALUE "demo-drawing" :TITLE "demoDrawing")
          (:VALUE "demo-market" :TITLE "demoMarket"))))
  (META
   ((META :MAIN :MODE (:TARGET :MAIN :VIEW :BRANCH-SELECTOR))
    (META :IMAGE :MODE (:TARGET :IMAGE :VIEW :BRANCH-SELECTOR)))
   :EACH (:MODE (:INTERACTION :SELECT-BRANCH)) :MODE
   (:VALUE NIL :MODEL
    ((META :MAIN :MODE (:TARGET :MAIN :VIEW :BRANCH-SELECTOR))
     (META :IMAGE :MODE (:TARGET :IMAGE :VIEW :BRANCH-SELECTOR)))
    :SETS (2) :INDEX 0 :VIEW :SYSTEM-BRANCH-LIST)))
 :MODE
 (:VALUE NIL :MODEL
  ((META :PORTAL.DEMO1 :MODE (:VIEW :PORTAL-NAME))
   (META "demo-sheet" :MODE
         (:VIEW :SELECT :OPTIONS
          ((:VALUE "demo-sheet" :TITLE "demoSheet")
           (:VALUE "demo-graph" :TITLE "demoGraph")
           (:VALUE "demo-image" :TITLE "demoImage")
           (:VALUE "demo-drawing" :TITLE "demoDrawing")
           (:VALUE "demo-market" :TITLE "demoMarket"))))
   (META
    ((META :MAIN :MODE (:TARGET :MAIN :VIEW :BRANCH-SELECTOR))
     (META :IMAGE :MODE (:TARGET :IMAGE :VIEW :BRANCH-SELECTOR)))
    :EACH (:MODE (:INTERACTION :SELECT-BRANCH)) :MODE
    (:VALUE NIL :MODEL
     ((META :MAIN :MODE (:TARGET :MAIN :VIEW :BRANCH-SELECTOR))
      (META :IMAGE :MODE (:TARGET :IMAGE :VIEW :BRANCH-SELECTOR)))
     :SETS (2) :INDEX 0 :VIEW :SYSTEM-BRANCH-LIST)))
  :ENCLOSE :ENCLOSE-OVERVIEW :FILL :FILL-OVERVIEW :NAME :PORTAL-SPECS :LAYOUT
  :COLUMN :BREADTH :SHORT :VIEW :VISTA))
