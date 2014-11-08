setup = (window) ->
  start = (new Date()).getTime()
  fs = require "fs"
  crypto = require "crypto"
  mkdirp = require 'mkdirp'
  head = window.document.querySelector "head"
  body = window.document.querySelector "body"
  appdom = window.document.querySelector "#app"
  appcore = "./app/"
  appload = ""
  appversion = null
  localhome = ""
  localcore = ""
  localversion = null
  root = ""
  version = null
  current = false
  localFile = false

  uncaughtException = (e) ->
    console.log "### EXCEPTION: " + e
    console.log e.stack
    true
  process.on "uncaughtException", uncaughtException
  window.onerror = uncaughtException

  addJavaScript = (path, localFile, cbfunc) ->
    cb = cbfunc or () ->
      true
    () ->
      jscontents = fs.readFileSync path, encoding:'utf8'
      if path.indexOf('enc') != -1
        decipher = crypto.createDecipher wE4jX8pF6FKFjceWzqScKQvgxcrdrJqanzx6rgJ7.algorithm, wE4jX8pF6FKFjceWzqScKQvgxcrdrJqanzx6rgJ7.password
        out = decipher.update jscontents, 'base64', 'utf8'
        out = out + decipher.final 'utf8'
      else
        out = jscontents
      script = document.createElement "script"
      script.type = "text/javascript"
      script.innerHTML = out
      body.appendChild script
      cb()
  addCSSFile = (local_head, path, localFile, cbfunc) ->
    cb = cbfunc or () ->
      true
    (cbfunc2) ->
      cb2 = cbfunc2 or () ->
        true
      path = "file://" + path  if localFile
      #csscontents = fs.readFileSync path, encoding:'utf8'
      css = document.createElement "link"
      css.rel = "stylesheet"
      css.type = "text/css"
      css.href = path
      #css.innerHTML = csscontents
      local_head.appendChild css
      cb(cb2)
  ext = (path) ->
    i = path.lastIndexOf(".")
    ext = path.substring(i + 1)
    ext
  hasExt = (path, exts) ->
    e = ext(path)
    for i of exts
      return true  if e is exts[i]
    false
  try
    if process.env.ETTHOME
      localhome = process.env.ETTHOME
    else if process.platform is "win32"
      localhome = process.env.USERPROFILE
    else
      localhome = process.env.HOME
    localcore = localhome + "/.elevatorscreen/"
    
    if !fs.existsSync localcore
      mkdirp localcore, (err)->
        if err 
          console.log 'Could not create directory: ' + localcore
        true

    appversion = require(appcore + "js/app-version.json")
    if current
      root = localcore
      localFile = true
    else
      root = appcore
      localFile = false

    appload = require root + "js/app-lazyload.json"

    if appload
      scriptLoad = () ->
        APP.settings.head = head
        APP.settings.body = body
        APP.settings.appdom = appdom
        APP.settings.$app = jQuery(app)
        APP.settings.root = root
        APP.settings.version = appversion.version
        APP.ui.init()
        true
      cssLoad = (cbfunc) -> 
        cb = cbfunc or () ->
          true
        cb()
      if appload.js && appload.js != [] && appload.js.length > 0
        appload.js.reverse()
        for j in appload.js
          scriptLoad = addJavaScript j, localFile, scriptLoad     
      if appload.css && appload.css != [] && appload.css.length > 0
        appload.css.reverse()
        for c in appload.css
          cssLoad = addCSSFile head, c, localFile, cssLoad
      if typeof scriptLoad == "function"
        cssLoad () ->
          setTimeout scriptLoad, 500
          true
      else
        cssLoad()

    window.setup =
      version: appversion.setup
      startTime: start
      current: current
      localhome: localhome
      localcore: localcore
      root: root
      uncaughtException: uncaughtException
      addCSSFile: addCSSFile

    #console.log "WINDOW.SETUP root:" + window.setup.root
    true
  catch e
    uncaughtException e
wE4jX8pF6FKFjceWzqScKQvgxcrdrJqanzx6rgJ7 =
  "algorithm":"aes-256-cbc"
  "password":"√∞¨≠¢§¶•ELEVATOR£≤˜˜≥£®´ß∂ƒ∆©˚¡•¡¬SCR33N"
