const NODE_DATA = '__SDOM_CUSTOM_DATA__';

export type DFunc<A, B> = {
  (a: A): B;
  derive(da: Patch<A>, b: B): Patch<B>;
}

export type DLens<A, B> = {
  get: DFunc<A, B>;
  set(x: Patch<B>): Patch<A>;
}

export type InferPatch1<T>
  = T extends Array<infer A> ? ArrayPatch<A[]>
  : T extends object ? KeyPatch<T>|Replace<T>
  : Replace<T>;

export type InferPatch<T> = InferPatch1<T>|Batch<T>|T;
export type NonTrivialPatch<T> =
  | KeyPatch<T>
  | ArraySplice<T>
  | ArraySwap<T>
  | KeyPatch<T>
  | Batch<T>
  ;

export type Patch<T>
  // @ts-ignore
  = ArrayPatch<T>
  | KeyPatch<T>
  | Batch<T>
  | Replace<T>
  ;

export type ArrayPatch<A extends any[]> =
  | ArraySplice<A>
  | ArraySwap<A>
  | KeyPatch<A, number>
  | Replace<A>
  ;

export class ArraySplice<A> {
  constructor(
    readonly _index: number,
    readonly _removes: number,
    readonly _values: A,
  ) {}
}

export class ArraySwap<A> {
  constructor(
    readonly _firstIdx: number,
    readonly _secondIdx: number,
  ) {}
}

export class Batch<T> {
  constructor(
    readonly _patches: Patch<T>[],
  ) {}
}

export class Replace<T> {
  constructor(
    readonly _prev: T,
    readonly _next: T,
  ) {}
}

export class KeyPatch<A, K extends keyof A = keyof A> {
  constructor(
    readonly _key: K,
    readonly _patch: Patch<A[K]>,
  ) {}
}

export function applyPatch<T>(value: T, patch: Patch<T>, destructively = false): T {
  if (patch instanceof KeyPatch) {
    if (destructively) {
      // @ts-ignore
      value[patch._key] = applyPatch(value[patch._key], patch._patch, destructively);
      return value;
    } else {
      // @ts-ignore
      return { ...value, [patch._key]: applyPatch(value[patch._key], patch._patch, destructively) };
    }
  }

  if (patch instanceof ArraySplice) {
    if (destructively) {
      // @ts-ignore
      value.splice(patch._index, patch._removes, ...patch._values);
      return value;
    } else {
      // @ts-ignore
      const nextValue = value.slice(0); nextValue.splice(patch._index, patch._removes, ...patch._values);
      return nextValue;
    }
  }

  if (patch instanceof ArraySwap) {
    if (destructively) {
      // @ts-ignore
      const tmp = value[patch._firstIdx]; value[firstIdx] = value[secondIdx]; value[secondIdx] = tmp;
      return value;
    } else {
      // @ts-ignore
      const nextValue = value.slice(0); nextValue[firstIdx] = value[secondIdx]; nextValue[secondIdx] = value[firstIdx];
      return nextValue;
    }    
  }

  if (patch instanceof Batch) {
    return patch._patches.reduce<T>((acc, p) => applyPatch(acc, p, destructively), value);
  }

  if (patch instanceof Replace) {
    return patch._next;
  }
  
  return absurd(patch);
}


export type SDOM<Model, Action=any> =
  | string|number|((m: Model) => string)
  | SDOMElement<Model>
  | SDOMText<Model>
  | SDOMTextThunk<Model>
  | SDOMDiscriminate<Model>
  | SDOMArray<Model>
  | SDOMPick<Model>
  | SDOMCustom<Model>
  | HasSDOM<Model>
  | SDOMMap<Model, Action>
  ;


export type SDOMAttribute<Model, Action=void> =
  | string|number|boolean|((e: Event, model: Model) => Action)
  | AttrPure<string|number|boolean>
  | AttrThunk<Model>
  | AttrEvent<Model>
  ;

