htmlparser = require "htmlparser2"
specialChars = /[^\w\s]/

module.exports = (template) ->
  result = "function(){return ["
  lastLevel = 0
  currentLevel = 0
  options = []
  addOptions = ->
    if options.length > 0
      opt = options.pop()
      if opt
        result += "#{JSON.stringify(opt)},["
      else
        result += "null,["
  parser = new htmlparser.Parser
    onopentag: (name, attr) ->
      currentLevel++
      if currentLevel == lastLevel 
        sep =  "," 
      else 
        addOptions() 
        sep = ""
      if name == "slot"
        name = attr.name
        name ?= "default"
        result += "#{sep}\"#{name}\""
      else
        if Object.keys(attr).length > 0
          opt = {}
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
                mods[mod] = true
              opt[oname][type] = val: v, mods: mods
            else
              opt[oname][type] = v
        else
          opt = null
        options.push opt
        result += "#{sep}this.el(\"#{name}\","
    ontext: (txt) ->
      if options.length > 0 and txt.trim()
        opt = options[options.length-1]
        opt ?= {}
        opt.text ?= {}
        opt.text["#"] ?= txt
        options[options.length-1] = opt
    onclosetag: (name) ->
      addOptions()
      lastLevel = currentLevel
      currentLevel--
      result += "])" unless name == "slot"
  parser.write(template)
  parser.end()
  result+="]}"
  return result
