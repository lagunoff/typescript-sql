import { absurd } from './types';
import { prepareQueryExpr } from './prepare';
import { prepareUnion } from './union-fields';
// import * as esc from 'sql-escape-string';

export const esc = (x: string) => x;
export const escident = (xs: string[]) => xs.map(escident1).join('.');
export const escident1 = (x: string) => x === '*' ? x : '`' + x.replace(/`/g, '\`') + '`';

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
  | Pragma<A>
;


export type TableRef = 
  | Table
  | Join
  | Func
  | TableRefQueryExpr
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
  | ['InQuery', QueryExpr<T>]
;

export type Canceller = () => void;
export type Consumer<A> = (x: A) => void;
export type Subscribe<A> = (next: Consumer<A>, completed: () => void) => Canceller;
export function noopFunc() {}


export function pprintStatement(stmt: Statement): string {
  if (stmt instanceof Pragma) {
    const { _name, _args } = stmt;
    return 'PRAGMA ' + escident1(_name) + '(' + _args.map(pprintScalarExpr).join(', ') + ')';
  }
  return pprintQueryExpr(stmt);
}

export function pprintTableRef(table: TableRef): string {
  if (table instanceof Table) {
    return escident(table._name);
  }  
  if (table instanceof Join) {
    const { _left, _type, _right, _on, _natural } = table;
    const chunks = [
      pprintTableRef(_left),
      _type.toUpperCase(),
      _natural ? 'NATURAL' : null,
      'JOIN',
      pprintTableRef(_right),
      _on ? 'ON ' + pprintScalarExpr(_on) : null,
    ];
    return chunks.filter(Boolean).join(' ');
  }

  if (table instanceof TableRefQueryExpr) {
    return '(' + pprintQueryExpr(table._expr) + ')';
  }  

  if (table instanceof Func) {
    const { _name, _args } = table;
    return escident(_name) + '(' + _args.map(pprintScalarExpr).join(', ') + ')';
  }

  return absurd(table);
}


export function pprintScalarExpr(expr: ScalarExpr): string {
  const lparen = ''; //'(';
  const rparen = ''; // ')';
  if (expr instanceof Pure) {
    if (typeof(expr._value) === 'number') return String(expr._value);
    if (typeof(expr._value) === 'string') return JSON.stringify(expr._value);
    if (expr._value === null) return 'NULL';
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
    return escident(_name._segments) + '(' + _args.map(pprintScalarExpr).join(', ') + ')';
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

export function pprintQueryExpr(expr: QueryExpr): string {
  if (expr instanceof Select) {
    const { _quantifier, _selectList, _from, _where, _limit, _offset } = expr;
    const selectList = _selectList.map(pairOrStar => {
      if (pairOrStar instanceof Star) {
        return pairOrStar._qualified.length === 0 ? '*' : escident(pairOrStar._qualified) + '.*';
      }
      const [expr, name] = pairOrStar;
      return name ? pprintScalarExpr(expr) + ' AS ' + escident1(name) : pprintScalarExpr(expr);
    }).join(', ');
    const chunks = [
      'SELECT',
      _quantifier === All ? null : Quantifier[_quantifier].toUpperCase(),
      selectList,
      _from ? 'FROM ' + _from.map(pprintTableRef).join(', ') : null,
      _where ? 'WHERE ' + pprintScalarExpr(_where) : null,
      _limit !== null ? 'LIMIT ' + _limit : null,
      _offset !== null ? 'OFFSET ' + _offset : null,
    ];
    return chunks.filter(Boolean).join(' ');
  }  
  if (expr instanceof SetOperation) {
    const { _op, _quantifier, _corresponding, _left, _right } = expr;

    const chunks = [
      pprintQueryExpr(_left),
      SetOp[_op].toUpperCase(),
      Quantifier[_quantifier].toUpperCase(),
      _corresponding === Corresponding.Corresponding ? null : Corresponding[_corresponding].toUpperCase(),
      pprintQueryExpr(_right),
    ];
    return 'SELECT * FROM (' + chunks.filter(Boolean).join(' ') + ')';
  }

  if (expr instanceof With) {
    const { _names, _expr } = expr;
    const bindings = Object.keys(_names).map(k => escident1(k) + ' AS (' + pprintQueryExpr(_names[k]) + ')').join(', ');
    return 'WITH ' + bindings + ' ' + pprintQueryExpr(_expr);
  }
 
  return absurd(expr[0]);
}

export function runSql(stmt: Statement, db: any): Subscribe<any> {
  return (next, complete) => {
    const prepared = db.prepare(pprintStatement(stmt)).raw();
    const results = prepared.all();
    next(results);
    complete();
    return noopFunc;
  };
}

type ExprOrIdent = ScalarExpr|string|Triple;
interface Triple {
  0: ExprOrIdent;
  1: string;
  2: ExprOrIdent;
}

export function normalizeExpr(x: ExprOrIdent): ScalarExpr {
  if (x instanceof ScalarExprBase) return x;
  if (typeof(x) === 'string') return new Ident(x.split('.'));
  const { 0: left, 1: op, 2: right } = x;
  return new Infix(op, normalizeExpr(left), normalizeExpr(right));
}

export function and(first: ExprOrIdent, second: ExprOrIdent, ...exprs: Array<ExprOrIdent>): ScalarExpr {
  return exprs.reduce<ScalarExpr>((acc, x) => new Infix('AND', acc, normalizeExpr(x)), new Infix('AND', normalizeExpr(first), normalizeExpr(second)));
}

export function or(first: ExprOrIdent, second: ExprOrIdent, ...exprs: Array<ExprOrIdent>): ScalarExpr {
  return exprs.reduce<ScalarExpr>((acc, x) => new Infix('OR', acc, normalizeExpr(x)), new Infix('OR', normalizeExpr(first), normalizeExpr(second)));
}

export function infix(left: ExprOrIdent, op: string, right: ExprOrIdent): ScalarExpr {
  return new Infix(op, normalizeExpr(left), normalizeExpr(right));
}

export function eq(left: ExprOrIdent, right: ExprOrIdent): ScalarExpr {
  return infix(left, '=', right);
}

export function between(expr: ExprOrIdent, min: number, max: number): ScalarExpr {
  return infix(infix(expr, '>=', of(min)), 'AND', infix(expr, '<=', of(max)));
}

export function id(...name: string[]): ScalarExpr {
  return new Ident(name);
}

export function of(value: number|string|null): ScalarExpr {
  return new Pure(value);
}

export function table(...name: string[]): Table {
  return new Table(name);
}

export function with_<A>(names: Record<string, QueryExpr>, expr: QueryExpr<A>): With<A> {
  return new With(names, expr);
}

export function pragma(name: string, ...args: ExprOrIdent[]): Pragma {
  return new Pragma(name, args.map(normalizeExpr));
}

type JoinOptions = { type?: JoinType, on?: ScalarExpr|Triple, natural?: boolean };

export function join(left: string|string[]|TableRef, right: string|string[]|TableRef, options: JoinOptions): TableRef {
  return new Join(
    left instanceof TableRefBase ? left : new Table(singleton(left)),
    right instanceof TableRefBase ? right : new Table(singleton(right)),
    options.type || 'Left',
    options.natural || false,
    options.on ? normalizeExpr(options.on) : void 0,
  );
}

type Singleton<A> = A|A[];
type SelectListItem = string|ScalarExpr|[ScalarExpr|string, string|null];
type SelectOptions = { from?: Singleton<string|TableRef>, where?: ScalarExpr, distinct?: boolean, offset?: number, limit?: number };

export function select(...args: Array<SelectListItem|SelectOptions>): Select<any> {
  type Acc = { selectList: Select<any>['_selectList'], options: SelectOptions };
  const { selectList, options } = args.reduce<Acc>((acc, x) => {
    if (typeof(x) === 'string') {
      const segments = x.split('.');
      const lastSegment = segments[segments.length - 1];
      if (lastSegment === '*') acc.selectList.push(new Star(segments.slice(0, segments.length - 1)));
      else acc.selectList.push([new Ident(segments), null]);
    }
    if (x instanceof ScalarExprBase) {
      acc.selectList.push([x, null]);
    }
    if (Array.isArray(x)) {
      const [val, col] = x;
      if (typeof(val) === 'string') {
        const segments = val.split('.');
        acc.selectList.push([new Ident(segments), col]);
      }
      if (val instanceof ScalarExprBase) {
        acc.selectList.push([val, col]);
      }
    }
    else if (typeof(x) === 'object') {
      Object.assign(acc.options, x);
    }
    return acc;
  }, { selectList: [], options: {} });
  
  return new Select(
    options.distinct ? Distinct : All,
    selectList,
    options.from === undefined ? [] : Array.isArray(options.from) ? options.from.map(nomalizeTable) : [nomalizeTable(options.from)],
    options.where || null,
    options.offset || null,
    options.limit || null,
  );
  
  function nomalizeTable(item: string|Ident|TableRef): TableRef {
    return item instanceof TableRefBase ? item : new Table(item instanceof Ident ? item._segments : [item]);
  }
}

export function subquery<A>(expr: QueryExpr<A>): ScalarExpr<A> {
  return new SubQuery('All', expr);
}

export function singleton<A>(xs: A|A[]): A[] {
  return Array.isArray(xs) ? xs : [xs];
}


export class ScalarExprBase<A> {
  readonly _A: A;
}

export class Pure<A> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _value: A,
  ) { super(); }
}

export class Ident<A = any> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _segments: string[],
  ) { super(); }
}