export class SDOMElement<Model> {
  constructor(
    readonly _name: string,
    readonly _attributes: Record<string, SDOMAttribute<Model>>,
    readonly _childs: SDOM<Model>[],
  ) {}
}

export class SDOMText<Model> {
  constructor(
    readonly _value: string,
  ) {}
}

export class SDOMTextThunk<Model> {
  constructor(
    readonly _thunk: (model: Model) => string,
  ) {}
}

export class SDOMDiscriminate<Model> {
  constructor(
    readonly _discriminator: keyof Model,
    readonly _tags: Record<string, SDOM<Model>>,
  ) {}
}

export class SDOMArray<Model> {
  constructor(
    readonly _discriminator: string,
    readonly _item: SDOM<any>,
  ) {}
}

export class SDOMPick<Model, K extends (keyof Model)[] = (keyof Model)[]> {
  constructor(
    readonly _keys: K,
    readonly _sdom: SDOM<Pick<Model, K[number]>>,
  ) {}
}

export class SDOMMap<Model, Action> {
  constructor(
    readonly _sdom: SDOM<Model, any>,
    readonly _proj: (x: any) => Action,
  ) {}
}

export class SDOMCustom<Model > {
  constructor(
    readonly _create: (model: Model) => HTMLElement|Text,
    readonly _actuate: (el: HTMLElement|Text, model: Model, patch: Patch<Model>) => HTMLElement|Text,
  ) {}
}

export abstract class HasSDOM<Model > {
  abstract toSDOM(): SDOM<Model>;
}

export class AttrPure<T> {
  constructor(
    readonly _value: T,
    readonly _isProperty: boolean,
  ) {}  
}


export class AttrThunk<Model> {
  constructor(
    readonly _thunk: (model: Model) => string,
    readonly _isPropery: boolean = false,
  ) {}  
}


export class AttrEvent<Model> {
  constructor(
    readonly _listener: (e: Event, model: Model) => void,
  ) {}  
}


export type Many<T> = T|T[];

export function h<Model>(name: string, childs?: Many<SDOM<Model>>);
export function h<Model>(name: string, attrs: Record<string, SDOMAttribute<Model>>, childs?: Many<SDOM<Model>>);
export function h<Model>() {
  if (arguments.length === 1) {
    const name = arguments[0], attrs = {}, childs = []; 
    return new SDOMElement<Model>(name, attrs, Array.isArray(childs) ? childs : [childs])
  }
  if (arguments.length === 2) {
    const name = arguments[0], attrs = {}, childs = arguments[1]; 
    return new SDOMElement<Model>(name, attrs, Array.isArray(childs) ? childs : [childs])
  }
  const name = arguments[0], attrs = arguments[1], childs = arguments[2]; 
  return new SDOMElement<Model>(name, attrs, Array.isArray(childs) ? childs : [childs])
}

export namespace h {
  export type BoundH = {
      <Model>(childs: Many<SDOM<Model>>): SDOMElement<Model>;
      <Model>(attrs: Record<string, SDOMAttribute<Model>>, childs: Many<SDOM<Model>>): SDOMElement<Model>;
  };
  
  export const div = h.bind(void 0, 'div') as BoundH;
  export const span = h.bind(void 0, 'span') as BoundH;
  export const button = h.bind(void 0, 'button') as BoundH;
  export const p = h.bind(void 0, 'p') as BoundH;
  export const h1 = h.bind(void 0, 'h1') as BoundH;
  export const h2 = h.bind(void 0, 'h2') as BoundH;
  export const h3 = h.bind(void 0, 'h3') as BoundH;
  export const input = <Model>(attrs: Record<string, SDOMAttribute<Model>>) => h('input', attrs, []);
  export const img = <Model>(attrs: Record<string, SDOMAttribute<Model>>) => h('img', attrs, []);
  export const label = h.bind(void 0, 'label') as BoundH;
  export const li = h.bind(void 0, 'li') as BoundH;
}

export namespace th {
  export type BoundH = {
      <Model>(template: TemplateStringsArray, ...args): SDOMElement<Model>;
  };
  
