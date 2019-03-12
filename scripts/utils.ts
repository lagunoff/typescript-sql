import { absurd } from "../src/types";

export type InferA<E>
  = E extends string ? E 
  : E extends Expr<infer A> ? A
  : unknown;

export type MkTuple<T extends Exprs> = { [K in keyof T]: InferA<T[K]> };
export type Exprs = Array<string|Expr<any>>;


export function tuple<T extends Exprs>(...xs: T): Tuple<MkTuple<T>> {
  return new Tuple(xs.map(coerceString));
}


export type Expr<T = any> =
  | Pure<T>
  | Scanner<T>
  | Tuple<T>
  | OneOf<T>
  | Hole<T>
  | Ref<T>
  | Annot<T>
;

export type Annotation =
  | { tag: 'Dimap', proj: Function, coproj: Function }
  | { tag: 'Name', name: string }
  | { tag: 'Comment', comment: string }
  | { tag: 'Optional' }
  | { tag: 'Many1' }
  | { tag: 'Many' }
;

export class ExprBase<T> {
  dimap<B>(proj: (x: T) => B, coproj: (x: B) => T): Expr<B> {
    return new Annot(this as any, { tag: 'Dimap', proj, coproj });
  }

}
 
export class Tuple<T> extends ExprBase<T>{
  constructor(
    public _values: Expr<T>[],
  ) { super(); }
}

export class Scanner<T> extends ExprBase<T>{
  constructor(
    public _name: string,
    public _regexp: string|RegExp,
    public _ignore: boolean,
  ) { super(); }
}

export class OneOf<T> extends ExprBase<T>  {
  constructor(
    public _alternatives: Expr<any>[],
  ) { super(); }
}

export class Pure<T> extends ExprBase<T> {
  constructor(
    public _value: T,
  ) { super(); }
}

export class Annot<T> extends ExprBase<T> {
  constructor(
    public _expr: Expr<unknown>,
    public _annotation: Annotation,
  ) { super(); }
}

export class Hole<T> extends ExprBase<T> {
  constructor(
    public _message: string,
  ) { super(); }
}

export class Ref<T> extends ExprBase<T> {
  constructor(
    public _name: string,
  ) { super(); }
}


export function rule<T>(name: string, expr: Expr<T>|string): Expr<T>;
export function rule<T extends Exprs>(name: string, alternatives: T): Expr<T[number]>;
export function rule<T>(name: string, exprOrAlternatives: any): Expr<T> {
  if (Array.isArray(exprOrAlternatives)) return new Annot(new OneOf(exprOrAlternatives.map(coerceString)), { tag: 'Name', name });
  return new Annot(coerceString(exprOrAlternatives), { tag: 'Name', name });
}

export function oneOf<T extends Exprs>(...alternatives: T): OneOf<T[number]> {
  return new OneOf(alternatives.map(coerceString));
}

export function many<T>(expr: Expr<T>): Expr<T[]>;
export function many<T extends Exprs>(...expr: T): Expr<Array<MkTuple<T>>>;
export function many(...xs: any[]): Expr<any> {
  if (xs.length === 1) return new Annot(new Annot(xs[0], { tag: 'Many1' }), { tag: 'Optional' });
  return new Annot(new Annot(new Tuple(xs), { tag: 'Many1' }), { tag: 'Optional' });
}

export function many1<T>(expr: Expr<T>): Expr<T[]>;
export function many1<T extends Exprs>(...expr: T): Expr<Array<MkTuple<T>>>;
export function many1(...xs: any[]): Expr<any> {
  if (xs.length === 1) return new Annot(xs[0], { tag: 'Many1' });
  return new Annot(new Tuple(xs), { tag: 'Many1' });
}

export function optional<T>(expr: Expr<T>): Expr<T|null>;
export function optional<T extends Exprs>(...expr: T): Expr<T|null>;
export function optional(...xs: any[]): Expr<any> {
  if (xs.length === 1) return new Annot(xs[0], { tag: 'Optional' });
  return new Annot(new Tuple(xs), { tag: 'Optional' });
}

export function scanner(name: string, regex: string|RegExp, ignore: boolean = false): Scanner<string> {
  return new Scanner(name, regex, ignore);
}

export function hole(name: string): Hole<any> {
  return new Hole(name);
}

export function ref(name: string): Ref<any> {
  return new Ref(name);
}


function coerceString<A>(x: string|Expr<A>): Expr<A|string> {
  return typeof(x) === 'string' ? new Pure(x) : x;
}


