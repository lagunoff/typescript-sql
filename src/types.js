"use strict";
exports.__esModule = true;
/** Don't coerce string literals to `string` type */
function literal(x) {
    return x;
}
exports.literal = literal;
function absurd(x) {
    throw new Error('absurd: unreachable code');
}
exports.absurd = absurd;
/** Helper for totality checking */
function ensure(x) {
}
exports.ensure = ensure;
