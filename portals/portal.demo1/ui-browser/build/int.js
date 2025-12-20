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
            console.log('xx', data, state, actions[key], actions);
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
        var _js51 = handleContainer.childNodes;
        var _js53 = _js51.length;
        for (var _js52 = 0; _js52 < _js53; _js52 += 1) {
            var n = _js51[_js52];
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
        var _js54 = Object.keys(event.detail);
        var _js56 = _js54.length;
        for (var _js55 = 0; _js55 < _js56; _js55 += 1) {
            var k = _js54[_js55];
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
    var points57 = points ? points : derivePoints(ent, chart);
    var circleRadius = 5;
    ctx.moveTo(points57[0][0], points57[0][1]);
    ctx.lineTo(points57[1][0], points57[1][1]);
    ctx.closePath();
    ctx.stroke();
    if (ent.inFlux && 'false' !== ent.inFlux) {
        var diffs = [[points57[0][0] - points57[1][0], points57[0][1] - points57[1][1]], [points57[1][0] - points57[0][0], points57[1][1] - points57[0][1]]];
        var ri = [Math.sign(diffs[0][1]) * Math.acos(diffs[0][0] / Math.sqrt(Math.pow(diffs[0][0], 2) + Math.pow(diffs[0][1], 2))), Math.sign(diffs[1][1]) * Math.acos(diffs[1][0] / Math.sqrt(Math.pow(diffs[1][0], 2) + Math.pow(diffs[1][1], 2)))];
        ctx.strokeStyle = 'black';
        ctx.fillStyle = 'black';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        ctx.arc(points57[0][0], points57[0][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points57[1][0], points57[1][1], 1, 0, Math.PI * 2, true);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(points57[0][0], points57[0][1], circleRadius, -Math.PI + (ri[0] - Math.PI * 0.2), -Math.PI + (ri[0] + Math.PI * 0.2), true);
        ctx.stroke();
        ctx.beginPath();
        ctx.arc(points57[1][0], points57[1][1], circleRadius, -Math.PI + (ri[1] - Math.PI * 0.2), -Math.PI + (ri[1] + Math.PI * 0.2), true);
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
        var _js58 = ent.ratios[0];
        var _js60 = _js58.length;
        for (var _js59 = 0; _js59 < _js60; _js59 += 1) {
            var ratio = _js58[_js59];
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
        var _js61 = ent.ratios[1];
        var _js63 = _js61.length;
        for (var _js62 = 0; _js62 < _js63; _js62 += 1) {
            var ratio = _js61[_js62];
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
            var zoomInterval64 = 0.05 * timeInterval;
            var wheelDelta65 = 0 < event.deltaY ? 1 : -1;
            return chart.updateOptions({ dateWindow : [1 === wheelDelta65 ? timeRange[0] - zoomInterval64 : timeRange[0] + zoomInterval64, timeRange[1]], valueRange : chart.yAxisRange() });
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
            var _js66 = entitiesCount - 1;
            for (var entix = 0; entix <= _js66; entix += 1) {
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
                var _js67 = mode.entities;
                var _js69 = _js67.length;
                for (var _js68 = 0; _js68 < _js69; _js68 += 1) {
                    var ent = _js67[_js68];
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
                var _js70 = mode.entities;
                var _js72 = _js70.length;
                for (var _js71 = 0; _js71 < _js72; _js71 += 1) {
                    var ent = _js70[_js71];
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
                    var movingFrom73 = mode.movingFrom;
                    tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                    var _js74 = mode.entitiesInFlux;
                    var _js76 = _js74.length;
                    for (var _js75 = 0; _js75 < _js76; _js75 += 1) {
                        var ent = _js74[_js75];
                        if (0 === ent.pointsInFlux.length) {
                            ent.layerPoints = [[ent.layerPoints[0][0] - (movingFrom73[0] - event.layerX), ent.layerPoints[0][1] - (movingFrom73[1] - event.layerY)], [ent.layerPoints[1][0] - (movingFrom73[0] - event.layerX), ent.layerPoints[1][1] - (movingFrom73[1] - event.layerY)]];
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
                            var _js77 = ent.pointsInFlux;
                            var _js79 = _js77.length;
                            for (var _js78 = 0; _js78 < _js79; _js78 += 1) {
                                var point = _js77[_js78];
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
                var timeInterval77 = chart.rawData_[1][0] - chart.rawData_[0][0];
                var domCoords78 = chart.eventToDomCoords(event);
                var dataPos79 = chart.toDataCoords(domCoords78[0], domCoords78[1]);
                var remainder80 = (dataPos79[0] % timeInterval77 + timeInterval77) % timeInterval77;
                var ent81 = mode.activeEntity;
                if (0 !== remainder80) {
                    dataPos79[0] -= remainder80;
                };
                ent81.points[1] = [dataPos79[0], dataPos79[1]];
                tempCanvas.clearRect(0, 0, chart.canvas_.width, chart.canvas_.height);
                __PS_MV_REG = [];
                return drawMethods[ent81.type]['draw'](tempCanvas, ent81, chart);
            };
        };
    };
};
function getCandlePlotter(mode) {
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
                    var _js82 = sets[0];
                    var _js84 = _js82.length;
                    for (var _js83 = 0; _js83 < _js84; _js83 += 1) {
                        var point = _js82[_js83];
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
                ctx.lineWidth = 0.6;
                var _js85 = sets[0].length - 1;
                for (var p = 0; p <= _js85; p += 1) {
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
                var _js86 = mode.entities;
                var _js88 = _js86.length;
                for (var _js87 = 0; _js87 < _js88; _js87 += 1) {
                    var ent = _js86[_js87];
                    if (!(mode.mousedown && ent.inFlux)) {
                        drawMethods[ent.type]['draw'](ctx, ent, mode.chart);
                    };
                };
            };
        };
    };
};