export function pprintExpr<A>(expr: Expr<A>, topLevel = false, lazyrefs = false, anytype = false): string {
  if (expr instanceof Pure) return JSON.stringify(expr._value);
  if (expr instanceof Scanner) return `scanner(` + esc(expr._name) + ', ' + (expr._regexp instanceof RegExp) ? expr._regexp.toString() : esc(expr._regexp) + ')';
  if (expr instanceof Tuple) return `tuple(` + expr._values.map(x => pprintExpr(x, false, lazyrefs)).join(', ') + ')';
  if (expr instanceof OneOf) return `oneOf(` + expr._alternatives.map(x => pprintExpr(x, false, lazyrefs)).join(', ') + ')';
  if (expr instanceof Hole) return `function(){ throw new Error(${esc(expr._message)}); }()`;
  if (expr instanceof Ref) return lazyrefs ? 'ref(' + esc(expr._name) + ')' : expr._name;
  if (expr instanceof Annot) {
    if (expr._annotation.tag === 'Comment') {
      if (topLevel) return commentlines(expr._annotation.comment) + '\n' + pprintExpr(expr._expr, topLevel, lazyrefs, anytype);
      return pprintExpr(expr._expr, topLevel, lazyrefs, anytype);
    }
    if (expr._annotation.tag === 'Name') {
      if (topLevel && anytype) return `const ${expr._annotation.name}: any = rule(` + esc(expr._annotation.name) + ', ' + pprintExpr(expr._expr, false, lazyrefs, anytype) + ')';
      if (topLevel) return `const ${expr._annotation.name} = rule(` + esc(expr._annotation.name) + ', ' + pprintExpr(expr._expr, false, lazyrefs, anytype) + ')';
      return 'rule(' + esc(expr._annotation.name) + ', ' + pprintExpr(expr._expr, topLevel, lazyrefs, anytype) + ')';
    }
    if (expr._annotation.tag === 'Optional') {
      return 'optional(' + pprintExpr(expr._expr, topLevel, lazyrefs, anytype) + ')';
    }
    if (expr._annotation.tag === 'Many1') {
      return 'many1(' + pprintExpr(expr._expr, topLevel, lazyrefs, anytype) + ')';
    }
    if (expr._annotation.tag === 'Many') {
      return 'many(' + pprintExpr(expr._expr, topLevel, lazyrefs, anytype) + ')';
    }
    if (expr._annotation.tag === 'Dimap') {
      throw new Error(`pprintExpr is not defined for 'Dimap'`);
    }
    return absurd(expr._annotation);
  }
  return absurd(expr);
}


export function pprintPEG<A>(expr: Expr<A>, topLevel = false): string {
  const withParens = expr => str => needParens(expr, false) ? '(' + str + ')' : str;
  
  if (expr instanceof Pure) return esc(expr._value);
  if (expr instanceof Scanner) throw new Error(`pprintPEG is not defined for 'Scanner'`);
  if (expr instanceof Tuple) return expr._values.map(x => withParens(x)(pprintPEG(x))).join(' ')
  if (expr instanceof OneOf) {
    if (topLevel) return expr._alternatives.map(x => pprintPEG(x)).join('\n  / ');
    return expr._alternatives.map(x => pprintPEG(x)).join(' / ');
  }
  if (expr instanceof Hole) return '"<hole: ' + expr._message + '>"'
  if (expr instanceof Ref) return expr._name;
  if (expr instanceof Annot) {
    if (expr._annotation.tag === 'Comment') {
      return pprintPEG(expr._expr, topLevel);
    }
    if (expr._annotation.tag === 'Name') {
      if (topLevel) return expr._annotation.name + '\n  = ' + pprintPEG(expr._expr, topLevel);
      return pprintPEG(expr._expr, topLevel);
    }
    if (expr._annotation.tag === 'Optional') {
      return withParens(expr._expr)(pprintPEG(expr._expr)) + '?';
    }
    if (expr._annotation.tag === 'Many1') {
      return withParens(expr._expr)(pprintPEG(expr._expr)) + '+';
    }
    if (expr._annotation.tag === 'Many') {
      return withParens(expr._expr)(pprintPEG(expr._expr)) + '*';
    }
    if (expr._annotation.tag === 'Dimap') {
      return pprintPEG(expr._expr, topLevel);
    }
    return absurd(expr._annotation);
  }
  return absurd(expr);

  function needParens<A>(expr: Expr<A>, topLevel: boolean) {
    if (expr instanceof Tuple) return !topLevel && expr._values.length !== 1;
    if (expr instanceof OneOf) return !topLevel && expr._alternatives.length !== 1;
    if (expr instanceof Annot) {
      if (expr._annotation.tag === 'Optional' || expr._annotation.tag === 'Many' || expr._annotation.tag === 'Many1') return false;
      return needParens(expr._expr, topLevel);
    }
    return false;
  }
}
function esc(x: any) {
  return JSON.stringify(x);
}
export const commentlines = x => '// ' + x.split('\n').join('\n// ');


