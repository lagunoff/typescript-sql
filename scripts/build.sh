#!/usr/bin/env sh

node_modules/.bin/pegjs --optimize speed -o lib/fast.js src/grammar.pegjs; pegjs --optimize size -o lib/compact.js src/grammar.pegjs
sed -n 's/^\/\/=\s\?\(.*\)$/\1/p' < src/grammar.pegjs > lib/index.d.ts
echo "module.exports = require('./fast');" > lib/index.js 
cp package.json lib/package.json