  export const div = h.bind(void 0, 'div') as BoundH;
  export const span = h.bind(void 0, 'span') as BoundH;
  export const button = h.bind(void 0, 'button') as BoundH;
  export const p = h.bind(void 0, 'p') as BoundH;
  export const h1 = h.bind(void 0, 'h1') as BoundH;
  export const h2 = h.bind(void 0, 'h2') as BoundH;
  export const h3 = h.bind(void 0, 'h3') as BoundH;
  export const input = <Model>(attrs: Record<string, SDOMAttribute<Model>>) => h('input', attrs, []);
  export const img = <Model>(attrs: Record<string, SDOMAttribute<Model>>) => h('img', attrs, []);
  export const label = h.bind(void 0, 'label') as BoundH;
  export const li = h.bind(void 0, 'li') as BoundH;
}


export function text(value: string) {
  return new SDOMText<{}>(value);
}

export function thunk<Model>(th: (model: Model) => string) {
  return new SDOMTextThunk<Model>(th);
}

export function pick<Model, K extends (keyof Model)[]>(keys: K, sdom: SDOM<Pick<Model, K[number]>>) {
  return new SDOMPick<Model, K>(keys, sdom);
}


export function discriminate<Model>(discriminator: keyof Model) {
  return <T extends Record<string, SDOM<Model>>>(tags: T) => new SDOMDiscriminate<Model>(discriminator, tags);
}

// @ts-ignore
type TK<M, K> = M[K][number];


export function array<Model, K extends keyof Model>(discriminator: K, pick: Array<keyof Model>, item: SDOM<{ item: TK<Model, K>, model: Model }>);
export function array<Model, K extends keyof Model>(discriminator: K, item: SDOM<{ item: TK<Model, K>, model: Model }>);
export function array<Model, K extends keyof Model>() {
  if (arguments.length === 2) {
    // @ts-ignore
    const [discriminator, item] = arguments;
    return new SDOMPick<Model, K[]>([discriminator], new SDOMArray<Model>(discriminator, item));
  }
  // @ts-ignore
  const [discriminator, pick, item] = arguments;
  return new SDOMPick<Model, K[]>(pick, new SDOMArray<Model>(discriminator, item));
}

export namespace attrs {
  export function lam<Model>(th: (model: Model) => string): AttrThunk<Model> {
    return new AttrThunk<Model>(th);
  }
}

export namespace props {
  export function of<T>(value: T): AttrPure<T> {
    return new AttrPure<T>(value, true);
  }
  export function lam<Model>(th: (model: Model) => string): AttrThunk<Model> {
    return new AttrThunk<Model>(th, true);
  }
}


export function create<Model>(sdom: SDOM<Model>, model: Model): HTMLElement|Text {
  if (sdom instanceof SDOMElement) {
    const el = document.createElement(sdom._name);
    Object.keys(sdom._attributes).forEach(k => applyAttribute(k, sdom._attributes[k], el, model));
    sdom._childs.forEach(ch => el.appendChild(create(ch, model)));
    return el;
  }
  
  if (sdom instanceof SDOMText) {
    const el = document.createTextNode(sdom._value);
    return el;
  }
  
  if (sdom instanceof SDOMTextThunk) {
    const el = document.createTextNode(sdom._thunk(model));
    return el;
  }
  
  if (typeof (sdom) === 'function') {
    const el = document.createTextNode(sdom(model));
    return el;
  }
  
  if (sdom instanceof SDOMDiscriminate) {
    const ch = sdom._tags[model[sdom._discriminator] as any];
    const el = create(ch, model);
    // @ts-ignore
    el.dataset.tag = model[sdom._discriminator];
    return el;
  }
  
  if (sdom instanceof SDOMArray) {
    const array = model[sdom._discriminator] as any[];
    const el = document.createElement('div');
    array.forEach((item, idx) => {
      const chModel = { item, model };
      const ch = create(sdom._item, chModel);
      ch[NODE_DATA] = { model: chModel };
      el.appendChild(ch);
    });
    return el;
  }
  
  if (sdom instanceof SDOMPick) {
    const el = create(sdom._sdom, model);
    return el;
  }
  
  if (sdom instanceof SDOMMap) {
    const el = create(sdom._sdom, model);
    el[NODE_DATA] = { proj: sdom._proj, model };
    return el;
  }
  
  if (sdom instanceof SDOMCustom) {
    return sdom._create(model);
  }

  if (sdom instanceof HasSDOM) {
    return create(sdom.toSDOM(), model);
  }

  ensure<string|number>(sdom);
  const el = document.createTextNode(sdom + '');
  return el;
}


