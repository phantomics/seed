import { schema } from 'prosemirror-schema-basic'
import { EditorState } from 'prosemirror-state'
import { EditorView } from 'prosemirror-view'
import { undo, redo, history } from 'prosemirror-history'
import { baseKeymap } from 'prosemirror-commands'

var __PS_MV_REG;
global.createProsemirror = function (target) {
    var state = EditorState({ schema : schema, plugins : [history(), keymap(baseKeymap)] });
    var view = new EditorView(target, { state : state });
    __PS_MV_REG = [];
    return view;
};