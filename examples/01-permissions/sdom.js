"use strict";
var __assign = (this && this.__assign) || function () {
    __assign = Object.assign || function(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p))
                t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};
exports.__esModule = true;
var NODE_DATA = '__SDOM_CUSTOM_DATA__';
var ArraySplice = /** @class */ (function () {
    function ArraySplice(_index, _removes, _values) {
        this._index = _index;
        this._removes = _removes;
        this._values = _values;
    }
    return ArraySplice;
}());
exports.ArraySplice = ArraySplice;
var ArraySwap = /** @class */ (function () {
    function ArraySwap(_firstIdx, _secondIdx) {
        this._firstIdx = _firstIdx;
        this._secondIdx = _secondIdx;
    }
    return ArraySwap;
}());
exports.ArraySwap = ArraySwap;
var Batch = /** @class */ (function () {
    function Batch(_patches) {
        this._patches = _patches;
    }
    return Batch;
}());
exports.Batch = Batch;
var Replace = /** @class */ (function () {
    function Replace(_prev, _next) {
        this._prev = _prev;
        this._next = _next;
    }
    return Replace;
}());
exports.Replace = Replace;
var KeyPatch = /** @class */ (function () {
    function KeyPatch(_key, _patch) {
        this._key = _key;
        this._patch = _patch;
    }
    return KeyPatch;
}());
exports.KeyPatch = KeyPatch;
function applyPatch(value, patch, destructively) {
    if (destructively === void 0) { destructively = false; }
    var _a;
    if (patch instanceof KeyPatch) {
        if (destructively) {
            // @ts-ignore
            value[patch._key] = applyPatch(value[patch._key], patch._patch, destructively);
            return value;
        }
        else {
            // @ts-ignore
            return __assign({}, value, (_a = {}, _a[patch._key] = applyPatch(value[patch._key], patch._patch, destructively), _a));
        }
    }
    if (patch instanceof ArraySplice) {
        if (destructively) {
            // @ts-ignore
            value.splice.apply(value, [patch._index, patch._removes].concat(patch._values));
            return value;
        }
        else {
            // @ts-ignore
            var nextValue = value.slice(0);
            nextValue.splice.apply(nextValue, [patch._index, patch._removes].concat(patch._values));
            return nextValue;
        }
    }
    if (patch instanceof ArraySwap) {
        if (destructively) {
            // @ts-ignore
            var tmp = value[patch._firstIdx];
            value[firstIdx] = value[secondIdx];
            value[secondIdx] = tmp;
            return value;
        }
        else {
            // @ts-ignore
            var nextValue = value.slice(0);
            nextValue[firstIdx] = value[secondIdx];
            nextValue[secondIdx] = value[firstIdx];
            return nextValue;
        }
    }
    if (patch instanceof Batch) {
        return patch._patches.reduce(function (acc, p) { return applyPatch(acc, p, destructively); }, value);
    }
    if (patch instanceof Replace) {
        return patch._next;
    }
    return absurd(patch);
}
exports.applyPatch = applyPatch;
var SDOMElement = /** @class */ (function () {
    function SDOMElement(_name, _attributes, _childs) {
        this._name = _name;
        this._attributes = _attributes;
        this._childs = _childs;
    }
    return SDOMElement;
}());
exports.SDOMElement = SDOMElement;
var SDOMText = /** @class */ (function () {
    function SDOMText(_value) {
        this._value = _value;
    }
    return SDOMText;
}());
exports.SDOMText = SDOMText;
var SDOMTextThunk = /** @class */ (function () {
    function SDOMTextThunk(_thunk) {
        this._thunk = _thunk;
    }
    return SDOMTextThunk;
}());
exports.SDOMTextThunk = SDOMTextThunk;
var SDOMDiscriminate = /** @class */ (function () {
    function SDOMDiscriminate(_discriminator, _tags) {
        this._discriminator = _discriminator;
        this._tags = _tags;
    }
    return SDOMDiscriminate;
}());
exports.SDOMDiscriminate = SDOMDiscriminate;
var SDOMArray = /** @class */ (function () {
    function SDOMArray(_discriminator, _item) {
        this._discriminator = _discriminator;
        this._item = _item;
    }
    return SDOMArray;
}());
exports.SDOMArray = SDOMArray;
var SDOMPick = /** @class */ (function () {
    function SDOMPick(_keys, _sdom) {
        this._keys = _keys;
        this._sdom = _sdom;
    }
    return SDOMPick;
}());
exports.SDOMPick = SDOMPick;
var SDOMMap = /** @class */ (function () {
    function SDOMMap(_sdom, _proj) {
        this._sdom = _sdom;
        this._proj = _proj;
    }
    return SDOMMap;
}());
exports.SDOMMap = SDOMMap;
var SDOMCustom = /** @class */ (function () {
    function SDOMCustom(_create, _actuate) {
        this._create = _create;
        this._actuate = _actuate;
    }
    return SDOMCustom;
}());
exports.SDOMCustom = SDOMCustom;
var HasSDOM = /** @class */ (function () {
    function HasSDOM() {
    }
    return HasSDOM;
}());
exports.HasSDOM = HasSDOM;
var AttrPure = /** @class */ (function () {
    function AttrPure(_value, _isProperty) {
        this._value = _value;
        this._isProperty = _isProperty;
    }
    return AttrPure;
}());
exports.AttrPure = AttrPure;
var AttrThunk = /** @class */ (function () {
    function AttrThunk(_thunk, _isPropery) {
        if (_isPropery === void 0) { _isPropery = false; }
        this._thunk = _thunk;
        this._isPropery = _isPropery;
    }
    return AttrThunk;
}());
exports.AttrThunk = AttrThunk;
var AttrEvent = /** @class */ (function () {
    function AttrEvent(_listener) {
        this._listener = _listener;
    }
    return AttrEvent;
}());
exports.AttrEvent = AttrEvent;
function h() {
    if (arguments.length === 1) {
        var name_1 = arguments[0], attrs_1 = {}, childs_1 = [];
        return new SDOMElement(name_1, attrs_1, Array.isArray(childs_1) ? childs_1 : [childs_1]);
    }
    if (arguments.length === 2) {
        var name_2 = arguments[0], attrs_2 = {}, childs_2 = arguments[1];
        return new SDOMElement(name_2, attrs_2, Array.isArray(childs_2) ? childs_2 : [childs_2]);
    }
    var name = arguments[0], attrs = arguments[1], childs = arguments[2];
    return new SDOMElement(name, attrs, Array.isArray(childs) ? childs : [childs]);
}
exports.h = h;
(function (h) {
    h.div = h.bind(void 0, 'div');
    h.span = h.bind(void 0, 'span');
    h.button = h.bind(void 0, 'button');
    h.p = h.bind(void 0, 'p');
    h.h1 = h.bind(void 0, 'h1');
    h.h2 = h.bind(void 0, 'h2');
    h.h3 = h.bind(void 0, 'h3');
    h.input = function (attrs) { return h('input', attrs, []); };
    h.img = function (attrs) { return h('img', attrs, []); };
    h.label = h.bind(void 0, 'label');
    h.li = h.bind(void 0, 'li');
})(h = exports.h || (exports.h = {}));
var th;
(function (th) {
    th.div = h.bind(void 0, 'div');
    th.span = h.bind(void 0, 'span');
    th.button = h.bind(void 0, 'button');
    th.p = h.bind(void 0, 'p');
    th.h1 = h.bind(void 0, 'h1');
    th.h2 = h.bind(void 0, 'h2');
    th.h3 = h.bind(void 0, 'h3');
    th.input = function (attrs) { return h('input', attrs, []); };
    th.img = function (attrs) { return h('img', attrs, []); };
    th.label = h.bind(void 0, 'label');
    th.li = h.bind(void 0, 'li');
})(th = exports.th || (exports.th = {}));
function text(value) {
    return new SDOMText(value);
}
exports.text = text;
function thunk(th) {
    return new SDOMTextThunk(th);
}
exports.thunk = thunk;
function pick(keys, sdom) {
    return new SDOMPick(keys, sdom);
}
exports.pick = pick;
function discriminate(discriminator) {
    return function (tags) { return new SDOMDiscriminate(discriminator, tags); };
}
exports.discriminate = discriminate;
function array() {
    if (arguments.length === 2) {
        // @ts-ignore
        var discriminator_1 = arguments[0], item_1 = arguments[1];
        return new SDOMPick([discriminator_1], new SDOMArray(discriminator_1, item_1));
    }
    // @ts-ignore
    var discriminator = arguments[0], pick = arguments[1], item = arguments[2];
    return new SDOMPick(pick, new SDOMArray(discriminator, item));
}
exports.array = array;
var attrs;
(function (attrs) {
    function lam(th) {
        return new AttrThunk(th);
    }
    attrs.lam = lam;
})(attrs = exports.attrs || (exports.attrs = {}));
var props;
(function (props) {
    function of(value) {
        return new AttrPure(value, true);
    }
    props.of = of;
    function lam(th) {
        return new AttrThunk(th, true);
    }
    props.lam = lam;
})(props = exports.props || (exports.props = {}));
function create(sdom, model) {
    if (sdom instanceof SDOMElement) {
        var el_1 = document.createElement(sdom._name);
        Object.keys(sdom._attributes).forEach(function (k) { return applyAttribute(k, sdom._attributes[k], el_1, model); });
        sdom._childs.forEach(function (ch) { return el_1.appendChild(create(ch, model)); });
        return el_1;
    }
    if (sdom instanceof SDOMText) {
        var el_2 = document.createTextNode(sdom._value);
        return el_2;
    }
    if (sdom instanceof SDOMTextThunk) {
        var el_3 = document.createTextNode(sdom._thunk(model));
        return el_3;
    }
    if (typeof (sdom) === 'function') {
        var el_4 = document.createTextNode(sdom(model));
        return el_4;
    }
    if (sdom instanceof SDOMDiscriminate) {
        var ch = sdom._tags[model[sdom._discriminator]];
        var el_5 = create(ch, model);
        // @ts-ignore
        el_5.dataset.tag = model[sdom._discriminator];
        return el_5;
    }
    if (sdom instanceof SDOMArray) {
        var array_1 = model[sdom._discriminator];
        var el_6 = document.createElement('div');
        array_1.forEach(function (item, idx) {
            var chModel = { item: item, model: model };
            var ch = create(sdom._item, chModel);
            ch[NODE_DATA] = { model: chModel };
            el_6.appendChild(ch);
        });
        return el_6;
    }
    if (sdom instanceof SDOMPick) {
        var el_7 = create(sdom._sdom, model);
        return el_7;
    }
    if (sdom instanceof SDOMMap) {
        var el_8 = create(sdom._sdom, model);
        el_8[NODE_DATA] = { proj: sdom._proj, model: model };
        return el_8;
    }
    if (sdom instanceof SDOMCustom) {
        return sdom._create(model);
    }
    if (sdom instanceof HasSDOM) {
        return create(sdom.toSDOM(), model);
    }
    ensure(sdom);
    var el = document.createTextNode(sdom + '');
    return el;
}
exports.create = create;
function actuate(el, sdom, model, patch) {
    if (patch instanceof Batch) {
        return patch._patches.reduce(function (acc, p) { return actuate(acc, sdom, model, p); }, el);
    }
    if (sdom instanceof SDOMElement) {
        if (!(el instanceof HTMLElement))
            throw new Error('actuate: got invalid DOM node');
        Object.keys(sdom._attributes).forEach(function (k) { return applyAttribute(k, sdom._attributes[k], el, model, patch); });
        sdom._childs.forEach(function (s, idx) {
            var ch = el.childNodes[idx];
            var nextCh = actuate(ch, s, model, patch);
            if (ch !== nextCh)
                el.replaceChild(nextCh, ch);
        });
        return el;
    }
    if (sdom instanceof SDOMTextThunk) {
        if (!(el instanceof Text))
            throw new Error('actuate: got invalid DOM node');
        var next = sdom._thunk(model);
        if (el.nodeValue !== next)
            el.nodeValue = next;
        return el;
    }
    if (typeof (sdom) === 'function') {
        if (!(el instanceof Text))
            throw new Error('actuate: got invalid DOM node');
        var next = sdom(model);
        if (el.nodeValue !== next)
            el.nodeValue = next;
        return el;
    }
    if (sdom instanceof SDOMText) {
        return el;
    }
    if (sdom instanceof SDOMDiscriminate) {
        // @ts-ignore
        if (el.dataset.tag !== model[sdom._discriminator]) {
            return create(sdom, model);
        }
        return actuate(el, sdom._tags[model[sdom._discriminator]], model, patch);
    }
    if (sdom instanceof SDOMArray) {
        var array_2 = model[sdom._discriminator];
        // if (!(patch instanceof ObjectPatch)) throw new Error('actuate2: invalid patch');
        if (!(patch instanceof KeyPatch) || patch._key !== sdom._discriminator) {
            array_2.forEach(function (item, idx) {
                var ch = el.childNodes[idx];
                var chPatch = new KeyPatch('model', patch);
                var chModel = ch[NODE_DATA].model;
                if (isReplace(patch))
                    applyPatch(chModel, chPatch, true);
                // @ts-ignore
                var nextCh = actuate(ch, sdom._item, chModel, chPatch);
                if (ch !== nextCh) {
                    nextCh[NODE_DATA] = { model: chModel };
                    el.replaceChild(nextCh, ch);
                }
            });
            return el;
        }
        ;
        var p_1 = patch._patch;
        if (p_1 instanceof ArraySplice) {
            for (var i = p_1._removes - 1; i >= 0; i--) {
                var ch = el.childNodes[p_1._index + i];
                el.removeChild(ch);
            }
            p_1._values.forEach(function (item, idx) {
                var chModel = { item: item, model: model };
                var ch = create(sdom._item, chModel);
                ch[NODE_DATA] = { model: chModel };
                el.insertBefore(ch, el.childNodes[p_1._index + idx] || null);
            });
            return el;
        }
        if (p_1 instanceof KeyPatch) {
            var ch = el.childNodes[p_1._key];
            var chPatch = new KeyPatch('item', patch);
            var chModel = ch[NODE_DATA].model;
            if (isReplace(patch))
                applyPatch(chModel, chPatch, true);
            var nextCh = actuate(ch, sdom._item, chModel, p_1._patch);
            if (ch !== nextCh)
                el.replaceChild(nextCh, ch);
            return el;
        }
        if (p_1 instanceof ArraySwap) {
            var ch1 = el.childNodes[p_1._firstIdx];
            var ch2 = el.childNodes[p_1._secondIdx];
            el.removeChild(ch2);
            el.insertBefore(ch2, ch1);
            el.removeChild(ch1);
            el.insertBefore(ch1, el.childNodes[p_1._secondIdx] || null);
            return el;
        }
        if (p_1 instanceof Replace) {
            return create(sdom, model);
        }
        return absurd(p_1);
    }
    if (sdom instanceof SDOMPick) {
        if (patch instanceof KeyPatch) {
            if (sdom._keys.indexOf(patch._key) === -1)
                return el;
        }
        return actuate(el, sdom._sdom, model, patch);
    }
    if (sdom instanceof SDOMMap) {
        var nextEl = actuate(el, sdom._sdom, model, patch);
        if (nextEl !== el) {
            nextEl[NODE_DATA] = { proj: sdom._proj, model: model };
        }
        else if (isReplace(patch)) {
            nextEl[NODE_DATA].model = applyPatch(nextEl[NODE_DATA].model, patch, true);
        }
        return nextEl;
    }
    if (sdom instanceof SDOMCustom) {
        return sdom._actuate(el, model, patch);
    }
    if (sdom instanceof HasSDOM) {
        return create(sdom.toSDOM(), model);
    }
    ensure(sdom);
    return el;
}
exports.actuate = actuate;
function isReplace(patch) {
    if (patch instanceof Replace)
        return true;
    if (patch instanceof Batch)
        return patch._patches.reduce(function (acc, p) { return acc || isReplace(p); }, false);
    return false;
}
function applyAttribute(name, sdomAttr, el, model, patch) {
    if (sdomAttr instanceof AttrThunk) {
        if (sdomAttr._isPropery) {
            var next = sdomAttr._thunk(model);
            if (el[name] !== next)
                el[name] = next;
        }
        else {
            var next = sdomAttr._thunk(model);
            if (el.getAttribute(name) !== next)
                el.setAttribute(name, next);
        }
        return;
    }
    if (patch)
        return;
    if (sdomAttr instanceof AttrPure) {
        if (sdomAttr._isProperty) {
            el[name] = sdomAttr._value;
        }
        else {
            // @ts-ignore
            el.setAttribute(name, sdomAttr._value);
        }
        return;
    }
    if (sdomAttr instanceof AttrEvent) {
        el.addEventListener(name, createEventListener(sdomAttr._listener));
        return;
    }
    if (typeof (sdomAttr) === 'function') {
        el.addEventListener(name, createEventListener(sdomAttr));
        return;
    }
    ensure(sdomAttr);
    if (name === 'value')
        el[name] = sdomAttr;
    if (typeof (sdomAttr) !== 'string')
        debugger;
    el.setAttribute(name, sdomAttr);
    return;
}
function createEventListener(cb) {
    return function (e) {
        var iter = e.target;
        var action = void 0;
        var actionInitialized = false;
        for (; iter; iter = iter.parentElement) {
            var nodeData = iter[NODE_DATA];
            if (!nodeData)
                continue;
            if (!actionInitialized && ('model' in nodeData)) {
                action = cb(e, nodeData.model);
                actionInitialized = true;
                if (action === void 0)
                    return;
            }
            if (actionInitialized && ('proj' in nodeData)) {
                action = nodeData.proj(action);
            }
        }
    };
}
/** Helper for totality checking */
function absurd(x) {
    throw new Error('absurd: unreachable code');
}
exports.absurd = absurd;
function ensure(value) {
    return value;
}
exports.ensure = ensure;