export function actuate<Model>(el: HTMLElement|Text, sdom: SDOM<Model>, model: Model, patch: Patch<Model>): HTMLElement|Text {
  if (patch instanceof Batch) {
    return patch._patches.reduce((acc, p) => actuate(acc, sdom, model, p as any), el);
  }
  
  if (sdom instanceof SDOMElement) {
    if (!(el instanceof HTMLElement)) throw new Error('actuate: got invalid DOM node');
    Object.keys(sdom._attributes).forEach(k => applyAttribute(k, sdom._attributes[k], el, model, patch));
    sdom._childs.forEach((s, idx) => {
      const ch = el.childNodes[idx] as any;
      const nextCh = actuate(ch, s, model, patch);
      if (ch !== nextCh) el.replaceChild(nextCh, ch);
    });
    return el;
  }
  
  if (sdom instanceof SDOMTextThunk) {
    if (!(el instanceof Text)) throw new Error('actuate: got invalid DOM node');
    const next = sdom._thunk(model);
    if (el.nodeValue !== next) el.nodeValue = next;
    return el;
  }
  
  if (typeof (sdom) === 'function') {
    if (!(el instanceof Text)) throw new Error('actuate: got invalid DOM node');
    const next = sdom(model);
    if (el.nodeValue !== next) el.nodeValue = next;
    return el;
  }

  if (sdom instanceof SDOMText) {
    return el;
  }

  if (sdom instanceof SDOMDiscriminate) {
    // @ts-ignore
    if (el.dataset.tag !== model[sdom._discriminator]) {
      return create(sdom, model);
    }
    return actuate(el, sdom._tags[model[sdom._discriminator] as any], model, patch);
  }

  if (sdom instanceof SDOMArray) {
    const array = model[sdom._discriminator] as any[];
    // if (!(patch instanceof ObjectPatch)) throw new Error('actuate2: invalid patch');
    if (!(patch instanceof KeyPatch) || patch._key !== sdom._discriminator) {
      array.forEach((item, idx) => {
        const ch = el.childNodes[idx] as HTMLElement;
        const chPatch = new KeyPatch<typeof chModel>('model', patch);
        const chModel = ch[NODE_DATA].model
        if (isReplace(patch)) applyPatch(chModel, chPatch, true); 
        // @ts-ignore
        const nextCh = actuate(ch, sdom._item, chModel, chPatch);
        if (ch !== nextCh) {
          nextCh[NODE_DATA] = { model: chModel };
          el.replaceChild(nextCh, ch);
        }
      })
      return el;
    };
    const p = patch._patch as ArrayPatch<any[]>;

    if (p instanceof ArraySplice) {
      for (let i = p._removes - 1; i >= 0; i--) {
        const ch = el.childNodes[p._index + i];
        el.removeChild(ch);
      }
      p._values.forEach((item, idx) => {
        const chModel = { item, model };
        const ch = create(sdom._item, chModel);
        ch[NODE_DATA] = { model: chModel };
        el.insertBefore(ch, el.childNodes[p._index + idx] || null);
      });
      return el;
    }
    
    if (p instanceof KeyPatch) {
      const ch = el.childNodes[p._key] as HTMLElement;
      const chPatch = new KeyPatch<typeof chModel>('item', patch);
      const chModel = ch[NODE_DATA].model;
      if (isReplace(patch)) applyPatch(chModel, chPatch, true);
      const nextCh = actuate(ch, sdom._item, chModel, p._patch);
      if (ch !== nextCh) el.replaceChild(nextCh, ch);
      return el;
    }

    if (p instanceof ArraySwap) {
      const ch1 = el.childNodes[p._firstIdx];
      const ch2 = el.childNodes[p._secondIdx];
      el.removeChild(ch2);
      el.insertBefore(ch2, ch1);
      el.removeChild(ch1);
      el.insertBefore(ch1, el.childNodes[p._secondIdx] || null);
      return el;
    }

    if (p instanceof Replace) {
      return create(sdom, model);
    }

    return absurd(p);
  }

  if (sdom instanceof SDOMPick) {
    if (patch instanceof KeyPatch) {
      if (sdom._keys.indexOf(patch._key as keyof Model) === -1) return el;
    }
    return actuate(el, sdom._sdom, model, patch);
  }

  if (sdom instanceof SDOMMap) {
    const nextEl = actuate(el, sdom._sdom, model, patch);
    if (nextEl !== el) {
      nextEl[NODE_DATA] = { proj: sdom._proj, model };
    } else if (isReplace(patch)) {
      nextEl[NODE_DATA].model = applyPatch(nextEl[NODE_DATA].model, patch, true);
    }

    return nextEl;
  }

  if (sdom instanceof SDOMCustom) {
    return sdom._actuate(el, model, patch);
  }
  
  if (sdom instanceof HasSDOM) {
    return create(sdom.toSDOM(), model);
  }

  ensure<string|number>(sdom);
  return el;
}


