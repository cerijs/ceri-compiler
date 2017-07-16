htmlparser = require "htmlparser2"
marker = "####"
camelize = (str) => str.replace /-(\w)/g, (_, c) => if c then c.toUpperCase() else ''
parseAttr = require("./compile1_parseAttr")(camelize, marker)
parseDirective = require("./compile1_parseDirective")(camelize, marker)

module.exports = (template) =>
  result = "function(){return ["
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
      else 
        if wasTemplate
          wasTemplate = false
        else if name != "slot"
          result += "])"
  parser.write(template)
  parser.end()
  result+="]}"
  # unescape marked function
  result = result.replace new RegExp("\"#{marker}(.*?)#{marker}\"","g"), (a,b) =>
    if b.match(/return/g).length > 1 # remove default return if one is used in expression
      b = b.replace /function\(\)\{return /,"function(){"
    return b
      .replace /\\"/g,"\"" # unescape qoutes
      .replace /[^\\]@/g, (a) => return a.replace("@","this.") # replace unescaped @ by this.
      .replace /\\\\@/g, "@" # replace escaped @
  return result
