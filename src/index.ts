import { absurd } from './types';
// import * as esc from 'sql-escape-string';

const esc = x => x;
const ident = xs => xs.map(x => '`' + x + '`');

export type ScalarExpr<T = any> =
  | ['Num', number]
  | ['Str', string]
  | ['Ident', string[]]
  | ['BinOp', string, ScalarExprRec<any>, ScalarExprRec<any>]
  | ['PrefixOp', string, ScalarExprRec<any>]
  | ['PostfixOp', string, ScalarExprRec<any>]
  | ['Between', ScalarExprRec<any>, number, number]
  | ['App', string[], ScalarExprRec<T>[]]
  | ['In', ScalarExprRec<T>, InValue<any>]
;

export type QueryExpr<T = any> =
  | ['Select', Quantifier, string[], string, ScalarExprRec<boolean>|null, number|null, number|null]
  | ['SetOp', SetOp, Quantifier, Corresponding, QueryExprRec<any>, QueryExprRec<any>]
  | ['With', Array<[string, QueryExprRec<T>]>, QueryExprRec<T>]
  | ['Values', QueryExprRec<T>[][]]
;

export type Statement<T = any> = 
  | ['Select', Quantifier, string[], string, ScalarExprRec<boolean>|null, number|null, number|null]
;

export enum Quantifier {
  All, Distinct,
};

export enum SetOp {
  Union, Except, Intersect,
};

export enum Corresponding {
  Corresponding, Respectively,
};

export type InValue<T> =
  | ['InList', ScalarExprRec<any>[]]
  | ['InQuery', QueryExpr<any>]
;

const fromRec = <T>(x: ScalarExprRec<T>) => x as any as ScalarExpr<T>;
const toRec = <T>(x: ScalarExpr<T>) => x as any as ScalarExprRec<T>;

const unwrap = Symbol('ScalarExprRec');
export type ScalarExprRec<T> = { [unwrap]: ScalarExpr<T> }

const fromRec2 = <T>(x: QueryExprRec<T>) => x as any as QueryExpr<T>;
const toRec2 = <T>(x: QueryExpr<T>) => x as any as QueryExprRec<T>;

export type QueryExprRec<T> = { [unwrap]: QueryExpr<T> }


export type Canceller = () => void;
export type Consumer<A> = (x: A) => void;
export type Subscribe<A> = (next: Consumer<A>, completed: () => void) => Canceller;
function noopFunc() {}

function pprintStatement(sql: Statement): string {
  if (sql[0] === 'Select') {
    const [tag, quantifier, list, from, where, limit, offset] = sql;
    const query = [
      'SELECT',
      quantifier === Distinct ? 'DISTINCT' : 'ALL',
      list.map(esc).join(', '),
      from ? 'FROM ' + esc(from) : null,
      where ? 'WHERE ' + pprintScalarExpr(fromRec(where)) : null,
    ];
    return query.join(' ');
  }  
  return absurd(sql[0]);
}

function pprintScalarExpr(sql: ScalarExpr): string {
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
    const [tag, op, left, right] = sql;
    return '(' + pprintScalarExpr(fromRec(left)) + ' ' + op + ' ' + pprintScalarExpr(fromRec(right)) + ')';
  }
  if (sql[0] === 'PrefixOp') {
    const [tag, op, expr] = sql;
    return '(' + op + ' ' + pprintScalarExpr(fromRec(expr)) + ')';
  }
  if (sql[0] === 'PostfixOp') {
    const [tag, op, expr] = sql;
    return '(' + pprintScalarExpr(fromRec(expr)) + ' ' + op + ')';
  }
  if (sql[0] === 'Between') {
    const [tag, expr, min, max] = sql;
    return '(' + pprintScalarExpr(fromRec(expr)) + ' BETWEEN ' + min + ' AND ' + max + ')';
  }
  if (sql[0] === 'App') {
    const [tag, name, args] = sql;
    return name.map(esc).join('.') + '(' + args.map(fromRec).map(pprintScalarExpr).join(', ') +  ')';
  }
  if (sql[0] === 'In') {
    const [tag, expr, value] = sql;
    if (value[0] === 'InList') {
      return '(' + pprintScalarExpr(fromRec(expr)) + ' IN (' + value[1].map(fromRec).map(pprintScalarExpr).join(', ') + '))';
    }
    if (value[0] === 'InQuery') {
      return '(' + pprintScalarExpr(fromRec(expr)) + ' IN ' + pprintQueryExpr(value[1]) + ')';
    }
    return absurd(value[0]);
  }
  return absurd(sql[0]);
}

function pprintQueryExpr(sql: QueryExpr): string {
  if (sql[0] === 'Select') {
    return pprintStatement(sql);
  }  
  if (sql[0] === 'SetOp') {
    const [tag, op, quantifier, corresponding, left, right] = sql;

    const query = [
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
 
  return absurd(sql[0]);
}

function runSql(sql: Statement, db: any): Subscribe<any> {
  return (next, complete) => {
    if (sql[0] === 'Select') {
      const stmt = db.prepare(pprintStatement(sql)).raw();
      const results = stmt.all();
      next(results);
      complete();
      return;
    }
    return absurd(sql[0]);
  };
}

declare const __dirname:any;
declare const require:any;
const Sqlite3 = require('better-sqlite3');
const path = require('path');
const db = new Sqlite3(path.join(__dirname, '../elk.sqlite'));

const { All, Distinct } = Quantifier;
// @ts-ignore
const sql = [
  'Select', All, ['id', 'name', 'advance_payment'], 'tariffs',
  ['BinOp', 'And',
   ['Between', ['Ident', ['id']], 0, 1000],
   ['BinOp', '!=', ['Ident', ['is_deleted']], ['Num', 1]],
  ],
  null, null
];

console.log(JSON.stringify(sql));
console.log('// => ' + pprintStatement(sql as any));
runSql(sql as any, db)((results) => {
  console.log(results);
}, () => console.log('complete'));


