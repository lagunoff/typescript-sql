## Work in progress, do not rely on this code

SQL-like language with JSON types for frontend application

## Installation
```
$ npm install typescript-sql
```

## Usage
```ts
import * as sql from 'typescript-sql';
const ast = sql.parse('select c01, c02, co3 from t01 join t02;');
// => [{"tag":"select","columns": [...],"from":[...],"where":null,"group_by":null,"having":null}]
```