function isReplace(patch: Patch<any>): boolean {
  if (patch instanceof Replace) return true;
  if (patch instanceof Batch) return patch._patches.reduce((acc, p) => acc || isReplace(p), false);
  return false;
}


function applyAttribute<Model>(name: string, sdomAttr: SDOMAttribute<Model>, el: HTMLElement, model: Model, patch?: Patch<Model>) {
  if (sdomAttr instanceof AttrThunk) {
    if (sdomAttr._isPropery) {
      const next = sdomAttr._thunk(model);
      if (el[name] !== next) el[name] = next;
    } else {
      const next = sdomAttr._thunk(model);
      if (el.getAttribute(name) !== next) el.setAttribute(name, next);
    }
    return;
  }

  if (patch) return;
  
  if (sdomAttr instanceof AttrPure) {
    if (sdomAttr._isProperty) {
      el[name] = sdomAttr._value;
    } else {
      // @ts-ignore
      el.setAttribute(name, sdomAttr._value);
    }
    return;
  }

  if (sdomAttr instanceof AttrEvent) {
    el.addEventListener(name, createEventListener(sdomAttr._listener));
    return;
  }

  if (typeof(sdomAttr) === 'function') {
    el.addEventListener(name, createEventListener(sdomAttr));
    return;
  }

  ensure<string|number|boolean>(sdomAttr);
  if (name === 'value') el[name] = sdomAttr;
  if (typeof(sdomAttr) !== 'string') debugger;
  el.setAttribute(name, sdomAttr as any);
  return;
}


function createEventListener<Model, Action>(cb: (e: Event, model: Model) => Action): EventListener {
  return e => {
    let iter = e.target as HTMLElement|null;
    let action = void 0 as Action|void;
    let actionInitialized = false;
    
    for (; iter; iter = iter.parentElement) {
      const nodeData = iter[NODE_DATA];
      if (!nodeData) continue;
      if (!actionInitialized && ('model' in nodeData)) {
        action = cb(e, nodeData.model);
        actionInitialized = true;
        if (action === void 0) return;
      }

      if (actionInitialized && ('proj' in nodeData)) {
        action = nodeData.proj(action);
      }
    }
  };
}


/** Helper for totality checking */
export function absurd(x: never): any {
  throw new Error('absurd: unreachable code');
}


export function ensure<T>(value: T): T {
  return value;
}

