module.exports = (camelize, marker) => (attr, opt = {}) =>
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
          obj = val: v, mods: mods
        opt[oname][type] = obj
      else
        opt[oname][type] = v
  return opt
