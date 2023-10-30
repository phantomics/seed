import { basicSetup, EditorView } from 'codemirror'
import { EditorState, Compartment, Facet } from '@codemirror/state'
import IndentService from '@codemirror/language'

var __PS_MV_REG;
global.createCodemirror = function (target, data) {
    var tabSize = new Compartment;
    var state = EditorState.create({ doc : data, extensions : [basicSetup, tabSize.of(EditorState.tabSize.of(8))] });
    var view = new EditorView({ state : state,
                                parent : target,
                                doc : data
                              });
    __PS_MV_REG = [];
    return view;
};