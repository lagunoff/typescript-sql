import { escident, Statement, escident1, TableRef, Table, Join, TableRefQueryExpr, Func, ScalarExpr, Pure, Ident, Infix, Prefix, Postfix, App, In, SubQuery, QueryExpr, Select, Star, All, Quantifier, SetOperation, SetOp, Corresponding, With, normalizeExpr, StatementExtension, ExprOrIdent } from './index';
import { absurd } from './types';


export class Pragma<A = any> extends StatementExtension<A> {
  readonly _A: A;
  
  constructor(
    public _name: string,
    public _args: ScalarExpr[],
  ) { super(); }

  pprint() {
    const { _name, _args } = this;
    return 'PRAGMA ' + escident1(_name) + '(' + _args.map(pprintScalarExpr).join(', ') + ')';    
  }
}


export type Canceller = () => void;
export type Consumer<A> = (x: A) => void;
export type Subscribe<A> = (next: Consumer<A>, completed: () => void) => Canceller;
export function noopFunc() {}


export function pprintStatement(stmt: Statement): string {
  if (stmt instanceof StatementExtension) {
    return stmt.pprint();
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


export function pragma(name: string, ...args: ExprOrIdent[]): Pragma {
  return new Pragma(name, args.map(normalizeExpr));
}