export class Infix<A> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _op: string,
    public _left: ScalarExpr,
    public _right: ScalarExpr,
  ) { super(); }
}

export class Prefix<A> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _op: string,
    public _expr: ScalarExpr,
  ) { super(); }
}

export class Postfix<A> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _op: string,
    public _expr: ScalarExpr,
  ) { super(); }
}

export class App<A> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _name: Ident<any>,
    public _args: ScalarExpr[],
  ) { super(); }
}

export class In<A> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _expr: ScalarExpr,
    public _value: InValue,
  ) { super(); }
}

export class SubQuery<A> extends ScalarExprBase<A> {
  readonly _A: A;
  constructor(
    public _type: 'Exists'|'Unique'|'All',
    public _expr: QueryExpr,
  ) { super(); }
}


//-- [ Statement ] -------------------------------------------------------------

export class Pragma<A = any> {
  readonly _A: A;
  
  constructor(
    readonly _name: string,
    readonly _args: ScalarExpr[],
  ) {}
}


//-- [ QueryExpr ] -------------------------------------------------------------

export class QueryExprBase<A> {
  with(names: Record<string, QueryExpr>): With<A> {
    return new With(names, this as any as QueryExpr);
  }
  union<B>(expr: QueryExpr<B>): SetOperation<A|B> {
    return new SetOperation(SetOp.Union, All, Corresponding.Corresponding, this as any as QueryExpr, expr);
  }
}

