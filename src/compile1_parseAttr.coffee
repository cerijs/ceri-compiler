module.exports = (camelize, spliceStr, marker, templateArgs) => 
  matchTemplateArgs = (val) =>
    reg = /[^\\\$]?((\$+)(\d+))/g
    found = false
    while result = reg.exec(val)
      tmp = templateArgs[templateArgs.length-result[2].length]
      tmp.args = Math.max(tmp.args || 0, (arg = parseFloat(result[3])))
      arg = templateArgs.toArg(tmp.depth, arg)
      len = result[1].length
      i = result.index+(result[0].length-len)
      ###if i > 0
        arg = '"+' + arg 
        if val[0] != '"'
          val = '"' + val
          i++
      if i + len > val.length
        arg += '+"'
        if val[val.length-1] != '"'
          val += '"'###
      val = spliceStr val, i , len, arg
      found = true
    if found
      val = marker+val+marker
    return val
  return (attr, opt = {}) =>
    if Object.keys(attr).length > 0
      for k,v of attr
        if /[^\w\s]/.test(k[0])
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
            obj = val: matchTemplateArgs(v), mods: mods
          opt[oname][type] = obj
        else
          opt[oname][type] = matchTemplateArgs(v)
    return opt
