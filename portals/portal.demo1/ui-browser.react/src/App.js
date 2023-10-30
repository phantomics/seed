import React from 'react'
import ReactDOM from 'react-dom/client'
import { CContainer, CSpinner, CRow, CCol } from '@coreui/react'
import './main.scss'
1 + 2;
function transact() {
    return jQuery.ajax({ url : './contact',
                         type : 'POST',
                         dataType : 'json',
                         contentType : 'application/json; charset=utf-8',
                         data : JSON.stringify([window.portalId, portalMethod].concat(params)),
                         success : function (data) {
        return console.log('dt', data);
    },
                         error : function (data, err) {
        return console.log(11, data, err);
    }
                       });
};
if ('undefined' === typeof View) {
    var View = createReactClass({ 'displayName' : '-VIEW',
                                  'render' : function () {
        var self = this;
        return React.createElement('div', { className : 'test123' });
    },
                                  'getInitialState' : function () {
        return this.initialize(this.props);
    },
                                  initialize : function (props) {
        return null;
    },
                                  size : 0
                                });
};
function MainComponent() {
    __PS_MV_REG = [];
    return '-c-container'('-c-row'('-c-col'('sm', 'auto', 'a'), '-c-col'('sm', 'auto', 'b'), '-c-col'('sm', 'auto', 'c')));
};
1 + 2;export default MainComponent