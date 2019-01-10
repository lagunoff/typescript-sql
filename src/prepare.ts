import { absurd } from './types';
import { QueryExpr, Select, SetOperation, With, TableRef, Table, TableRefQueryExpr, Func, Join, Statement, ScalarExpr, Pure, Ident, Infix, Prefix, Postfix, App, In, SubQuery } from './index';


export type Plugin = {
  prepareStatement?(stmt: Statement): Statement;
  prepareScalarExpr?(expr: ScalarExpr): ScalarExpr;
  prepareQueryExpr?(expr: QueryExpr): QueryExpr;
};


export function prepareStatement(plugins: Plugin[], stmt: Statement) {
  

  return { prepareQueryExpr };
}

export function prepareScalarExpr(plugins: Plugin[], expr: ScalarExpr): ScalarExpr {
  const next = plugins.reduce((acc, p) => p.prepareScalarExpr ? p.prepareScalarExpr(acc) : acc, expr);

  if (next instanceof Pure) {
    return next;
  }
  if (next instanceof Ident) {
    return next;
  }
  if (next instanceof Infix) {
    next._left = prepareScalarExpr(plugins, next._left);
    next._right = prepareScalarExpr(plugins, next._right);
    return next;
  }
  if (next instanceof Prefix) {
    next._expr = prepareScalarExpr(plugins, next._expr);
    return next;
  }
  if (next instanceof Postfix) {
    next._expr = prepareScalarExpr(plugins, next._expr);
    return next;
  }
  if (next instanceof App) {
    for (let i = 0; i < next._args.length; i++) next._args[i] = prepareScalarExpr(plugins, next._args[i]);
    return next;
  }
  if (next instanceof In) {
    const { _value } = next;
    next._expr = prepareScalarExpr(plugins, next._expr);
    
    if (_value[0] === 'InList') {
      for (let i = 0; i < _value[1].length; i++) _value[1][i] = prepareScalarExpr(plugins, _value[1][i]);
    }
    if (_value[0] === 'InQuery') {
      _value[1] = prepareQueryExpr(plugins, _value[1]);
    }
    return next;
  }
  
  if (next instanceof SubQuery) {
    next._expr = prepareQueryExpr(plugins, next._expr);
    return next;
  }
  
  return absurd(next);
}

export function prepareTableRef(plugins: Plugin[], table: TableRef): TableRef {
  if (table instanceof Table) {
    return table;
  }
  
  if (table instanceof Join) {
    table._left = prepareTableRef(plugins, table._left);
    table._right = prepareTableRef(plugins, table._right);
    return table;
  }

  if (table instanceof TableRefQueryExpr) {
    table._expr = prepareQueryExpr(plugins, table._expr);
    return table;    
  }  

  if (table instanceof Func) {
    for (let i = 0; i < table._args.length; i++) table._args[i] = prepareScalarExpr(plugins, table._args[i]);
    return table;
  }  

  return absurd(table);
}

export function prepareQueryExpr(plugins: Plugin[], expr: QueryExpr): QueryExpr {
  const next = plugins.reduce((acc, p) => p.prepareQueryExpr ? p.prepareQueryExpr(acc) : acc, expr);

  if (next instanceof Select) {
    const { _selectList, _from, _where } = next;
    _selectList.forEach(pair => {
      if (Array.isArray(pair)) pair[0] = prepareScalarExpr(plugins, pair[0])
    });
    next._where = _where ? prepareScalarExpr(plugins, _where) : _where;
    for (let i = 0; i < _from.length; i++) _from[i] = prepareTableRef(plugins, _from[i]);
    return next;
  }
  
  if (next instanceof SetOperation) {
    const { _left, _right } = next;
    next._left = prepareQueryExpr(plugins, _left);
    next._right = prepareQueryExpr(plugins, _right);
    return next;
  }

  if (next instanceof With) {
    const { _names, _expr } = next;
    next._expr = prepareQueryExpr(plugins, _expr);
    for (const k in _names) {
      _names[k] = prepareQueryExpr(plugins, _names[k]);
    }
    return next;
  }
 
  return absurd(next);
}
