htmlparser = require "htmlparser2"
specialChars = /[^\w\s]/

module.exports = (template) ->
  result = "function(){return ["
  lastLevel = 0
  currentLevel = 0
  parser = new htmlparser.Parser
    onopentag: (name, attr) ->
      currentLevel++
      sep = if currentLevel == lastLevel then "," else ""
      if name == "slot"
        name = attr.name
        name ?= "default"
        result += "#{sep}\"#{name}\""
      else
        if Object.keys(attr).length > 0
          options = {}
          for k,v of attr
            if specialChars.test(k[0])
              type = k[0]
              oname = k.slice(1)
            else
              type = ""
              oname = k
            splitted = oname.split(".")
            [oname] = splitted.splice(0,1)
            options[oname] ?= {} 
            if splitted.length > 0
              options[oname][type] = val: v, mods: splitted
            else
              options[oname][type] = v
          options = JSON.stringify(options)
        else
          options = "null"
        result += "#{sep}this.el(\"#{name}\",#{options},["
    onclosetag: (name) ->
      lastLevel = currentLevel
      currentLevel--
      result += "])" unless name == "slot"
  parser.write(template)
  parser.end()
  result+="]}"
  return result
