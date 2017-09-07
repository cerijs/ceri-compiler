htmlparser = require "htmlparser2"
marker = "####"
camelize = (str) => str.replace /-(\w)/g, (_, c) => if c then c.toUpperCase() else ''
spliceStr = (str, index, count, add) =>
  if index < 0 
    index = str.length + index
    if index < 0
      index = 0
  str.slice(0, index) + (add || "") + str.slice(index + count)
templateArgs = []
templateArgs.toArg = (depth, nr) => 
  return String.fromCharCode(96+nr) + if depth then String.fromCharCode(96+depth) else ""

templateArgs.toArgs = (tmp) =>
  if (i = tmp.args)?
    arr = []
    while i
      arr.unshift templateArgs.toArg(tmp.depth,i--)
  return arr
parseAttr = require("./compile1_parseAttr")(camelize, spliceStr, marker, templateArgs)
parseDirective = require("./compile1_parseDirective")(camelize, marker)

module.exports = (template) =>
  result = "function(){return ["
  parseTemplateArgs = (args) =>
    if (arr = templateArgs.toArgs(args))?
      result = spliceStr result, args.position, 0, arr.join(',')
  templateArgs.push position: 9
  lastLevel = 0
  currentLevel = 0
  wasTemplate = false
  options = []
  addOptions = (bracket) =>
    if options.length > 0
      opt = options.pop()
      if opt
        result += "#{JSON.stringify(opt)},"
      else
        result += "null,"
      result += "[" if bracket
  parser = new htmlparser.Parser
    onopentag: (name, attr) =>
      return if parseDirective(name, attr, options)
      currentLevel++
      if currentLevel == lastLevel 
        sep =  "," 
      else 
        addOptions(name != "template")
        sep = ""
      if name == "slot"
        name = attr.name
        name ?= "default"
        result += "#{sep}\"#{name}\""
      else if name == "template"
        result += "function(){return ["
        templateArgs.push position: result.length-10, depth: templateArgs.length
      else
        options.push parseAttr(attr)
        result += "#{sep}this.el(\"#{name}\","
    ontext: (txt) =>
      if options.length > 0 and txt.trim()
        opt = options[options.length-1]
        opt ?= {}
        opt.text ?= {}
        if txt.indexOf("{{") > -1
          txt = txt
            .replace(/{{/g,"\"+(")
            .replace(/}}/g,")+\"")
          opt.text[":"] ?= "#{marker}function(){return \"#{txt}\";}#{marker}"
            .replace(/\+""/g,"")
            .replace(/""\+/g,"")
        else
          opt.text["#"] ?= txt
        options[options.length-1] = opt
    onclosetag: (name) =>
      return if parseDirective(name)
      addOptions(true)
      lastLevel = currentLevel
      currentLevel--
      if name == "template"
        result += "]})"
        wasTemplate = true
        parseTemplateArgs(templateArgs.pop())
      else 
        if wasTemplate
          wasTemplate = false
        else if name != "slot"
          result += "])"
  parser.write(template)
  parser.end()
  result+="]}"
  parseTemplateArgs(templateArgs.pop())
  # unescape marked function
  result = result.replace new RegExp("\"#{marker}(.*?)#{marker}\"","g"), (a,b) =>
    if (m = b.match(/return/g))? and m.length > 1 # remove default return if one is used in expression
      b = b.replace /function\(\)\{return /,"function(){"
    return b
      .replace /\\"/g,"\"" # unescape qoutes
      .replace /[^\\]@/g, (a) => return a.replace("@","this.") # replace unescaped @ by this.
      .replace /\\\\@/g, "@" # replace escaped @
  return result
