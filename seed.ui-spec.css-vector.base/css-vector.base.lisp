;;;; css-vector.base.lisp

(in-package #:seed.ui-spec.css-vector.base)

(defmacro css-ivector-standard ()
  "Main CSS styles for Seed's interface."
  `("/* Portal styles */
  @keyframes animatedBackground {
    from { background-position: 0 50px; }
    to { background-position: 0 0; }}"
    (body :overflow hidden
          :height 100%
          :width 100%
          (.breaker :clear both))

    (.vector-interface
     :height 100%
     :width 100%

     ;; high-level portal styles
     (.link
      :fill none
      :stroke "#ccc"
      :stroke-width 1.5px)

     (.icon-title-frame
      ((:or rect circle)
       :fill "#eee8d5"))

     (.expand-control
      (.button-backing :fill "#fdf6e3")
      (.button-circle :fill "#839496")
      (rect :fill "#fdf6e3"))

     (.glyph
      (.outer-circle :fill "#dc322f")
      (.inner-circle :fill "#fdf6e3")))))



#|
.visualizer-container {
    path.link {
        fill: none;
        stroke: #9ecae1;
        stroke-width: 1.5px;
    }

    path.node-path {
        fill: none;
        stroke: #9ecae1;
        stroke-width: 1.5px;
    }

    path.link-path {
        fill: none;
        stroke: #9fe1b3;
        stroke-width: 1.5px;
        stroke-dasharray: 3, 3;
    }

    .broken-link text.text {
        fill: #aa0000;
    }
    
    .meta-dots-holder, .expand-control {
        .meta-dots {
            stroke-linecap: round;
        }

        .plain-link-indicators {
            stroke: #999;
        }

        .conditional-link-indicators {
            stroke: #7a9863;
        }

        .broken-link-indicators {
            stroke: #c80000;
        }
    }

    .expand-control {
        cursor: pointer;

        rect {
            fill: #fff;
        }

        .button-backing {
            fill: #fff;
        }
        
        .button-circle {
            fill: #ccc;
        }
    
        .plain-link-indicators {
            stroke: #999;
        }

        .conditional-link-indicators {
            stroke: #7a9863;
        }
    }
}

#drag-marker {
    cursor: move;
}

.visualizer-container .object-data-fetch, #drag-marker {
    .outer-meta-band {
        display: relative;
        stroke: #c8b7b7;
        fill: none;
        stroke-width: 3;
        stroke-linecap: square;
        stroke-linejoin: square;
    }

    .inner-circle {
        fill: #fff;
    }

    .outer-meta-spokes {
        display: relative;
        stroke: #c8b7b7;
        fill: none;
        stroke-width: 2.2;
        stroke-linecap: square;
        stroke-linejoin: miter;
    }

    .inner-meta-spokes {
        display: relative;
        fill: none;
        stroke-linecap: butt;
        stroke-linejoin: miter;
    }
}

/* Tree/network diagram focus and selection styles */

.visualizer-container {
    .shift-control {
        display: none;
        
        .up-button-alt {
            display: none;
        }
        
        circle.center-point {
            display: none;
        }
    }

    .icon-title-frame {
        .text-frame, .text-frame-joiner, .circle-frame {
            fill: #e3dedb;
            opacity: 0;
        }

        .interactor {
            cursor: pointer;
        }
    }

    .item.selected {
        .icon-title-frame {
            opacity: 0.5;
        }
    }

    // display drag icon when user hovers over a list level 1 glyph
    .item.node .glyph.linkable {
        cursor: move;
    }

    // display shift controls for selected controls on the first level
    .item.node.level-1:hover, .item.link:hover {
        .shift-control {
            display: block;
        }
    }
    
    .drag-active {
        .shift-control {
            display: none;
        }
        
        .transposable .shift-control {
            display: block;
            
            path.arrow {
                display: none;
            }
            
            circle.center-point {
                display: block;
            }
        }
    }

    // display shift controls for selected controls on the first level
    /*.item.node.selected.level-1, .item.link.selected {
        .shift-control {
            display: block;
        }
    }*/
    
    .item.node.level-1.netRoot, .item.link.netRoot {
        .shift-control {
            display: none;
        }
    }
    
    // don't display the up shifter buttons for the node after the root node or for the first link in a list
    /*.item.link.index-0, .item.node.index-1 {
        .shift-control .up-button {
            display: none;
        }
    }*/

    /*.item.link.lastItem, .item.node.lastItem {
        .shift-control .up-button-alt {
            display: block;
        }
        .shift-control .down-button, .shift-control .up-button {
            display: none;
        }
    }

    .item.link.lastItem.index-0, .item.node.lastItem.index-0, .item.link.lastItem.level-1.index-1, .item.node.lastItem.index-1 {
        .shift-control .up-button-alt {
            display: none;
        }
    }*/

    .item.focus .icon-title-frame {
        opacity: 0.25;
        
        .text-frame {
            opacity: 1;
        }
    }

    .item.selected .icon-title-frame {
        .text-frame, .circle-frame, .text-frame-joiner {
            opacity: 1;
        }

        .text-frame {
            x: 12.25;
            width: 494;
        }
    }

    .item {
        text {
            font: 14px sans-serif;
            pointer-events: none;
        }
        
        .linker-control {
            cursor: pointer;
            
            .inner-path {
                fill: #c8beb7;
                cursor: pointer;
            }
            
            .outer-path {
                fill: #fff;
                fill-opacity:1;
                stroke:#ffffff;
                stroke-width:3;
                stroke-miterlimit:4;
                stroke-opacity:1;
                stroke-dasharray:none;
            }
        }

        .linker-control:hover .inner-path {
            fill: #917c6f;
        }
    }
}
|#
