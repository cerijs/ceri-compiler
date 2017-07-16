isDirective = (name) => name.match /^[$:@~]/
module.exports = (camelize, marker) => (name, attr, options) =>
  type = name.slice(0,1)
  return false unless isDirective(type)
  if attr and options.length > 0
    opt = options[options.length-1] 
    name = name.slice(1)
    splitted = name.split("=")
    tmp = opt[splitted[0]] ?= {}
    val = if splitted[1] then camelize(splitted[1]) else []
    tmp = tmp[type] ?= val: val, mods: {}
    for k,v of attr
      splitted = camelize(k).split(".")
      if ~(splitted.indexOf "expr")
        tmp.mods[splitted[0]] = "#{marker}function(){return #{v};}#{marker}"
      else
        tmp.mods[splitted[0]] = v or true
  return true 