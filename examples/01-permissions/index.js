"use strict";
exports.__esModule = true;
var sdom_1 = require("./sdom");
function render() {
    return sdom_1.h.div([
        sdom_1.h.h2('Permission management'),
        sdom_1.h.p('Lorem ipsum'),
    ]);
}
var container = document.createElement('div');
document.body.appendChild(container);
var sdom = render();
var el = sdom_1.create(sdom, {});
container.appendChild(el);
