#!/usr/bin/env node
var program = require('commander')
  , fs = require('fs')
  , path = require('path')
  , cwd = process.cwd()
program
  .version(JSON.parse(fs.readFileSync(path.join(__dirname, 'package.json'), 'utf8')).version)
  .usage('[options] <file ...>')
  .option('-o, --out [folder]', 'out')
  .option('-b, --bundle', 'make a bundle')
  .option('-w, --webpack', 'webpack config to use for bundle creation')
  .option('-v [version]', 'compiler version to use as default')
  .parse(process.argv);
if (!program.out)
  program.out = process.cwd()
require("./lib/index.js")(program)
