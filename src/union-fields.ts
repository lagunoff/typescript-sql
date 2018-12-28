import { absurd } from './types';
import { QueryExpr, Select, SetOperation, With, TableRef, Table, TableRefQueryExpr, Func, Join, escident, Statement, SetOp, select, id, of, ScalarExpr } from './index';


export function prepareUnion(db: any) {
  function prepareQueryExpr(expr: QueryExpr): QueryExpr {
    if (expr instanceof SetOperation) {
      const { _op, _left, _right } = expr;
      if (_op === SetOp.Union) {
        const numLeft = numFields(_left, db);
        const numRight = numFields(_right, db);
        expr._left = numLeft < numRight ? addColumns(numRight - numLeft, _left) : _left;
        expr._right = numRight < numLeft ? addColumns(numLeft - numRight, _right) : _right;
        return expr;
      }
      return expr;
    }
    
    return expr;

    function addColumns(n: number, expr: QueryExpr): QueryExpr {
      const nulls = Array.from(Array(n)).map(() => of(null));
      return select([[id('*'), null], ...nulls], { from: new TableRefQueryExpr(expr) });
    }
  }

  return { prepareQueryExpr };
}


function numFields(expr: QueryExpr, db: any): number {
  if (expr instanceof Select) {
    const { _fields, _from } = expr;
    if (_fields.length === 0) {
      return _from.reduce((acc, f) => numFieldsTableRef(f, db) + acc, 0);
    }
    return _fields.length;
  }  
  if (expr instanceof SetOperation) {
    const { _left } = expr;
    return numFields(_left, db);
  }

  if (expr instanceof With) {
    const { _expr } = expr;
    return numFields(_expr, db);
  }
  
  return absurd(expr[0]);
}


function numFieldsTableRef(table: TableRef, db: any): number {
  if (table instanceof Table) {
    const info = db.prepare('PRAGMA table_info(' + escident(table._name) + ')').all();
    console.log('PRAGMA table_info(?):', info);
    return info.length;
  }
  if (table instanceof TableRefQueryExpr) {
    return numFields(table._expr, db);
  }
  if (table instanceof Func) {
    // TODO: make sure that this always results only in one column
    return 1;
  }
  if (table instanceof Join) {
    return numFieldsTableRef(table._left, db) + numFieldsTableRef(table._right, db);
  }
  return absurd(table);    
}
