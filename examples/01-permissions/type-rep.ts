import { Expr } from '../../src/types';


// TypeRep
export type TypeRep<A> =
  | ArrayRep<A>
  | Dict<A>
  | PartialRep<A>
  | RecordRep<A>
  | Primitive<A>
  | Literal<A>
  | OneOf<A>
  | ToTypeRep<A>
  | Unknown<A>
  | Any<A>
  | Tuple<A>
  | ClassRep<A>
  ;


// Base class for instance methods
export class TypeRepBase<A> {
  readonly _A: A;
}

export class ArrayRep<A> extends TypeRepBase<A> {
  constructor(
    readonly _value: TypeRep<any>,
  ) { super(); }
}

export class Tuple<A> extends TypeRepBase<A> {
  constructor(
    readonly _tuple: TypeRep<any>[],
  ) { super(); }
}

export class Dict<A> extends TypeRepBase<A> {
  constructor(
    readonly _value: TypeRep<any>,
  ) { super(); }
}

export class RecordRep<A> extends TypeRepBase<A> {
  constructor(
    readonly _record: Record<string, TypeRep<any>>,
  ) { super(); }
}

export class PartialRep<A> extends TypeRepBase<A> {
  constructor(
    readonly _record: RecordRep<any>,
  ) { super(); }
}

export class Primitive<A> extends TypeRepBase<A> {
  constructor(
    readonly _type: 'boolean'|'string'|'number',
  ) { super(); }
}

export class Literal<A> extends TypeRepBase<A> {
  constructor(
    readonly _value: A,
  ) { super(); }
}

export class OneOf<A> extends TypeRepBase<A> {
  constructor(
    readonly _alternatives: TypeRep<A>,
  ) { super(); }
}

export class ClassRep<A> extends TypeRepBase<A> {
  constructor(
    readonly _contructorArgs: TypeRep<A>[],
  ) { super(); }
}

export class Any<A> extends TypeRepBase<A> {
}

export class Unknown<A> extends TypeRepBase<A> {
}


export abstract class ToTypeRep<A> extends TypeRepBase<A> {
  abstract toTypeRep(): TypeRep<A>;
}


/**
 * Алиас для `x => new PureDecoder(Either.of(x))`
 */
export function of<A extends Expr>(a: A): Literal<A> {
  return new Literal(a);
}


// Примитивы
const anyRep = new Any<any>()
const unknownRep = new Unknown<unknown>()
const stringRep = new Primitive<string>('string');
const booleanRep = new Primitive<boolean>('boolean');
const numberRep = new Primitive<number>('number');
const nullRep = new Literal<null>(null);
const undefinedRep = new Literal<undefined>(undefined);


// Экспорт с переименованием
export { anyRep as any, stringRep as string, booleanRep as boolean, numberRep as number, nullRep as null, undefinedRep as undefined, unknownRep as unknown };


/**
 * Сопоставление с несколькими декодерами до первого успешного
 * сравнeния
 */
export function oneOf<XS extends TypeRep<any>[]>(...array: XS): OneOf<XS[number]['_A']>;
export function oneOf<XS extends TypeRep<any>[]>(array: XS): OneOf<XS[number]['_A']>;
export function oneOf(): OneOf<any> {
  const decoders = Array.isArray(arguments[0]) ? arguments[0] : Array.prototype.slice.call(arguments);
  return new OneOf(decoders);
}


export function array<A>(decoder: TypeRep<A>): TypeRep<A[]> {
  return new ArrayRep(decoder);
}

export function record<T>(fields: { [K in keyof T]: TypeRep<T[K]> }): RecordRep<T> {
  return new RecordRep(fields);
}

export function dict<A>(decoder: TypeRep<A>): TypeRep<Record<string, A>> {
  return new Dict(decoder);
}


/**
 * Кортежи разных размеров. Проверяемое значение необязательно должно
 * быть массивом
 * ```ts
 *   const pair = t.tuple(t.string, t.number);
 *   const pair_2 = t.record({ '0': t.string, '1': t.number }); // тоже самое
 * ```
 */
// @ts-ignore
export function tuple<A extends TypeRep<any>[]>(...reps: A): TypeRep<{ [K in keyof A]: A[K]['_A'] }>;
export function tuple(...args): TypeRep<any> {
  // @ts-ignore
  return ap(...args.map((decoder, idx) => at(idx, decoder)), (...xs) => xs);
}