export class Select<A> extends QueryExprBase<A> {
  readonly _A: A;
  constructor(
    public _quantifier: Quantifier,
    public _selectList: Array<[ScalarExpr, string|null]|Star>,
    public _from: TableRef[],
    public _where: ScalarExpr|null,
    public _offset: number|null,
    public _limit: number|null,
  ) { super(); }
}

export class SetOperation<A> extends QueryExprBase<A> {
  readonly _A: A;
  constructor(
    public _op: SetOp,
    public _quantifier: Quantifier,
    public _corresponding: Corresponding,
    public _left: QueryExpr,
    public _right: QueryExpr,
  ) { super(); }

  clone(patch?: Partial<SetOperation<A>>) {
    const { _op, _quantifier, _corresponding, _left, _right } = { ...patch, ...this };
    return new SetOperation(_op, _quantifier, _corresponding, _left, _right);
  }
}

export class With<A> extends QueryExprBase<A> {
  readonly _A: A;
  constructor(
    public _names: Record<string, QueryExpr>,
    public _expr: QueryExpr,
  ) { super(); }
}

export class Star {
  constructor(
    public _qualified: string[],
  ) {}
}


//-- [ TableRef ] -------------------------------------------------------------

export class TableRefBase {
  join(right: string|string[]|TableRef, options: JoinOptions = {}) {
    return join(this as any, right, options);
  }
}

