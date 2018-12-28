import { absurd } from './types';
// import * as esc from 'sql-escape-string';

const esc = x => x;
const escident = xs => xs.map(escident1).join('.');
const escident1 = x => x === '*' ? x : '`' + x + '`';

export type ScalarExpr<A = any> =
  | Pure<A>
  | Ident<A>
  | Infix<A>
  | Prefix<A>
  | Postfix<A>
  | App<A>
  | In<A>
  | SubQuery<A>
;


export type QueryExpr<A = any> =
  | Select<A>
  | SetOperation<A>
  | With<A>
  // | ['Values', QueryExprRec<T>[][]]
;


export type Statement<A = any> = 
  | Select<A>
  | With<A>
  | SetOperation<A>
;

export type TableRef = 
  | Table
  | Join
  | Func
;


export type JoinType = 'Inner' | 'Left' | 'Right' | 'Full' | 'Cross';

export enum Quantifier {
  All, Distinct,
};

export enum SetOp {
  Union, Except, Intersect,
};

export enum Corresponding {
  Corresponding, Respectively,
};

export type InValue<T = any> =
  | ['InList', ScalarExpr[]]
  | ['InQuery', QueryExpr]
;

export type Canceller = () => void;
export type Consumer<A> = (x: A) => void;
export type Subscribe<A> = (next: Consumer<A>, completed: () => void) => Canceller;
function noopFunc() {}


function pprintStatement(stmt: Statement): string {
  return pprintQueryExpr(stmt);
}

function pprintTableRef(table: TableRef): string {
  if (table instanceof Table) {
    return escident(table._name);
  }  
  if (table instanceof Join) {
    const { _left, _type, _right, _on } = table;
    const chunks = [
      pprintTableRef(_left),
      _type.toUpperCase(),
      'JOIN',
      pprintTableRef(_right),
      _on ? 'ON ' + pprintScalarExpr(_on) : null,
    ];
    return chunks.filter(Boolean).join(' ');
  }

  if (table instanceof TableRefQueryExpr) {
    return pprintQueryExpr(table._expr);
  }  

  if (table instanceof Func) {
    const { _name, _args } = table;
    return escident(name) + '(' + _args.map(pprintScalarExpr).join(', ') + ')';
  }  

  return absurd(table[0]);
}


function pprintScalarExpr(expr: ScalarExpr): string {
  const lparen = ''; //'(';
  const rparen = ''; // ')';
  if (expr instanceof Pure) {
    if (typeof(expr._value) === 'number') return String(expr._value);
    if (typeof(expr._value) === 'string') return JSON.stringify(expr._value);
    throw new Error('Unimplemented');
  }
  if (expr instanceof Ident) {
    return escident(expr._segments);
  }
  if (expr instanceof Infix) {
    const { _op, _left, _right } = expr;
    if (_op === 'AND' && _left instanceof Infix && _left._op === '>=' && _right instanceof Infix && _right._op === '<=' && _left._left === _right._left) {
      return lparen + pprintScalarExpr(_left._left) + ' BETWEEN ' + pprintScalarExpr(_left._right) + ' AND ' + pprintScalarExpr(_right._right) + rparen;
    }
    if (_op === '=' || _op === '!=') return pprintScalarExpr(_left) + ' ' + _op + ' ' + pprintScalarExpr(_right);
    
    return lparen + pprintScalarExpr(_left) + ' ' + _op + ' ' + pprintScalarExpr(_right) + rparen;
  }
  if (expr instanceof Prefix) {
    const { _op, _expr } = expr;
    return lparen + _op + ' ' + pprintScalarExpr(_expr) + rparen;
  }
  if (expr instanceof Postfix) {
    const { _op, _expr } = expr;
    return lparen + pprintScalarExpr(_expr) + ' ' + _op + rparen;
  }
  if (expr instanceof App) {
    const { _name, _args } = expr;
    return escident(_name) + lparen + _args.map(pprintScalarExpr).join(', ') +  rparen;
  }
  if (expr instanceof In) {
    const { _expr, _value } = expr;
    if (_value[0] === 'InList') {
      return lparen + pprintScalarExpr(_expr) + ' IN (' + _value[1].map(pprintScalarExpr).join(', ') + '))';
    }
    if (_value[0] === 'InQuery') {
      return lparen + pprintScalarExpr(_expr) + ' IN ' + pprintQueryExpr(_value[1]) + rparen;
    }
    return absurd(_value[0]);
  }
  if (expr instanceof SubQuery) {
    const ty = expr._type === 'All' ? null : expr._type.toUpperCase();
    return lparen + ty ? ty + ' ' : '' + pprintQueryExpr(expr._expr) + rparen;
  }
  return absurd(expr[0]);
}

