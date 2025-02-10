import { schema } from 'prosemirror-schema-basic'
import { EditorState } from 'prosemirror-state'
import { EditorView } from 'prosemirror-view'

var __PS_MV_REG;
global.createProsemirror = function (target, data) {
    var state = EditorState({ schema : schema });
    var view = new EditorView({ state : state });
    __PS_MV_REG = [];
    return view;
};
