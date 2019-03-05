import * as t from './type-rep';
import { ToTypeRep, TypeRep, TypeRepBase } from './type-rep';


export type SQLiteColumnOptions = {
  sqlType?: 'TEXT'|'NUMERIC'|'INTEGER'|'REAL'|'BLOB';
  primary?: boolean;
  unique?: boolean;
  nullable?: boolean;
  foreign?: { table: string, columns: string[] };
};


export class SQLiteColumnAnnotation<A> extends ToTypeRep<A> {
  constructor(
    readonly _value: TypeRep<A>,
    readonly _options: SQLiteColumnOptions,
  ) { super(); }
  
  toTypeRep() {
    return this._value;
  }
}


declare module "./type-rep" {
  interface TypeRepBase<A> {
    withSqliteColumn(options: SQLiteColumnOptions): SQLiteColumnAnnotation<A>;
  }
}

TypeRepBase.prototype.withSqliteColumn = function(options) {
  return new SQLiteColumnAnnotation(this as any, options);
};


const drivers = t.record({
  id: t.number.withSqliteColumn({ primary: true}),
})
