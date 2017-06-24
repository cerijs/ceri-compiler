htmlparser = require "htmlparser2"
specialChars = /[^\w\s]/
camelize = (str) -> str.replace /-(\w)/g, (_, c) -> if c then c.toUpperCase() else ''
marker = "####"

module.exports = (template) ->
  result = "function(){return ["
  lastLevel = 0
  currentLevel = 0
  wasTemplate = false
  options = []
  addOptions = (bracket) ->
    if options.length > 0
      opt = options.pop()
      if opt
        result += "#{JSON.stringify(opt)},"
      else
        result += "null,"
      result += "[" if bracket
  parser = new htmlparser.Parser
    onopentag: (name, attr) ->
      parseAttr = (opt = {})->
        if Object.keys(attr).length > 0
          for k,v of attr
            if specialChars.test(k[0])
              type = k[0]
              oname = k.slice(1)
            else
              type = ""
              oname = k
            splitted = oname.split(".")
            [oname] = splitted.splice(0,1)
            opt[oname] ?= {}
            if splitted.length > 0
              mods = {}
              for mod in splitted
                mods[camelize(mod)] = true
              if Object.keys(mods).length == 1 and mods.expr
                obj = "#{marker}function(){return #{v};}#{marker}"
              else if mods.expr
                delete mods.expr
                obj = val: "#{marker}function(){return #{v};}#{marker}", mods: mods
              else
                obj = val: v, mods: mods
              opt[oname][type] = obj
            else
              opt[oname][type] = v
          return opt
        else
          return null
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
        options.push parseAttr()
        result += "#{sep}this.el(\"#{name}\","
    ontext: (txt) ->
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
    onclosetag: (name) ->
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
  result = result.replace new RegExp("\"#{marker}(.*?)#{marker}\"","g"), (a,b) ->
    if b.match(/return/g).length > 1 # remove default return if one is used in expression
      b = b.replace /function\(\)\{return /,"function(){"
    return b
      .replace /\\"/g,"\"" # unescape qoutes
      .replace /[^\\]@/g, (a) -> return a.replace("@","this.") # replace unescaped @ by this.
      .replace /\\\\@/g, "@" # replace escaped @
  return result
