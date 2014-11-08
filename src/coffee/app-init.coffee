APP = 
  ns: (namespaces) ->
    names = namespaces.split(".")
    len = undefined
    ns = APP
    i = undefined
    names.splice 0, 1  if names[0].toUpperCase() is "APP"
    len = names.length
    i = 0
    while i < len
      not ns[names[i]] and (ns[names[i]] = {})
      ns = ns[names[i]]
      i++