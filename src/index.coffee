# out: ../lib/index.js

fs = require "fs"
path = require "path"
merge = require "webpack-merge"
acorn = require "acorn"

makeMessage = (type, node) ->
  if type == "cwarn"
    type = "console.warn"
  else
    type = "throw new Error"
  condition = node.arguments.shift().value
  text = node.arguments.map (n) ->
    if n.raw
      n.raw
    else
      n.name
  text = text.join(" + ")
  return "if(process.env.NODE_ENV!=='production' && #{condition}){#{type}(#{text})}"

compilehtml = (v, html) ->
  unless v?
    throw new Error("ceri-compiler failed. No version for template provided.")
  require("./compile#{v}")(html)

replaceExpression = (js, expr, cb) ->
  indexOffset = 0
  while (indexOffset = js.indexOf(expr+"(",indexOffset)) > -1
    node =  acorn.parseExpressionAt(js, indexOffset)
    if node.type == "SequenceExpression"
      node = node.expressions[0]
    try
      [js,move] = cb(js, node)
      indexOffset += move
    catch e
      console.error e
      indexOffset++
  return js

compilejs = (v, js) ->
  unless js?
    js = v
    v = null
  js = replaceExpression js, "template", (js, node) ->
    
    if node.arguments[1]?
      _v = node.arguments[0].value
      html = node.arguments[1].value
    else
      _v = v
      html = node.arguments[0].value
    result = compilehtml(_v, html)
    linebreaks = html.split("\n").length - 1
    result += "\n".repeat(linebreaks)
    js = js.substr(0,node.start) + result + js.substr(node.end)
    return [js, node.start + result.length + 1]
  ["cwarn","cerror"].forEach (type) ->
    js = replaceExpression js, type, (js, node) ->
      result = makeMessage(type,node)
      js = js.substr(0,node.start) + result + js.substr(node.end)
      return [js, node.start + result.length + 1]
  return js

compileFile = (program, input) ->
  input = path.resolve input
  output = path.resolve program.out, path.basename(input)
  if fs.existsSync(input)
    fs.readFile input, encoding:"utf8", (err,result) ->
      throw err if err
      result = compilejs program.v, result
      fs.writeFile output, result, (err) ->
        throw err if err
  return output

module.exports = (program) ->
  if path.extname(__filename) == ".coffee"
    require "coffee-script/register"
  if program.html?
    return compilehtml program.v, program.html
  else if program.js?
    return compilejs program.v, program.js
  else if program.out
    program.out = path.resolve(program.out)
    inputs = []
    for input in program.args
      parsed = input.split(":")
      if parsed.length == 1
        parsed.unshift path.basename(parsed[0],".js")
      inputs.push parsed
    outFiles = []
    for input in inputs
      outFiles.push [input[0],compileFile(program, input[1])]
    if program.bundle
      if program.webpack
        if path.extname(program.webpack) == ".coffee"
          require "coffee-script/register"
        webconf = require program.webpack
      if outFiles.length > 1
        es6Bundle = path.resolve program.out, "bundle.ES6.js"
        requireString = outFiles.map (outfile) ->
        "'#{outfile[0]}':require('#{outfile[1]}')"
        bundleString = "module.exports = {#{requireString.join(',')}};"
        fs.writeFileSync es6Bundle, bundleString
      entry = path.resolve program.out, "entry.js"
      requireString = outFiles.map (outfile) ->
          "window.ceri['#{outfile[0]}']=require('#{outfile[1]}')"
      requireString.unshift "if(!window.ceri)window.ceri={}"
      entryString = requireString.join('\n')
      fs.writeFileSync entry, entryString
      webconf ?= {}
      webconf = merge require("#{__dirname}/webpack.config"), {
        entry:
          index: [entry]
        output:
          path: program.out + "/"
        },
        webconf
      webpack = require "webpack"
      compiler = webpack(webconf)
      compiler.run (err, stats) ->
        fs.unlinkSync entry 
        throw err if err
        console.log stats.toString(colors: true)
        if stats.hasErrors() or stats.hasWarnings()
          console.log "please fix the warnings and errors with webpack first"