function pprintQueryExpr(expr: QueryExpr): string {
  if (expr instanceof Select) {
    const { _quantifier, _fields, _from, _where, _limit, _offset } = expr;
    const chunks = [
      'SELECT',
      _quantifier === Distinct ? 'DISTINCT' : 'ALL',
      _fields.length === 0 ? '*' : _fields.map(([expr, name]) => name ? pprintScalarExpr(expr) + ' AS ' + escident1(name) : pprintScalarExpr(expr)).join(', '),
      _from ? 'FROM ' + _from.map(pprintTableRef).join(', ') : null,
      _where ? 'WHERE ' + pprintScalarExpr(_where) : null,
    ];
    return chunks.join(' ');
  }  
  if (expr instanceof SetOperation) {
    const { _op, _quantifier, _corresponding, _left, _right } = expr;

    const chunks = [
      pprintQueryExpr(_left),
      SetOp[_op].toUpperCase(),
      Quantifier[_quantifier].toUpperCase(),
      Corresponding[_corresponding].toUpperCase(),
      pprintQueryExpr(_right),
    ];
    return '(' + chunks.join(' ') + ')';
  }

  if (expr instanceof With) {
    const { _names, _expr } = expr;
    const bindings = Object.keys(_names).map(k => escident1(k) + ' AS (' + pprintQueryExpr(_names[k]) + ')').join(', ');
    return 'WITH ' + bindings + ' ' + pprintQueryExpr(_expr);
  }
 
  return absurd(expr[0]);
}

function runSql(stmt: Statement, db: any): Subscribe<any> {
  return (next, complete) => {
    const prepared = db.prepare(pprintStatement(stmt)).raw();
    const results = prepared.all();
    next(results);
    complete();
    return noopFunc;
  };
}


function and(first: ScalarExpr, second: ScalarExpr, ...exprs: ScalarExpr[]): ScalarExpr {
  return exprs.reduce((acc, x) => infix(acc, 'AND', x), infix(first, 'AND', second));
}

function infix(left: ScalarExpr, op: string, right: ScalarExpr): ScalarExpr {
  return new Infix(op, left, right);
}

function eq(left: ScalarExpr, right: ScalarExpr): ScalarExpr {
  return infix(left, '=', right);
}

function between(expr: ScalarExpr, min: number, max: number): ScalarExpr {
  return infix(infix(expr, '>=', of(min)), 'AND', infix(expr, '<=', of(max)));
}

function id(...name: string[]): ScalarExpr {
  return new Ident(name);
}

function of(value: number|string): ScalarExpr {
  return new Pure(value);
}

function table(...name: string[]): Table {
  return new Table(name);
}

function with_<A>(names: Record<string, QueryExpr>, expr: QueryExpr<A>): With<A> {
  return new With(names, expr);
}

function join(left: string|string[]|TableRef, right: string|TableRef, options: { on: ScalarExpr, type?: JoinType }): TableRef {
  return new Join(
    left instanceof TableRefBase ? left : new Table(singleton(left)),
    right instanceof TableRefBase ? right : new Table(singleton(right)),
    options.type || 'Left',
    options.on
  );
}

type Singleton<A> = A|A[];

function select(fields: Array<string|string[]|[ScalarExpr, string|null]>, options: { from: Singleton<string|Ident|TableRef>, where?: ScalarExpr, distinct?: boolean, offset?: number, limit?: number }): Select<any> {
  return new Select(
    options.distinct ? Distinct : All,
    fields.map(nomalizeFields),
    Array.isArray(options.from) ? options.from.map(nomalizeTable) : [nomalizeTable(options.from)],
    options.where || null,
    options.offset || null,
    options.limit || null    
  );

  function nomalizeFields(item: typeof fields[number]): [ScalarExpr, string|null] {
    if (typeof(item) === 'string') return [id(item), null];
    if (typeof(item[0]) === 'string') return [id(...item as any), null];
    return item as any;
  }
  
  function nomalizeTable(item: string|Ident|TableRef): TableRef {
    return item instanceof TableRefBase ? item : new Table(item instanceof Ident ? item._segments : [item]);
  }
}

function subquery<A>(expr: QueryExpr<A>): ScalarExpr<A> {
  return new SubQuery('All', expr);
}

function singleton<A>(xs: A|A[]): A[] {
  return Array.isArray(xs) ? xs : [xs];
}

class Pure<A> {
  readonly _A: A;
  constructor(
    readonly _value: A,
  ) {}
}

class Ident<A = any> {
  readonly _A: A;
  constructor(
    readonly _segments: string[],
  ) {}
}

class Infix<A> {
  readonly _A: A;
  constructor(
    readonly _op: string,
    readonly _left: ScalarExpr,
    readonly _right: ScalarExpr,
  ) {}
}

