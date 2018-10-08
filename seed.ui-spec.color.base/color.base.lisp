;;;; seed.ui-spec.color.base.lisp

(in-package #:seed.ui-spec.color.base)

(defvar palette-hicontrast-solarized)
(defvar palette-medcontrast-adjunct)
(defvar palette-medcontrast-dropcloth)

(setq palette-hicontrast-solarized
      (list :base03 "#002b36" :base02 "#073642" :base01 "#586e75"
	    :base00 "#657b83" :base0 "#839496" :base1 "#93a1a1"
	    :base2 "#eee8d5" :base3 "#fdf6e3" :yellow "#b58900"
	    :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	    :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	    :green "#859900")
      palette-medcontrast-adjunct
      (list :base03 "#262625" :base02 "#2f3033" :base01 "#676b71"
	    :base00 "#707784" :base0 "#89919e" :base1 "#9a9ea5"
	    :base2 "#e6e8ec" :base3 "#f7f6f5" :yellow "#b38a39"
	    :orange "#bd5a34" :red "#c94f42" :magenta "#be527e"
	    :violet "#6874af" :blue "#408abc" :cyan "#509d95"
	    :green "#919637")
      palette-medcontrast-dropcloth
      (list :base03 "#262625" :base02 "#33302d" :base01 "#716964"
	    :base00 "#83746a" :base0 "#9e8e83" :base1 "#a59c97"
	    :base2 "#ece7e4" :base3 "#f7f6f5" :yellow "#b38a39"
	    :orange "#bd5a34" :red "#c94f42" :magenta "#be527e"
	    :violet "#6874af" :blue "#408abc" :cyan "#509d95"
	    :green "#919637"))

#|
purple palette
(:adjunct :base03 "#242434" :base02 "#2F2F3F" :base01 "#73676E"
	  :base00 "#817477" :base0 "#9D8D8D" :base1 "#AC9A97"
	  :base2 "#F8E5D5" :base3 "#FFF3E2" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

faded
(hex-express (lab-palette (15 2 -4) (20 2 -4) (45 1 -3) (50 1 -3) (60 1 -3) (65 1 -3) (92 0 -2) (97 0 -2)))

more faded
(:adjunct :base03 "#26252B" :base02 "#313036" :base01 "#6E6969"
	  :base00 "#7B7676" :base0 "#968F8D" :base1 "#A39D9A"
	  :base2 "#EFE7E0" :base3 "#FCF3ED" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

brown faded
(hex-express (lab-palette (15 6 2) (20 6 2) (45 4 3) (50 4 3) (60 3 4) (65 3 4) (92 1 2) (97 1 2)))

(:adjunct :base03 "#2F2323" :base02 "#3A2D2E" :base01 "#736866"
	  :base00 "#807572" :base0 "#998F8A" :base1 "#A69C97"
	  :base2 "#ECE7E4" :base3 "#FAF6F3" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

gray through blue
(hex-express (lab-palette (15 0 0.6) (20 0 -2) (45 0 -4) (50 0 -8) (60 0 -8) (65 0 -4) (92 0 -2) (97 0 0.6)))

(:adjunct :base03 "#242628" :base02 "#2F3033" :base01 "#676B71"
	  :base00 "#707784" :base0 "#89919E" :base1 "#9A9EA5"
	  :base2 "#E6E8EC" :base3 "#F4F6FA" :yellow "#b58900"
	  :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
	  :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
	  :green "#859900")

gray through brown
(hex-express (lab-palette (15 1 2) (20 1 2) (45 2 4) (50 4 8) (60 4 8) (65 2 4) (92 1 2) (97 1 2)))
(:BASE03 "#282523" :BASE02 "#33302D" :BASE01 "#716964" :BASE00 "#83746A" :BASE0
 "#9E8E83" :BASE1 "#A59C97" :BASE2 "#ECE7E4" :BASE3 "#FAF6F3")
- more gray at ends
(hex-express (lab-palette (15 0.16 0.6) (20 1 2) (45 2 4) (50 4 8) (60 4 8) (65 2 4) (92 1 2) (97 0.16 0.6)))
(:BASE03 "#262625" :BASE02 "#33302D" :BASE01 "#716964" :BASE00 "#83746A" :BASE0
 "#9E8E83" :BASE1 "#A59C97" :BASE2 "#ECE7E4" :BASE3 "#F7F6F5")


orange peak
(hex-express (lab-palette (15 8 4) (20 8 4) (45 24 16) (50 50 50) (60 50 50) (65 16 24) (92 0 2) (97 0 2)))

orange peak to cinnamon
(hex-express (lab-palette (15 12 6) (20 12 6) (45 24 16) (50 50 50) (60 50 50) (65 16 24) (92 0 2) (97 0 2)))


50% hues
(:yellow "#AB8C58" :orange "#AA654A" :red "#B26053" :magenta "#A9627C"
	 :violet "#6E759C" :blue "#5F88A9" :cyan "#699995" :green "#939457")

75% hues
(:yellow "#B38A39" :orange "#BD5A34" :red "#C94F42" :magenta "#BE527E"
	 :violet "#6874AF" :blue "#408ABC" :cyan "#509D95" :green "#919637")

|#


;; (css-styles (with :palettes ((:standard :base03 "#002b36" :base02 "#073642" :base01 "#586e75"
;; 			   				 :base00 "#657b83" :base0 "#839496" :base1 "#93a1a1"
;; 			   				 :base2 "#eee8d5" :base3 "#fdf6e3" :yellow "#b58900"
;; 			   				 :orange "#cb4b16" :red "#dc322f" :magenta "#d33682"
;; 			   				 :violet "#6c71c4" :blue "#268bd2" :cyan "#2aa198"
;; 			   				 :green "#859900"))
;; 		  :palette-contexts (:holder))
;; 	    css-form-view)
