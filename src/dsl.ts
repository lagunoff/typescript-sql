export type InferA<E>
  = E extends string ? E 
  : E extends Expr<infer A> ? A
  : unknown;

export type MkTuple<T extends Exprs> = { [K in keyof T]: InferA<T[K]> };
export type Exprs = Array<string|Expr<any>>;


export function tuple<T extends Exprs>(...xs: T): Tuple<MkTuple<T>> {
  return new Tuple(xs.map(coerceString));
}


export type Expr<T> =
  | Pure<T>
  | Scanner<T>
  | Rule<T>
  | Tuple<T>
  | OneOf<T>
  | Quantifier<T>
  | RuleDimap<T>
;

export class ExprBase<T> {
  dimap<B>(proj: (x: T) => B, coproj: (x: B) => T): RuleDimap<B> {
    return new RuleDimap(this as any, proj, coproj);
  }
}
 
export class Tuple<T> extends ExprBase<T>{
  constructor(
    readonly _values: Expr<T>[],
  ) { super(); }
}

export class Scanner<T> extends ExprBase<T>{
  constructor(
    readonly _name: string,
    readonly _regexp: string|RegExp,
    readonly _ignore: boolean,
  ) { super(); }
}

export class Rule<T> extends ExprBase<T> {
  constructor(
    readonly _name: string,
    readonly _expr: Expr<T>,
  ) { super(); }
}

export class OneOf<T> extends ExprBase<T>  {
  constructor(
    readonly _alternatives?: Expr<any>[],
  ) { super(); }
}

export class Pure<T> extends ExprBase<T> {
  constructor(
    readonly _value: T,
  ) { super(); }
}

export class RuleDimap<T> extends ExprBase<T> {
  constructor(
    readonly _value: Expr<unknown>,
    readonly _proj?: (x: unknown) =>  T,
    readonly _comap?: (t: T) =>  unknown,
  ) { super(); }
}


export class Quantifier<T> extends ExprBase<T> {
  constructor(
    readonly _expr: Expr<unknown>,
    readonly _quantifier: 'many'|'many1'|'optional',
  ) { super(); }
}
export type QuantifierType = Quantifier<void>['_quantifier'];


export function rule<T>(name: string, expr: Expr<T>): Rule<T>;
export function rule<T extends Exprs>(name: string, alternatives: T): Rule<T[number]>;
export function rule<T>(name: string, exprOrAlternatives: any): Rule<T> {
  if (Array.isArray(exprOrAlternatives)) return new Rule(name, new OneOf(exprOrAlternatives.map(coerceString)));
  return new Rule(name, exprOrAlternatives);
}

export function oneOf<T extends Exprs>(...alternatives: T): OneOf<T[number]> {
  return new OneOf(alternatives.map(coerceString));
}

export function many<T>(expr: Expr<T>): Quantifier<T[]>;
export function many<T extends Exprs>(...expr: T): Quantifier<Array<MkTuple<T>>>;
export function many(...xs: any[]): Quantifier<any> {
  if (xs.length === 1) return new Quantifier(xs[0], 'many');
  return new Quantifier(new Tuple(xs), 'many');
}
export function many1<T>(expr: Expr<T>): Quantifier<T[]>;
export function many1<T extends Exprs>(...expr: T): Quantifier<Array<MkTuple<T>>>;
export function many1(...xs: any[]): Quantifier<any> {
  if (xs.length === 1) return new Quantifier(xs[0], 'many1');
  return new Quantifier(new Tuple(xs), 'many1');
}
export function optional<T>(expr: Expr<T>): Quantifier<T|null> {
  return new Quantifier(expr, 'optional');
}
export function scanner(name: string, regex: string|RegExp, ignore: boolean = false): Scanner<string> {
  return new Scanner(name, regex, ignore);
}


function coerceString<A>(x: string|Expr<A>): Expr<A|string> {
  return typeof(x) === 'string' ? new Pure(x) : x;
}