class Prefix<A> {
  readonly _A: A;
  constructor(
    readonly _op: string,
    readonly _expr: ScalarExpr,
  ) {}
}

class Postfix<A> {
  readonly _A: A;
  constructor(
    readonly _op: string,
    readonly _expr: ScalarExpr,
  ) {}
}

class App<A> {
  readonly _A: A;
  constructor(
    readonly _name: Ident<any>,
    readonly _args: ScalarExpr[],
  ) {}
}

class In<A> {
  readonly _A: A;
  constructor(
    readonly _expr: ScalarExpr,
    readonly _value: InValue,
  ) {}
}

class SubQuery<A> {
  readonly _A: A;
  constructor(
    readonly _type: 'Exists'|'Unique'|'All',
    readonly _expr: QueryExpr,
  ) {}
}


//-- [ QueryExpr ] -------------------------------------------------------------

class QueryExprBase<A> {
  with(names: Record<string, QueryExpr>): With<A> {
    return new With(names, this as any as QueryExpr);
  }
  union<B>(expr: QueryExpr<B>): SetOperation<A|B> {
    return new SetOperation(SetOp.Union, All, Corresponding.Corresponding, this as any as QueryExpr, expr);
  }
}

class Select<A> extends QueryExprBase<A> {
  readonly _A: A;
  constructor(
    readonly _quantifier: Quantifier,
    readonly _fields: Array<[ScalarExpr, string|null]>,
    readonly _from: TableRef[],
    readonly _where: ScalarExpr|null,
    readonly _limit: number|null,
    readonly _offset: number|null,
  ) { super(); }
}

class SetOperation<A> extends QueryExprBase<A> {
  readonly _A: A;
  constructor(
    readonly _op: SetOp,
    readonly _quantifier: Quantifier,
    readonly _corresponding: Corresponding,
    readonly _left: QueryExpr,
    readonly _right: QueryExpr,
  ) { super(); }
}

class With<A> extends QueryExprBase<A> {
  readonly _A: A;
  constructor(
    readonly _names: Record<string, QueryExpr>,
    readonly _expr: QueryExpr,
  ) { super(); }
}


//-- [ TableRef ] -------------------------------------------------------------

class TableRefBase {
  join(right: string|string[]|TableRef, options: { type?: JoinType, on: ScalarExpr }) {
    return new Join(this as any as TableRef, right instanceof TableRefBase ? right : new Table(singleton(right)), options.type || 'Left', options.on);
  }
}

class Table extends TableRefBase {
  constructor(
    readonly _name: string[],
  ) { super(); }
}

class Join extends TableRefBase {
  constructor(
    readonly _left: TableRef,
    readonly _right: TableRef,
    readonly _type: JoinType,
    readonly _on: ScalarExpr,
  ) { super(); }
}

class TableRefQueryExpr extends TableRefBase {
  constructor(
    readonly _expr: QueryExpr,
  ) { super(); }
}

class Func extends TableRefBase {
  constructor(
    readonly _name: string[],
    readonly _args: ScalarExpr[],
  ) { super(); }
}

declare const __dirname:any;
declare const require:any;
const Sqlite3 = require('better-sqlite3');
const path = require('path');
const db = new Sqlite3(path.join(__dirname, '../elk.sqlite'));

const { All, Distinct } = Quantifier;

const q01 = select([['tariffs', 'id'], ['tariffs', 'name'], ['services', 'name']], {
  from: table('tariffs').join('services', { on: infix(id('tariffs', 'service_id'), '=', id('services', 'id')) }),
  
  where: infix(
    between(id('tariffs', 'id'), 0, 1000),
    'AND',
    infix(id('tariffs', 'is_deleted'), '!=', of(1)),
  ),
});

const qcountries = subquery(select(['name', 'id'], { from: 'countries', where: eq(id('countries', 'id'), id('tariffs')) }));


const q02 = select([['tariffs', 'id'], ['tariffs', 'name'], ['tariffs', 'service_id'], ['services', 'name']], {
  from: table('tariffs')
    .join('services', { on: infix(id('tariffs', 'service_id'), '=', id('services', 'id')) }),
  
  where: infix(
    between(id('tariffs', 'id'), 0, 1000),
    'AND',
    infix(id('tariffs', 'is_deleted'), '!=', of(1)),
  ),
});


const q03 = select([['t', '*'], ['countries', 'name']], {
  from: ['countries', 'countries_services', 't'],
  where: and(
    eq(
      id('countries', 'id'),
      id('countries_services', 'country_id'),
    ),
    eq(
      id('t', 'service_id'),
      id('countries_services', 'service_id'),
    ),    
  )
}).with({
  t: q02,
});


console.log(JSON.stringify(q03));
console.log('// => ' + pprintStatement(q03));
runSql(q03, db)((results) => {
  console.log(results);
}, () => console.log('complete'));
