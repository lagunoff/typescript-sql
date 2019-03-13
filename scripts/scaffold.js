#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const print = x => console.log(JSON.stringify(x, null, 2));
require('ts-node/register/transpile-only');
const utils = require('./utils');

const split1 = (str, sep) => {
  const idx = str.indexOf(sep); if (idx === -1) return [str, ''];
  return [str.slice(0, idx), str.slice(idx + sep.length)]
};

const findBalancedIdx = (begin, end) => (str, beginIdx=0) => {
  let iter = beginIdx;
  const stack = [];
  while (1) {
    if (iter >= str.length) break;
    if (str[iter] === begin) stack.push(iter);
    if (str[iter] === end) stack.pop();    
    if (stack.length === 0) break;
    iter++;
  };
  return iter;
};

const parseBalanced = (begin, end) => (str, beginIdx=0) => {
  const idx = findBalancedIdx(begin, end)(str, beginIdx);
  return str.slice(beginIdx, idx + 1);
};

const parseExpr = str => {
  let iter = 0;
  const vbarIdxs = [];
  for(;;) {
    if (iter >= str.length) { break; }
    if (str[iter] === '|') {
      vbarIdxs.push(iter);
      iter++
      continue;
    }
    if (str[iter] === '{' || str[iter] === '[' || str[iter] === '<') {
      const idx = findBalancedIdx(str[iter], balanced[str[iter]])(str, iter);
      iter = idx;
      continue;
    }
    iter++
  }
  const alternatives = [];
  for (let i = 0; i < vbarIdxs.length + 1; i++) {
    const beginIdx = i - 1 === -1 ? 0 : vbarIdxs[i - 1] + 1;
    const endIdx = vbarIdxs[i];
    alternatives.push(parseTuple(str.slice(beginIdx, endIdx).trim()));
  }
  if (alternatives.length === 1) return alternatives[0];
  return utils.oneOf(...alternatives);
};

const balanced = { '{': '}', '[': ']', '<': '>' };

const parseTuple = str => {
  let iter = 0;
  const values = [];
  for(;;) {
    if (iter >= str.length) break;
    if (str[iter] === '{' || str[iter] === '[') {
      const substrP = parseBalanced(str[iter], balanced[str[iter]])(str, iter);
      substr = substrP.slice(1, substrP.length - 1);
      if (str[iter] === '[') {
        values.push(utils.optional(parseExpr(substr)));
      } else {
        values.push(parseExpr(substr));
      }
      iter += substrP.length;
      continue;
    }
    if (str[iter] === '<') {
      const name = parseBalanced(str[iter], balanced[str[iter]])(str, iter);
      values.push(utils.ref(prepareRuleName(name)));
      iter += name.length;
      continue;
    }
    if (/^\s$/.test(str[iter])) {
      //      if (values[values.length - 1] !== ' ') values.push(' ');
      iter++;
      continue;
    } else {
      const begin = iter;
      while (1) { if (/^\s$/.test(str[++iter] || ' ')) break; }
      const name = str.slice(begin, iter);
      if (name === '...') {
        values.push(utils.many1(values.pop()));
      } else {
        values.push(utils.of(name));
      }
      continue;      
    }
  }
  if (values.length === 1) return values[0];
  return utils.tuple(...values);
};

const esc = x => JSON.stringify(x);
const compose = (...fns) => x => fns.reduceRight((acc, fn) => fn(acc), x);
const prepareRuleName = str => {
  const output = str.replace(/<|>/g, '').replace(/[^\w\d]+/g, '_').replace(/^(\d)/, '_$1');
  return output;
};

const prepareExpr = str => {
  const exeptions = {'"["': '[', '"]"': ']', '|': false, '<': false, '>': false, '=': false, '"|"': '|', '<=': false, '<>': false, '||': false, '[': false, ']': false, '{': false  };
  const trimmed = str.trim();
  if (trimmed in exeptions) return utils.of(exeptions[trimmed] || trimmed);
  if (/^!!/.test(trimmed)) return utils.hole(trimmed);
  return null;
};

const parseRule = s => {
  const [name, rules] = split1(s, '::=').map(x => x.trim()); if (!rules) return null;
  const expr = prepareExpr(rules) || parseExpr(rules);
  return utils.rule(prepareRuleName(name), expr);
};

const process = compose(parseRule);
const shouldProcess = x => /^</.test(x);


const input = fs.readFileSync('/dev/stdin', 'utf-8');
const rules = {};
input.split('\n\n').forEach($1 => {
  if (!shouldProcess($1)) return null;
  const postProcess = compose(utils.addSpaces, utils.replaceOptionalMany1);
  const expr = utils.comment(parseRule($1), $1);
  utils.rewrite(expr).map(postProcess).forEach(expr => {
    const name = utils.getName(expr);
    if (name in rules) throw new Error(`name ${esc(name)} was already taken`);
    rules[name] = expr;
  });
});
const exprs = Object.keys(rules);

const gp01 = utils.makeGP(rules);
const [components, gp02] = utils.computeKosaraju(gp01);
const components_inv = utils.inverseGP(components);
const gp02_inv = utils.inverseGP(gp02);
const roots = Array.prototype.concat.apply([], [
  'delete_statement_searched', 'insert_statement' ,'rollback_statement' ,'search_condition', 'query_specification' , 'update_statement_searched', 'value_expression', 'table_definition',
  'identifier_body',
].map(k => Object.keys(components_inv[k])));

const root_components = utils.transitiveEdges(gp02_inv, roots);
// const sorted_components = utils.topologicalSort(components, gp02);
// const componentsWeights = sorted_components.reduce((acc, x, idx) => (acc[x] = idx, acc), {});
// const sorted_roots = root_components.sort((a, b) => componentsWeights[a] > componentsWeights[b] ? 1 : componentsWeights[a] < componentsWeights[b] ? -1 : 0);
// console.log(roots);
// console.log(JSON.stringify(utils.transitiveEdges(gp02inv, roots), null, 2));
// debugInfo(components, gp02, gp02inv);
// process.exit(0);
// console.log(JSON.stringify(gp01, null, 2))

// console.log(`import { rule, tuple, many, scanner, optional, many1, oneOf } from '../src/dsl';\n`);
root_components.forEach(component => {
  if (!(component in components)) return;
  Object.keys(components[component]).forEach(rule => {
    if (!(rule in rules)) return;
    //  console.log(utils.commentlines(utils.pprintExpr(rules[rule], false)));
    console.log(utils.pprintPEG(rules[rule], true));
    console.log();
  });
});

// const topologicalSort = dsl.getTransitiveRefs(rules, dg, ['bit_factor']);
// console.log(dependencies.map(x => dsl.pprintExpr(rules[x], true) + '\n// refs: ' + dsl.getRefs(rules[x]).join(', ')).join('\n\n'));


function debugInfo(components, gp, gpinv) {
  Object.keys(components).forEach(c => {
    // if (!gp[c]) throw new Error(`component ${esc(c)} doesn't exist in gp`);
    // if (!gpinv[c]) throw new Error(`component ${esc(c)} doesn't exist in gp`);
    const edges = gp[c] ? Object.keys(gp[c]) : [];
    const invedges = gpinv[c] ? Object.keys(gpinv[c]) : [];
    console.log(utils.getComment(rules[c]))
    console.log(`${c} -> ` + (invedges.length ? invedges.join(', ') : '<none>'));
    console.log(`${c} <- ` + (edges.length ? edges.join(', ') : '<none>'));
    console.log(`\n`);
  });
}
