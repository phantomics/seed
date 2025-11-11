window.seedData = {  };
window.seedElements = {  };
function formInput(element, context, event) {
    var fdata = new FormData(element.closest('form'));
    var obj = Object.fromEntries(fdata.entries());
    __PS_MV_REG = [];
    return fetchContact(element, context, obj, event);
};
function fetchContact(element, context, input, event) {
    var dataIn = new FormData();
    dataIn.append('path', (context.system + '*' + context.branch).toUpperCase());
    dataIn.append('input', new Blob([JSON.stringify(input)], { type : 'application/json' }));
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST', body : dataIn }).then(function (response) {
        return response.json();
    }).then(function (data) {
        if (data.oobReload) {
            data.oobReload.forEach(function (item) {
                return htmx.trigger(seedElements[item], 'reload');
            });
        };
        return data;
    }).then('function' === typeof(event) ? event : ('undefined' !== typeof(event) ? function (data) {
        return htmx.trigger(element, event.next);
    } : null));
};
function realize(system, branch, element) {
    return function (input) {
        __PS_MV_REG = [];
        return fetch('/contact/', { method : 'POST',
                                    headers : { 'Content-type' : 'application/json; charset=UTF-8' },
                                    body : JSON.stringify({ system : system,
                                                            branch : branch,
                                                            input : input
                                                          })
                                  }).then(function (response) {
            return response.json();
        }).then(function (data) {
            return htmx.trigger(element, 'refresh');
        });
    };
};
function registerExclusiveToggleArray(data, actions, state) {
    return function (key, index) {
        if (key) {
            actions[key](data);
            return state.index = index;
        };
    };
};
function initializeDraggable(element, mode, inSeries) {
    var handleContainer = null;
    var handle = null;
    Array.from(element.childNodes).filter(function (item) {
        return (item instanceof HTMLElement);
    }).map(function (n, itemIndex) {
        if ('FORM' === n.tagName) {
            return Array.from(n.childNodes).filter(function (item) {
                return (item instanceof HTMLElement);
            }).map(function (n, itemIndex) {
                return n.className === 'field has-addons' ? (handleContainer = n) : null;
            });
        } else {
            return n.className === 'field has-addons' ? (handleContainer = n) : null;
        };
    });
    if (handleContainer) {
        var _js115 = handleContainer.childNodes;
        var _js117 = _js115.length;
        for (var _js116 = 0; _js116 < _js117; _js116 += 1) {
            var n = _js115[_js116];
            if (n.className === 'control drag-handle') {
                handle = n;
                break;
            };
        };
    };
    if ('undefined' !== typeof(inSeries)) {
        var drops = { element : element,
                      dragHandle : handle,
                      onDragStart : mcodeHandlerOnDrag(inSeries, mode)
                    };
        draggable(drops);
        __PS_MV_REG = [];
        return null;
    };
};
function mcodeDropTarget(element, mode, dragging, n) {
    return { element : n,
             getData : function (data) {
        __PS_MV_REG = [];
        return attachClosestEdge({  }, { element : n,
                                         input : data.input,
                                         allowedEdges : ['top', 'bottom']
                                       });
    },
             onDragEnter : function (event) {
        if (!event.self.element.isEqualNode(event.source.element)) {
            var closestEdge = extractClosestEdge(event.self.data);
            if (!closestEdge) {
                __PS_MV_REG = [];
                return null;
            } else {
                var indicator = getDropIndicator(closestEdge, '8px');
                __PS_MV_REG = [];
                return n.insertAdjacentElement('afterend', indicator);
            };
        };
    },
             onDragLeave : function (event) {
        if (!event.self.element.isEqualNode(event.source.element)) {
            return n.nextElementSibling ? n.nextElementSibling.remove() : null;
        };
    },
             onDrop : function (event) {
        var closestEdge = extractClosestEdge(event.self.data);
        if (n.nextElementSibling) {
            n.nextElementSibling.remove();
        };
        __PS_MV_REG = [];
        return fetchContact(element, mode, { path : element.getAttribute('meta-path'), sort : [parseInt(dragging.source.element.getAttribute('index')), parseInt(n.getAttribute('index')) + (function () {
            switch (closestEdge) {
            case 'bottom':
                return 0;
            case 'top':
                return 0;
            };
        })()] }, function () {
            return htmx.trigger(element, 'reload');
        });
    }
           };
};
function mcodeHandlerOnDrag(element, mode) {
    return function (dragging) {
        return Array.from(element.childNodes).filter(function (item) {
            return (item instanceof HTMLElement);
        }).map(function (n, itemIndex) {
            __PS_MV_REG = [];
            return 3 !== n.nodeType && null === n.getAttribute('data-drop-target-for-element') ? dropTargetForElements(mcodeDropTarget(element, mode, dragging, n)) : null;
        });
    };
};
function getDropIndicator(edge, gap) {
    var strokeSize = 2;
    var terminalSize = 8;
    var lineOffset = 'calc(-0.5 * (' + gap + ' + ' + strokeSize + 'px))';
    var orientation = (function () {
        switch (edge) {
        case 'top':
            return 'horizontal';
        case 'bottom':
            return 'horizontal';
        case 'left':
            return 'vertical';
        case 'right':
            return 'vertical';
        };
    })();
    var element = document.createElement('div');
    var offsetToAlign = (terminalSize - strokeSize) / 2;
    element.setAttribute('data-edge', edge);
    element.classList.add('drop-marker');
    __PS_MV_REG = [];
    return element;
};
function pushForm(item, formList) {
    return formList.push(item);
};
function submitForms(formList) {
    return formList.forEach(function (form) {
        return htmx.trigger(form, 'submit');
    });
};
function ejoin(base, event) {
    if (!('undefined' === typeof(event) || 'undefined' === typeof(event.detail))) {
        var _js118 = Object.keys(event.detail);
        var _js120 = _js118.length;
        for (var _js119 = 0; _js119 < _js120; _js119 += 1) {
            var k = _js118[_js119];
            if (!(k === 'elt' || 'undefined' === typeof(event.detail[k]))) {
                base[k] = event.detail[k];
            };
        };
    };
    __PS_MV_REG = [];
    return base;
};
var derivePoints = function (ent, chart) {
    __PS_MV_REG = [];
    return [!ent.layerPoints || !ent.layerPoints[0] || 'undefined' === typeof(ent.layerPoints[0]) ? chart.toDomCoords(ent.points[0][0], ent.points[0][1]) : ent.layerPoints[0], !ent.layerPoints || !ent.layerPoints[1] || 'undefined' === typeof(ent.layerPoints[1]) ? chart.toDomCoords(ent.points[1][0], ent.points[1][1]) : ent.layerPoints[1]];
};
var drawLine = function (ctx, ent, chart, points) {
    if (ent.inFlux && 'false' !== ent.inFlux) {
        ctx.lineWidth = 2;
    };
    ctx.beginPath();
    var points121 = points ? points : derivePoints(ent, chart);
    var circleRadius = 5;
    ctx.moveTo(points121[0][0], points121[0][1]);
    ctx.lineTo(points121[1][0], points121[1][1]);
    ctx.closePath();
    ctx.stroke();
    if (ent.inFlux && 'false' !== ent.inFlux) {
        var diffs = [[points121[0][0] - points121[1][0], points121[0][1] - points121[1][1]], [points121[1][0] - points121[0][0], points121[1][1] - points121[0][1]]];
        var ri = [Math.sign(diffs[0][1]) * Math.acos(diffs[0][0] / Math.sqrt(Math.pow(diffs[0][0], 2) + Math.pow(diffs[0][1], 2))), Math.sign(diffs[1][1]) * Math.acos(diffs[1][0] / Math.sqrt(Math.pow(diffs[1][0], 2) + Math.pow(diffs[1][1], 2)))];
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'black';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        ctx.arc(points121[0][0], points121[0][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points121[1][0], points121[1][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points121[0][0], points121[0][1], circleRadius, -Math.PI + (ri[0] - Math.PI * 0.2), -Math.PI + (ri[0] + Math.PI * 0.2), true);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(points121[1][0], points121[1][1], circleRadius, -Math.PI + (ri[1] - Math.PI * 0.2), -Math.PI + (ri[1] + Math.PI * 0.2), true);
        ctx.stroke();
    };
    ctx.strokeStyle = 'black';
    __PS_MV_REG = [];
    return ctx.lineWidth = 1;
};
var intersectLine = function (ent, chart, point, callback) {
    var linePoints = [chart.toDomCoords(ent.points[0][0], ent.points[0][1]), chart.toDomCoords(ent.points[1][0], ent.points[1][1])];
    var margin = 8;
    if (!(point[0] > linePoints[0][0] + margin && point[0] > linePoints[1][0] + margin || point[0] < linePoints[0][0] - margin && point[0] < linePoints[1][0] - margin || point[1] > linePoints[0][1] + margin && point[1] > linePoints[1][1] + margin || point[1] < linePoints[0][1] - margin && point[1] < linePoints[1][1] - margin)) {
        var ratio = (linePoints[0][1] - linePoints[1][1]) / (linePoints[1][0] - linePoints[0][0]);
        var xPos = point[0] - linePoints[0][0];
        var crossY = Math.abs(xPos * ratio - linePoints[0][1]);
        __PS_MV_REG = [];
        return 8 > Math.abs(crossY - point[1]) ? callback(ent) : null;
    };
};
if ('undefined' === typeof drawMethods) {
    var drawMethods = { line : { draw : drawLine, intersect : intersectLine },
                        retraceX : { draw : function (ctx, ent, chart) {
        var points = derivePoints(ent, chart);
        drawLine(ctx, ent, chart, points);
        ctx.strokeStyle = 'blue';
        ctx.lineWidth = 1;
        var xOrigin = points[0][0] < points[1][0] ? points[0][0] : points[1][0];
        var xInterval = points[0][0] - points[1][0];
        var _js122 = ent.ratios[0];
        var _js124 = _js122.length;
        for (var _js123 = 0; _js123 < _js124; _js123 += 1) {
            var ratio = _js122[_js123];
            var xLevel = points[0][0] < points[1][0] ? xOrigin - ratio * xInterval : xOrigin + ratio * xInterval;
            ctx.beginPath();
            ctx.moveTo(xLevel, 0);
            ctx.lineTo(xLevel, ctx.canvas.height);
            ctx.closePath();
            ctx.stroke();
        };
        ctx.strokeStyle = 'black';
        __PS_MV_REG = [];
        return ctx.lineWidth = 1.5;
    }, intersect : intersectLine },
                        retraceY : { draw : function (ctx, ent, chart) {
        var points = derivePoints(ent, chart);
        drawLine(ctx, ent, chart, points);
        ctx.strokeStyle = 'red';
        ctx.lineWidth = 1;
        var xOrigin = points[0][0] < points[1][0] ? points[0][0] : points[1][0];
        var yOrigin = points[0][1] < points[1][1] ? points[0][1] : points[1][1];
        var yInterval = points[0][1] - points[1][1];
        var _js125 = ent.ratios[1];
        var _js127 = _js125.length;
        for (var _js126 = 0; _js126 < _js127; _js126 += 1) {
            var ratio = _js125[_js126];
            var yLevel = points[0][1] < points[1][1] ? yOrigin - ratio * yInterval : yOrigin + ratio * yInterval;
            ctx.beginPath();
            ctx.moveTo(xOrigin, yLevel);
            ctx.lineTo(ctx.canvas.width, yLevel);
            ctx.closePath();
            ctx.stroke();
        };
        ctx.strokeStyle = 'black';
        __PS_MV_REG = [];
        return ctx.lineWidth = 1.5;
    }, intersect : intersectLine }
                      };
};
if ('undefined' === typeof candlestickChartEntityTemplates) {
    var candlestickChartEntityTemplates = { line : {  },
                                            retraceX : { ratios : [[0, 0.382, 0.618, 1]] },
                                            retraceY : { ratios : [[], [0, 0.236, 0.382, 0.5, 0.618, 0.764, 1]] }
                                          };
};
function commitEntities(mode, callback) {
    __PS_MV_REG = [];
    return fetchContact(null, mode, { entities : 0 === mode.entitiesInFlux.length ? [0] : mode.entitiesInFlux }, function (data) {
        console.log('en', mode.entities, data, mode.linkedBranchId);
        mode.entities = data;
        htmx.trigger('#' + mode.linkedBranchId, 'reload');
        return callback ? callback() : null;
    });
};
function interactorMousewheel(mode) {
    return function (event, chart, context) {
        if (event.shiftKey) {
            var priceRange = chart.yAxisRange();
            var priceInterval = priceRange[0] - priceRange[1];
            var zoomInterval = 0.05 * priceInterval;
            var wheelDelta = 0 < event.deltaY ? 1 : -1;
            return chart.updateOptions({ dateWindow : chart.xAxisRange(), valueRange : [1 === wheelDelta ? priceRange[0] - zoomInterval : priceRange[0] + zoomInterval, priceRange[1]] });
        } else {
            var timeRange = chart.xAxisRange();
            var timeInterval = timeRange[1] - timeRange[0];
            var zoomInterval128 = 0.05 * timeInterval;
            var wheelDelta129 = 0 < event.deltaY ? 1 : -1;
            return chart.updateOptions({ dateWindow : [1 === wheelDelta129 ? timeRange[0] - zoomInterval128 : timeRange[0] + zoomInterval128, timeRange[1]], valueRange : chart.yAxisRange() });
        };
    };
};
function interactorMousedown(mode) {
    return function (event, g, context) {
        mode.mousedown = true;
        var canvasCoords = [event.layerX, event.layerY];
        var domCoords = g.eventToDomCoords(event);
        var entitiesCount = mode.entities.length;
        switch (mode.interaction) {
        case 'select':
            var entityClicked = false;
            var _js130 = entitiesCount - 1;
            for (var entix = 0; entix <= _js130; entix += 1) {
                self.drawMethods.line.intersect(mode.entities[entix], mode.chart, domCoords, function (ent) {
                    entityClicked = true;
                    ent.layerPoints = [g.toDomCoords(ent.points[0][0], ent.points[0][1]), g.toDomCoords(ent.points[1][0], ent.points[1][1])];
                    console.log('lp1', ent.layerPoints);
                    if (ent.inFlux && 'false' !== ent.inFlux) {
                        if (8 > Math.abs(ent.layerPoints[0][0] - domCoords[0]) && 8 > Math.abs(ent.layerPoints[0][1] - domCoords[1])) {
                            ent.pointsInFlux.push(0);
                        } else {
                            if (8 > Math.abs(ent.layerPoints[1][0] - domCoords[0]) && 8 > Math.abs(ent.layerPoints[1][1] - domCoords[1])) {
                                ent.pointsInFlux.push(1);
                            };
                        };
                    };
                    if (!ent.inFlux || 'false' === ent.inFlux) {
                        ent.inFlux = true;
                        __PS_MV_REG = [];
                        return mode.entitiesInFlux.push(ent);
                    } else {
                        __PS_MV_REG = [];
                        return null;
                    };
                });
            };
            if (!entityClicked) {
                mode.entitiesInFlux = [];
                var _js131 = mode.entities;
                var _js133 = _js131.length;
                for (var _js132 = 0; _js132 < _js133; _js132 += 1) {
                    var ent = _js131[_js132];
                    ent.inFlux = false;
                };
            };
            mode.movingFrom = canvasCoords;
            if (0 === mode.entitiesInFlux.length) {
                context.initializeMouseDown(event, g, context);
                return window.Dygraph.startPan(event, g, context);
            } else {
                return g.drawGraph_();
            };
        case 'draw':
            var timeInterval = g.rawData_[1][0] - g.rawData_[0][0];
            var dataPos = g.toDataCoords(domCoords[0], domCoords[1]);
            var remainder = (dataPos[0] % timeInterval + timeInterval) % timeInterval;
            if (0 !== remainder) {
                dataPos[0] -= remainder;
            };
            var thisDate = new Date();
            var base = { type : mode.drawEntity,
                         inFlux : true,
                         name : 'obj-' + thisDate.getTime(),
                         points : [[dataPos[0], dataPos[1]], [dataPos[0], dataPos[1]]],
                         pointsInFlux : []
                       };
            var newEntity = Object.assign({  }, base, candlestickChartEntityTemplates[mode.drawEntity]);
            mode.entitiesInFlux.push(newEntity);
            __PS_MV_REG = [];
            return mode.activeEntity = newEntity;
        };
    };
};
function interactorMouseup(mode) {
    return function (event, chart, context) {
        var self = this;
        mode.mousedown = false;
        switch (mode.interaction) {
        case 'select':
            if (context.isPanning) {
                window.Dygraph.endPan(event, chart, context);
                return chart.drawGraph_();
            } else {
                var _js134 = mode.entities;
                var _js136 = _js134.length;
                for (var _js135 = 0; _js135 < _js136; _js135 += 1) {
                    var ent = _js134[_js135];
                    if (ent.inFlux && 'false' !== ent.inFlux) {
                        ent.points[0] = chart.toDataCoords(ent.layerPoints[0][0], ent.layerPoints[0][1]);
                        ent.points[1] = chart.toDataCoords(ent.layerPoints[1][0], ent.layerPoints[1][1]);
                        ent.layerPoints = null;
                        ent.pointsInFlux = [];
                    };
                };
                return chart.drawGraph_();
            };
        case 'draw':
            mode.activeEntity = null;
            mode.interaction = 'select';
            __PS_MV_REG = [];
            return commitEntities(mode, function () {
                return chart.drawGraph_();
            });
        };
    };
};
function interactorMousemove(mode) {
    return function (event, chart, context) {
        var self = this;
        var tempCanvas = chart.canvas_ctx_;
        if (mode.mousedown) {
            switch (mode.interaction) {
            case 'select':
                if (0 === mode.entitiesInFlux.length) {
                    return context.isPanning ? window.Dygraph.movePan(event, chart, context) : chart.drawGraph_();
                } else {
                    var movingFrom137 = mode.movingFrom;
                    tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                    var _js138 = mode.entitiesInFlux;
                    var _js140 = _js138.length;
                    for (var _js139 = 0; _js139 < _js140; _js139 += 1) {
                        var ent = _js138[_js139];
                        if (0 === ent.pointsInFlux.length) {
                            ent.layerPoints = [[ent.layerPoints[0][0] - (movingFrom137[0] - event.layerX), ent.layerPoints[0][1] - (movingFrom137[1] - event.layerY)], [ent.layerPoints[1][0] - (movingFrom137[0] - event.layerX), ent.layerPoints[1][1] - (movingFrom137[1] - event.layerY)]];
                        } else {
                            var timeInterval = chart.rawData_[1][0] - chart.rawData_[0][0];
                            var domCoords = chart.eventToDomCoords(event);
                            var dataPos = chart.toDataCoords(domCoords[0], domCoords[1]);
                            var remainder = (dataPos[0] % timeInterval + timeInterval) % timeInterval;
                            if (0 !== remainder) {
                                dataPos[0] -= remainder;
                            };
                            var columnValue = chart.getValue(dataPos[0], 1);
                            var cvals = [Math.floor(chart.toDomYCoord(chart['rawData_'][dataPos[0]][2])), Math.floor(chart.toDomYCoord(chart['rawData_'][dataPos[0]][3]))];
                            var _js141 = ent.pointsInFlux;
                            var _js143 = _js141.length;
                            for (var _js142 = 0; _js142 < _js143; _js142 += 1) {
                                var point = _js141[_js142];
                                ent['layerPoints'][point] = [event.layerX, event.layerY];
                                if (8 > Math.abs(cvals[0] - ent['layerPoints'][point][1])) {
                                    ent['layerPoints'][point][1] = cvals[0];
                                } else {
                                    if (8 > Math.abs(cvals[1] - ent['layerPoints'][point][1])) {
                                        ent['layerPoints'][point][1] = cvals[1];
                                    };
                                };
                            };
                        };
                        mode.movingFrom = [event.layerX, event.layerY];
                        drawMethods[ent.type]['draw'](tempCanvas, ent, chart);
                    };
                    __PS_MV_REG = [];
                    return;
                };
            case 'draw':
                var timeInterval141 = chart.rawData_[1][0] - chart.rawData_[0][0];
                var domCoords142 = chart.eventToDomCoords(event);
                var dataPos143 = chart.toDataCoords(domCoords142[0], domCoords142[1]);
                var remainder144 = (dataPos143[0] % timeInterval141 + timeInterval141) % timeInterval141;
                var ent145 = mode.activeEntity;
                if (0 !== remainder144) {
                    dataPos143[0] -= remainder144;
                };
                ent145.points[1] = [dataPos143[0], dataPos143[1]];
                tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                __PS_MV_REG = [];
                return drawMethods[ent145.type]['draw'](tempCanvas, ent145, chart);
            };
        };
    };
};
function getCandlePlotter(mode) {
    console.log('mm', mode);
    return function (e) {
        if (0 !== e.seriesIndex) {
            var self = this;
            var setCount = e.seriesCount;
            window.bla = e.allSeriesPoints;
            if (4 !== setCount) {
                return console.log('Error: Exactly 4 prices each point must be provided for the candle chart.');
            } else {
                var prices = [];
                var sets = e.allSeriesPoints;
                var area = e.plotArea;
                var ctx = e.drawingContext;
                var candleMaxSpacing = 3;
                var barCount = (range = e.dygraph.xAxisRange(), counting = false, length = 0, ((function () {
                    var _js146 = sets[0];
                    var _js148 = _js146.length;
                    for (var _js147 = 0; _js147 < _js148; _js147 += 1) {
                        var point = _js146[_js147];
                        if (!counting && point.xval > range[0]) {
                            counting = true;
                        };
                        if (counting && point.xval > Math.floor(range[1])) {
                            counting = false;
                        };
                        if (counting) {
                            length += 1;
                        };
                    };
                })(), length));
                var viewWidth = e.dygraph.getArea().w;
                var barWidth = Math.max(1, 0.7 * (viewWidth / barCount));
                var upFillStyle = 'rgba(38,139,210,1.0)';
                var upStrokeStyle = 2 < barWidth ? 'rgba(38,139,210,1.0)' : 'rgba(38,139,210,0.6)';
                var downFillStyle = 'rgba(220,50,47,1.0)';
                var downStrokeStyle = 2 < barWidth ? 'rgba(220,50,47,1.0)' : 'rgba(220,50,47,0.6)';
                console.log('sets', sets);
                ctx.lineWidth = 0.6;
                var _js149 = sets[0].length - 1;
                for (var p = 0; p <= _js149; p += 1) {
                    var price = { open : sets[0][p]['yval'],
                                  high : sets[1][p]['yval'],
                                  low : sets[2][p]['yval'],
                                  close : sets[3][p]['yval'],
                                  openY : sets[0][p]['y'],
                                  highY : sets[1][p]['y'],
                                  lowY : sets[2][p]['y'],
                                  closeY : sets[3][p]['y']
                                };
                    var topY = area.y + area.h * price.highY;
                    var bottomY = area.y + area.h * price.lowY;
                    var centerX = area.x + area.w * sets[0][p]['x'];
                    var bodyY = null;
                    var bodyHeight = null;
                    prices.push(price);
                    ctx.beginPath();
                    ctx.moveTo(centerX, topY);
                    ctx.lineTo(centerX, bottomY);
                    ctx.closePath();
                    if (price.open > price.close) {
                        ctx.fillStyle = downFillStyle;
                        ctx.strokeStyle = downStrokeStyle;
                        bodyY = area.y + area.h * price.openY;
                    } else {
                        ctx.fillStyle = upFillStyle;
                        ctx.strokeStyle = upStrokeStyle;
                        bodyY = area.y + area.h * price.closeY;
                    };
                    ctx.stroke();
                    bodyHeight = area.h * Math.abs(price.openY - price.closeY);
                    ctx.fillRect(centerX - barWidth / 2, bodyY, barWidth, bodyHeight);
                };
                ctx.strokeStyle = 'black';
                ctx.lineWidth = 1.5;
                console.log('ents', mode, mode.entities);
                var _js150 = mode.entities;
                var _js152 = _js150.length;
                for (var _js151 = 0; _js151 < _js152; _js151 += 1) {
                    var ent = _js150[_js151];
                    if (!(mode.mousedown && ent.inFlux)) {
                        drawMethods[ent.type]['draw'](ctx, ent, mode.chart);
                    };
                };
            };
        };
    };
};