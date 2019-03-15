#!/usr/bin/env sh

[ -d foo ] || mkdir foo;
node_modules/.bin/pegjs --optimize speed -o lib/fast.js src/grammar.pegjs; pegjs --optimize size -o lib/compact.js src/grammar.pegjs
sed -n 's/^\/\/=\s\?\(.*\)$/\1/p' < src/grammar.pegjs | sed 's/^type /export type /' > lib/index.d.ts
echo "module.exports = require('./fast');" > lib/index.js 
cp scripts/*.d.ts lib/
cp package.json lib/package.json
