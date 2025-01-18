window.seedData = {  };
window.seedElements = {  };
function fetchContact(system, branch, input, handler) {
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST',
                                body : JSON.stringify({ system : system,
                                                        branch : branch,
                                                        input : input
                                                      }),
                                headers : { 'Content-type' : 'application/json; charset=UTF-8' }
                              }).then(function (response) {
        return response.json();
    }).then(function (data) {
        console.log('dt', data, data.oobReload);
        if (data.oobReload) {
            data.oobReload.forEach(function (item) {
                console.log('it', item);
                return htmx.trigger(seedElements[item], 'reload');
            });
        };
        return data;
    }).then(handler);
};
function fetchContact2(context, element, input) {
    __PS_MV_REG = [];
    return fetch('/contact/', { method : 'POST',
                                headers : { 'Content-type' : 'application/json; charset=UTF-8' },
                                body : JSON.stringify({ system : context.system,
                                                        branch : context.branch,
                                                        input : input
                                                      })
                              }).then(function (response) {
        return response.json();
    }).then(function (data) {
        return htmx.trigger(element, 'refresh');
    });
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
function pushForm(item, formList) {
    return formList.push(item);
};
function submitForms(formList) {
    return formList.forEach(function (form) {
        return htmx.trigger(form, 'submit');
    });
};
function ejoin(base, event) {
    if (!('undefined' === typeof event || 'undefined' === typeof event.detail)) {
        console.log('ee', event.detail);
        var _js15 = Object.keys(event.detail);
        var _js17 = _js15.length;
        for (var _js16 = 0; _js16 < _js17; _js16 += 1) {
            var k = _js15[_js16];
            if (!(k === 'elt' || 'undefined' === typeof event.detail[k])) {
                base[k] = event.detail[k];
            };
        };
    };
    return base;
};
function candlePlotter(e) {
    if (0 !== e.seriesIndex) {
        var self = this;
        var setCount = e.seriesCount;
        if (8 !== setCount) {
            return console.log('Error: Exactly 4 prices each point must be provided for the candle chart.');
        } else {
            var prices = [];
            var sets = e.allSeriesPoints;
            var area = e.plotArea;
            var ctx = e.drawingContext;
            var candleMaxSpacing = 3;
            var barCount = (range = e.dygraph.xAxisRange(), counting = false, length = 0, ((function () {
                var _js18 = sets[0];
                var _js20 = _js18.length;
                for (var _js19 = 0; _js19 < _js20; _js19 += 1) {
                    var point = _js18[_js19];
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
            var _js21 = sets[0].length - 1;
            for (var p = 0; p <= _js21; p += 1) {
                var price = { open : sets[0][p]['yval'],
                              close : sets[1][p]['yval'],
                              high : sets[2][p]['yval'],
                              low : sets[3][p]['yval'],
                              openY : sets[0][p]['y'],
                              closeY : sets[1][p]['y'],
                              highY : sets[2][p]['y'],
                              lowY : sets[3][p]['y']
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
            __PS_MV_REG = [];
            return ctx.lineWidth = 1.5;
        };
    };
};