#first, checks if it isn't implemented yet
if !String.prototype.format
  String.prototype.format = () ->
    args = arguments
    replace = (match, number)-> 
      if typeof args[number] != 'undefined'
        args[number]
      else
        match
    this.replace /{(\d+)}/g, replace

setup(window)