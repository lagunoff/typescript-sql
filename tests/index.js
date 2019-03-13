const fs = require('fs');
const path = require('path');
const sql = require('../lib/fast');

function checkParserFails(file, text) {
  try {
    sql.parse(text)
  } catch (e) {
    if (e instanceof sql.SyntaxError) return true;
    throw e;
  }
  throw new Error('Parser was supposed to fail, but it didn\'t, in file ' + file);
}

const oks = ['./ok.01.sql'];
const fails = ['./fail.01.sql'];

oks.forEach(file => fs.readFileSync(path.join(__dirname, file), 'utf-8').split('-- --').forEach(s => sql.parse(s)));
fails.forEach(file => fs.readFileSync(path.join(__dirname, file), 'utf-8').split('-- --').filter(x => x.trim() !== '').forEach(s => checkParserFails(file, s)));