export function addSpaces<A>(expr: Expr<A>): Expr<A> {
  if (expr instanceof Tuple) {
    expr._values.forEach((x, idx, arr) => arr[idx] = addSpaces(x));
    for (let i=1; i < expr._values.length; i++) {
      const a = expr._values[i - 1], b = expr._values[i];
      const tripleOrTuple = addBetween(a, b);
      if (tripleOrTuple.length === 3) expr._values.splice(i, 0, tripleOrTuple[1]);
      i++;
    }
    return expr;
  }
  if (expr instanceof OneOf) {
    expr._alternatives.forEach((x, idx, arr) => arr[idx] = addSpaces(x));
    return expr;
  }
  if (expr instanceof Annot) {
    expr._expr = addSpaces(expr._expr);
    return expr;
  }
  return expr;

  function addBetween(a: Expr, b: Expr): Expr[] {
    if (isGroup(a) && isGroup(b)) return [a, addLeading(b)];
    if (!isGroup(a) && !isGroup(b)) return [a, ref('_'), b];
    if (isGroup(a) && !isGroup(b)) return [addEnd(a), b];
    if (!isGroup(a) && isGroup(b)) return [a, addLeading(b)];
    return [a, b];
  }

  function addEnd(a: Expr) {
    if (a instanceof Annot) return (a._expr = addEnd(a._expr), a);
    if (a instanceof Tuple) return (a._values.push(ref('_')), a);
    return tuple(a, ref('_'));
  }
  
  function addLeading(a: Expr) {
    if (a instanceof Annot) return (a._expr = addLeading(a._expr), a);
    if (a instanceof Tuple) return (a._values.unshift(ref('_')), a);
    return tuple(ref('_'), a);
  }

  function isGroup(a: Expr): boolean {
    if (a instanceof Annot && (a._annotation.tag === 'Optional' || a._annotation.tag === 'Many' || a._annotation.tag === 'Many1')) return true;
    return false;
  }
}


export function of<T>(x: T): Pure<T> {
  return new Pure(x);
}

export function comment<T>(expr: Expr<T>, comment: string): Expr<T> {
  return new Annot(expr, { tag: 'Comment', comment });
}

export function getName(expr: Expr<any>): string|null {
  if (expr instanceof Annot && expr._annotation.tag === 'Name') return expr._annotation.name;
  if (expr instanceof Annot) return getName(expr._expr);
  return null;
}

export function getComment(expr: Expr<any>): string|null {
  if (expr instanceof Annot && expr._annotation.tag === 'Comment') return expr._annotation.comment;
  if (expr instanceof Annot) return getComment(expr._expr);
  return null;
}

export function getRefs(expr: Expr<any>): string[] {
  const output: string[] = [];
  go(expr);
  return output;
  
  function go(expr: Expr<any>) {
    if (expr instanceof Ref) { output.push(expr._name); return; }
    if (expr instanceof Tuple) { expr._values.forEach(go); return; }
    if (expr instanceof OneOf) { expr._alternatives.forEach(go); return; }
    if (expr instanceof Annot) { return go(expr._expr); }
  }
}


// Precedence graph
export type SSet = Record<string, true>;
export type StronglyConnected = Record<string, SSet>;
export type GP = Record<string, SSet>;
export type GPI = GP;


// Build precedence graph
export function makeGP(rules: Record<string, Expr>): GP {
  const gp: GP = {};
  Object.keys(rules).forEach(rule => getRefs(rules[rule]).forEach(ref => {
    gp[ref] = gp[ref] || {};
    gp[ref][rule] = true;
  }));
  return gp;
}

// Compute Strongly Connected Components of `Gp`
// https://en.wikipedia.org/wiki/Kosaraju%27s_algorithm
export function computeKosaraju(gp: GP): [StronglyConnected, GP] {
  const discovered: SSet = {};
  const stack: string[] = [];
  const components: StronglyConnected = {};
  const graph: GP = {};

  for (const vertex in gp) {
    visit(vertex);
  }

  for (let i = stack.length - 1; i >= 0; i--) {
    assign(stack[i], stack[i]);
  }

  for (const root in components) {
    for (const vertex in components[root]) {
      // Search out-neighbours
      for (const neighbour in gp[vertex]) {
        if (neighbour in components[root]) continue;
        // Found out-neighbour from another component
        for (const neighbourRoot in components) {
          if (neighbour in components[neighbourRoot]) {
            graph[root] = graph[root] || {};
            graph[root][neighbourRoot] = true;
          }
        }
      }
    }
  }

  return [components, graph];

  function visit(vertex: string) {
    if (vertex in discovered) return;
    discovered[vertex] = true;
    for (const neighbour in gp[vertex]) {
      visit(neighbour);
    }
    stack.push(vertex);
  }

  function assign(vertex: string, root: string) {
    if (alreadyAssigned(vertex)) return;
    components[root] = components[root] || {};
    components[root][vertex] = true;

    // Traverse in-neighbours
    for (const neighbour in gp) {
      if (vertex in gp[neighbour]) assign(neighbour, root);
    }
  }

  function alreadyAssigned(vertex: string): boolean {
    for (const root in components) {
      if (vertex in components[root]) return true;
    }
    return false;
  }
}

