const fs = require('fs');
const path = require('path');
const sql = require('../sql');

fs.readFileSync(path.join(__dirname, './success.txt'), 'utf-8').split('\n---\n').forEach(s => console.log(sql.parse(s)));
