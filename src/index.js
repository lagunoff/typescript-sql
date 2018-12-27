Object.defineProperty(exports, "__esModule", { value: true });
var types_1 = require("./types");
// import * as esc from 'sql-escape-string';
var esc = function (x) { return x; };
var ident = function (xs) { return xs.map(function (x) { return '`' + x + '`'; }); };
var Quantifier;
(function (Quantifier) {
    Quantifier[Quantifier["All"] = 0] = "All";
    Quantifier[Quantifier["Distinct"] = 1] = "Distinct";
})(Quantifier = exports.Quantifier || (exports.Quantifier = {}));
;
var SetOp;
(function (SetOp) {
    SetOp[SetOp["Union"] = 0] = "Union";
    SetOp[SetOp["Except"] = 1] = "Except";
    SetOp[SetOp["Intersect"] = 2] = "Intersect";
})(SetOp = exports.SetOp || (exports.SetOp = {}));
;
var Corresponding;
(function (Corresponding) {
    Corresponding[Corresponding["Corresponding"] = 0] = "Corresponding";
    Corresponding[Corresponding["Respectively"] = 1] = "Respectively";
})(Corresponding = exports.Corresponding || (exports.Corresponding = {}));
;
var fromRec = function (x) { return x; };
var toRec = function (x) { return x; };
var unwrap = Symbol('ScalarExprRec');
var fromRec2 = function (x) { return x; };
var toRec2 = function (x) { return x; };
function pprintStatement(sql) {
    if (sql[0] === 'Select') {
        var tag = sql[0], quantifier = sql[1], list = sql[2], from = sql[3], where = sql[4], limit = sql[5], offset = sql[6];
        var query = [
            'SELECT',
            quantifier === Distinct ? 'DISTINCT' : 'ALL',
            list.map(esc).join(', '),
            from ? 'FROM ' + esc(from) : null,
            where ? 'WHERE ' + pprintScalarExpr(fromRec(where)) : null,
        ];
        return query.join(' ');
    }
    return types_1.absurd(sql[0]);
}
function pprintScalarExpr(sql) {
    if (sql[0] === 'Num') {
        return JSON.stringify(sql[1]);
    }
    if (sql[0] === 'Str') {
        return JSON.stringify(sql[1]);
    }
    if (sql[0] === 'Ident') {
        return ident(sql[1]);
    }
    if (sql[0] === 'BinOp') {
        var tag = sql[0], op = sql[1], left = sql[2], right = sql[3];
        return '(' + pprintScalarExpr(fromRec(left)) + ' ' + op + ' ' + pprintScalarExpr(fromRec(right)) + ')';
    }
    if (sql[0] === 'PrefixOp') {
        var tag = sql[0], op = sql[1], expr = sql[2];
        return '(' + op + ' ' + pprintScalarExpr(fromRec(expr)) + ')';
    }
    if (sql[0] === 'PostfixOp') {
        var tag = sql[0], op = sql[1], expr = sql[2];
        return '(' + pprintScalarExpr(fromRec(expr)) + ' ' + op + ')';
    }
    if (sql[0] === 'Between') {
        var tag = sql[0], expr = sql[1], min = sql[2], max = sql[3];
        return '(' + pprintScalarExpr(fromRec(expr)) + ' BETWEEN ' + min + ' AND ' + max + ')';
    }
    if (sql[0] === 'App') {
        var tag = sql[0], name_1 = sql[1], args = sql[2];
        return name_1.map(esc).join('.') + '(' + args.map(fromRec).map(pprintScalarExpr).join(', ') + ')';
    }
    if (sql[0] === 'In') {
        var tag = sql[0], expr = sql[1], value = sql[2];
        if (value[0] === 'InList') {
            return '(' + pprintScalarExpr(fromRec(expr)) + ' IN (' + value[1].map(fromRec).map(pprintScalarExpr).join(', ') + '))';
        }
        if (value[0] === 'InQuery') {
            return '(' + pprintScalarExpr(fromRec(expr)) + ' IN ' + pprintQueryExpr(value[1]) + ')';
        }
        return types_1.absurd(value[0]);
    }
    return types_1.absurd(sql[0]);
}
function pprintQueryExpr(sql) {
    if (sql[0] === 'Select') {
        return pprintStatement(sql);
    }
    if (sql[0] === 'SetOp') {
        var tag = sql[0], op = sql[1], quantifier = sql[2], corresponding = sql[3], left = sql[4], right = sql[5];
        var query = [
            pprintQueryExpr(fromRec2(left)),
            SetOp[op].toUpperCase(),
            Quantifier[quantifier].toUpperCase(),
            Corresponding[corresponding].toUpperCase(),
            pprintQueryExpr(fromRec2(right)),
        ];
        return '(' + query.join(' ') + ')';
    }
    if (sql[0] === 'With') {
        throw new Error('Unimplemented');
    }
    if (sql[0] === 'Values') {
        throw new Error('Unimplemented');
    }
    return types_1.absurd(sql[0]);
}
function runSql(sql, db) {
    return function (cb) {
        if (sql[0] === 'Select') {
            var tag = sql[0], quantifier = sql[1], list = sql[2], from = sql[3], where = sql[4], limit = sql[5], offset = sql[6];
            var query = pprintStatement(sql);
            console.log('performing "' + query + '"…');
            db.each(query, cb);
            return;
        }
        return types_1.absurd(sql[0]);
    };
}
var sqlite3 = require('sqlite3');
var path = require('path');
var db = new sqlite3.Database(path.join(__dirname, '../elk.sqlite'));
var All = Quantifier.All, Distinct = Quantifier.Distinct;
// @ts-ignore
var sql = ['Select', All, ['id', 'name'], 'tariffs', ['BinOp', '=', ['Ident', ['id']], ['Num', 15]], null, null];
console.log(sql);
runSql(sql, db)(function (err, row) {
    if (err)
        console.log('err', err);
    else
        console.log(row);
});
