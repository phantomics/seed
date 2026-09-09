;; catalog.lisp
;; A Philo-accessed data catalog. This file is NOT loaded by ASDF; it is read
;; at runtime, section by section, by the `philo' accessor. Each keyword is a
;; key; the fx forms after it are that key's value region.
;;
;; The fx forms use the IS/AS/BY ontology (seed.modulate2):
;;   :is  - data character (omitted here; inferred from the Lisp type)
;;   :as  - semantic role  (e.g. :counter for the quantities)
;;   :by  - interaction modality (:observing throughout - a read-only view)

:tools
(fx "Hammer"      (:name . :tool-1) (:by :observing))
(fx "Screwdriver" (:name . :tool-2) (:by :observing))
(fx "Wrench"      (:name . :tool-3) (:by :observing))
(fx "Pliers"      (:name . :tool-4) (:by :observing))

:quantities
(fx 42 (:name . :qty-hammer)      (:as :counter) (:by :observing))
(fx 17 (:name . :qty-screwdriver) (:as :counter) (:by :observing))
(fx 83 (:name . :qty-wrench)      (:as :counter) (:by :observing))

:colors
(fx "Red"    (:name . :color-1) (:by :observing))
(fx "Blue"   (:name . :color-2) (:by :observing))
(fx "Green"  (:name . :color-3) (:by :observing))
(fx "Yellow" (:name . :color-4) (:by :observing))
(fx "Violet" (:name . :color-5) (:by :observing))