// Topological sort by Kahn's algorithm
// https://en.wikipedia.org/wiki/Topological_sorting
export function topologicalSort(components: StronglyConnected, precedence: GP): string[];
export function topologicalSort(components: string[], precedence: GP): string[];
export function topologicalSort(components_: StronglyConnected|string[], precedence: GP): string[] {
  const components = Array.isArray(components_) ? components_ : Object.keys(components_);
  const list: string[] = [];
  const queue: string[] = [];
  const inDegrees: Record<string, number> = {};
  let visited = 0;

  // Compute in-degrees
  for (const root in precedence) {
    for (const vertex in precedence[root]) {
      inDegrees[vertex] = inDegrees[vertex] || 0;
      inDegrees[vertex] += 1;
    }
  }
  
  // Fill `queue`
  for (const root of components) {
    const inDegree = inDegrees[root] || 0;
    if (inDegree === 0) queue.push(root);
  }

  while(queue.length) {
    const n = queue.shift()!;
    visited++;
    list.push(n);
    for (const m in precedence[n] || {}) {
      inDegrees[m] = inDegrees[m] || 0;
      inDegrees[m]--;
      if (inDegrees[m] <= 0) queue.push(m);
    }
  }

  if (components.length !== visited) {
    throw new Error('Precedence graph has at least one cycle');
  }
  return list;
}


export function inverseGP(gp: GP): GPI {
  const inverted: GPI = {};
  Object.keys(gp).forEach(k => {
    Object.keys(gp[k]).forEach(ch => {
      inverted[ch] = inverted[ch] || {};
      inverted[ch][k] = true;
    });
  });
  return inverted;
}

export function transitiveEdges(gp: GP, edges: string[]): string[] {
  const output: SSet = {};
  edges.forEach(go);
  return Object.keys(output);
  
  function go(edge: string) {
    output[edge] = true;
    Object.keys(gp[edge] || {}).forEach(go);
  }
}


// rule+? -> rule*
export function replaceOptionalMany1(expr: Expr): Expr {
  return go(expr);
  
  function go(expr: Expr): Expr {
    if (expr instanceof Tuple) { expr._values.forEach((x, idx, xs) => xs[idx] = go(x)); return expr; }
    if (expr instanceof OneOf) { expr._alternatives.forEach((x, idx, xs) => xs[idx] = go(x)); return expr; }
    if (expr instanceof Annot) {
      if (expr._annotation.tag === 'Optional'
          && (expr._expr instanceof Annot)
          && expr._expr._annotation.tag === 'Many1'
         )
        return new Annot(go(expr._expr._expr), { tag: 'Many' });
      expr._expr = go(expr._expr);
      return expr;
    }
    return expr;
  }  
}


export function rewrite<A>(expr: Expr<A>): Expr<A>[] {
  if (expr instanceof Annot && expr._annotation.tag === 'Name') {
    const { _annotation: { name } } = expr;
    
    if (['space', 'identifier_start', 'nonquote_character', 'newline', 'nondoublequote_character'].indexOf(name) !== -1) {
      return [];
    }
  }
  if (expr instanceof Annot) {
    return rewrite(expr._expr).map((e, idx) => idx === 0 ? (expr._expr = e, expr) : e) as any;
  }
  // if (expr instanceof Annot) return (expr._expr = rewrite(expr._expr), [expr]);
  // if (expr instanceof Tuple) { expr._values.forEach((x, idx, xs) => xs[idx] = rewrite(x)); return [expr; }
  // if (expr instanceof OneOf) { expr._alternatives.forEach((x, idx, xs) => xs[idx] = rewrite(x)); return expr; }
  return [expr];
}


export function removeSingleRef(expr: Expr): Expr {
  return go(expr);
  
  function go(expr: Expr): Expr {
    if (expr instanceof Annot) {
      if (expr._annotation.tag === 'Name' && expr._expr instanceof Ref)
        return expr._expr
      expr._expr = go(expr._expr);
      return expr;
    }
    return expr;
  }  
}
