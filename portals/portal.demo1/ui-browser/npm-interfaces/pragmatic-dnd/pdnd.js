import { draggable, dropTargetForElements, monitorForElements } from '@atlaskit/pragmatic-drag-and-drop/element/adapter'
import { combine } from '@atlaskit/pragmatic-drag-and-drop/combine'
import { attachClosestEdge, extractClosestEdge } from '@atlaskit/pragmatic-drag-and-drop-hitbox/closest-edge'

global.draggable = draggable;
global.attachClosestEdge = attachClosestEdge;
global.extractClosestEdge = extractClosestEdge;
global.dndCombine = combine;
global.dropTargetForElements = dropTargetForElements;
global.monitorForElements = monitorForElements;