export class Table extends TableRefBase {
  constructor(
    public _name: string[],
  ) { super(); }
}

export class Join extends TableRefBase {
  constructor(
    public _left: TableRef,
    public _right: TableRef,
    public _type: JoinType,
    public _natural: boolean,
    public _on?: ScalarExpr,
  ) { super(); }
}

export class TableRefQueryExpr extends TableRefBase {
  constructor(
    public _expr: QueryExpr,
  ) { super(); }
}

export class Func extends TableRefBase {
  constructor(
    public _name: string[],
    public _args: ScalarExpr[],
  ) { super(); }
}

export class TableDefinition {
  constructor(
    public _name: string,
    public _columns: ColumnDefinition[],
  ) { }
}

export class ColumnDefinition {
  constructor(
    public _name: string,
    public _type: string,
    public _default: string,
  ) { }
}

declare const __dirname:any;
declare const require:any;
const Sqlite3 = require('better-sqlite3');
const path = require('path');
const db = new Sqlite3(path.join(__dirname, '../elk.sqlite'));

const { All, Distinct } = Quantifier;

const q01 = select('tariffs.id', 'tariffs.name', 'services.name', {
  from: table('tariffs').join('services', { on: ['tariffs.service_id', '=', 'services.id'] }),
  
  where: and(
    between('tariffs.id', 0, 1000),
    ['tariffs.is_deleted', '!=', of(1)],
  ),
});

// const qcountries = subquery(select(['name', 'id'], { from: 'countries', where: eq(id('countries', 'id'), id('tariffs')) }));


const q02 = select('tariffs.id', 'tariffs.name', 'tariffs.service_id', 'services.name', {
  from: table('tariffs')
    .join('services', { on: ['tariffs.service_id', '=', 'services.id'] }),
  
  where: and(
    between('tariffs.id', 0, 1000),
    ['tariffs.is_deleted', '!=', of(1)],
  ),
});

const q03 = select(
  of('tariffs'), 'id', 'name', 't.name:1', { from: 't' }
).union(
  select(of('countries'), 'countries.name', of(null), of(null), {
    from: ['countries', 'countries_services', 't'],
    where: and(
      ['countries.id', '=', 'countries_services.country_id'],
      ['t.service_id', '=', 'countries_services.service_id'],
    )
  })
).with({
  t: q02,
});


const q04 = select(of('service'), 'services.id', 'services.name', 'countries.name', {
  from: ['services', 'countries_services', 'countries'],
  limit: 5,
  where: and(
    ['services.id', '=', 'countries_services.service_id'],
    ['countries_services.country_id', '=', 'countries.id'],
  ),
});

const q05 = pragma('table_info', 'countries');

setTimeout(() => {
  const plugins = [prepareUnion(db)];
  const queue = [q04, q05]; //.map(x => prepareQueryExpr(plugins, x));

  queue.forEach(q => {
    // console.log(JSON.stringify(q));
    console.log('// => ' + pprintStatement(q));
    runSql(q, db)((results) => {
      console.log(results);
    }, () => console.log('ceomplete'));
  });
});

namespace play {
  const and: any = 0;
  const not: any = 0;
  
  export const q = x => and(
    ['countries.id', '=', 'countries_services.country_id'],
    ['countries.id', '=', 'countries_services.country_id'],
    not(['countries.id', '=', 'countries_services.country_id']),
  );
}


namespace privileges {
  type CRUD = 'C'|'R'|'U'|'D';
  type Access =
    | { tag: 'Deny' }
    | { tag: 'Allow' }
    | { tag: 'Columns', table: string, columns: string[], access: CRUD[] }
    | { tag: 'Rows', table: string, access: ScalarExpr<boolean> }
    | { tag: 'Not', access: Access }
    | { tag: 'And', access: Access[] }
}
