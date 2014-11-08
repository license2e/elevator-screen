APP.ns 'ui'
APP.ui =
  _interval_external: null
  _interval_internal: null
  clear_external: (cbfunc) ->
    cb = cbfunc or () ->
      true
    if null != this._interval_external
      clearInterval this._interval_external 
    cb()
  set_interval_external: (interval) ->
    this.clear_external()
    this._interval_external = interval
    true
  clear_internal: (cbfunc) ->
    cb = cbfunc or () ->
      true
    if null != this._interval_internal
      clearInterval this._interval_internal 
    cb()
  set_interval_internal: (interval) ->
    this.clear_internal()
    this._interval_internal = interval
    true
  win: (url) ->
    if APP.settings.win == null
      APP.settings.win = APP.settings.gui.Window.get()
    APP.settings.win
  inspect: () ->
    win = this.win()
    win.showDevTools()
    true
  show: (cbfunc) ->
    win = this.win()
    cb = cbfunc or ->
      true
    win.show()
    cb()
  full_screen: (cbfunc) ->
    win = this.win()
    cb = cbfunc or ->
      true
    win.enterKioskMode()
    cb()
  min_screen: (cbfunc) ->
    win = this.win()
    cb = cbfunc or ->
      true
    win.leaveKioskMode()
    cb()
  quit: (cbfunc) ->
    win = this.win()
    cb = cbfunc or ->
      true
    APP.settings.gui.App.quit()
    cb()
  footer: (tpl, cbfunc) ->
    cb = cbfunc or ->
      true
    cb()
  switch: (tpl, cbfunc) ->
    cb = cbfunc or ->
      true
    if APP.settings.current != tpl
      # process footer
      this.footer tpl
      $tplshow = $ '.tplshow'
      if $tplshow.length > 0
        $tplshow.removeClass 'tplshow'
      APP.settings.tpls[tpl].addClass 'tplshow'
      APP.settings.current = tpl
    cb()
  load: (tpl, evts, cbfunc) ->
    cb = cbfunc or ->
      true
    # lazyload the tpl
    if !APP.settings.tpls[tpl]
      # get the template from the json
      tplobj = require APP.settings.root + "tpl/" + tpl + ".json"
      # create a $ object
      $rndtpl = $ tplobj.tpl
      # add the class rendered
      $rndtpl.addClass 'rendered'
      # add to the settings templates array
      APP.settings.tpls[tpl] = $rndtpl
      # add the tpl to the app
      $rndtpl.appendTo APP.settings.$article
      # bind the events
      this.bind evts
    # show the template
    this.switch tpl
    # callback
    cb()
  bind: (evts, cbfunc)->
    cb = cbfunc or ->
      true
    # bind the events
    if evts != undefined
      for id, ev of evts
        if id == 'app-generic-func'
          if 'function' == typeof ev
            ev()
        else
          if ev.events
            $items = $(id)
            if ev.events_not
              $items = $items.not(ev.events_not)
            $items.on(ev.events)
          if ev.jwerty and undefined != jwerty
            for keys, func of ev.jwerty
              if 'window' == id
                id = window
              jwerty.key keys, func, id
          if ev.context and ev.context != [] and undefined != APP.menu
            APP.menu.init id, ev.context
    cb()
  app_set: (cbfunc)->
    cb = cbfunc or ->
      true
    APP.lib.api_setting 'app_token', (type, value)->
      if APP.settings.db.panel.url != null and APP.settings.db.panel.token != null and APP.settings.db.panel.token == value
        cb true
      else
        cb false
  extract_file: (force) ->
    APP.logger.debug 'Attempting to load the main screen'
    fs = require 'fs'
    path = require 'path'
    unzip_path = path.join APP.settings.db.theme.theme_dir, APP.settings.db.panel.token
    APP.logger.debug 'Unzip path: ' + unzip_path
    # extract the zip file
    if force or (fs.existsSync(APP.settings.db.theme.theme_file) and !fs.existsSync(APP.settings.db.theme.app_theme_dir))
      unzip = require 'unzip'
      theme_file_stream = fs.createReadStream APP.settings.db.theme.theme_file 
      theme_file_stream.pipe( unzip.Extract path:unzip_path )
      theme_file_stream.on 'error', (err)->
        APP.logger.error 'Error while unzipping the file. ' + err
      theme_file_stream.on 'close', ()->
        APP.logger.debug 'File unzipped, should load the new one?'
        APP.ui.load_main()
    else
      APP.logger.debug 'No need to extract file..'
      APP.ui.load_main()
    APP.logger.debug 'Should have loaded the main'
    true
  load_main: ()->
    load_main_window = ()->
      # fade out the welcome section and load the main view
      $('#welcome-section').fadeOut 'slow', ()->
        APP.ui.load 'main', APP.events.main, ()->
          APP.ui.show()
          true
        true
      true
    fs = require 'fs'
    # apply css file
    if fs.existsSync APP.settings.db.theme.app_theme_dir_file
      fs.readFile APP.settings.db.theme.app_theme_dir_file, 'utf8', (err,data)->
        if err
          APP.logger.error err
          return false
        if data.match '$body_id'
          APP.logger.debug 'Theme: Replacing $body_id with token.'
          result = data.replace /\$body_id/g, APP.settings.db.panel.token
          fs.writeFile APP.settings.db.theme.app_theme_dir_file, result, 'utf8', (err)->
            if err
              APP.logger.error err
              return false
            true
        else
          APP.logger.debug 'Theme: No $body_id was found to replace.'
        true
      theme_css_file = APP.settings.db.theme.app_theme_dir_file + '?' + (new Date()).getTime()
      load_theme_css = window.setup.addCSSFile APP.settings.head, theme_css_file, true, (cb)->
        cb()
        true
      load_theme_css(load_main_window)
    else
      load_main_window()
  load_main_setup: ()->
    try
      self = this
      $(APP.settings.body).attr 'id', 'body-'+APP.settings.db.panel.token

      APP.lib.api_setting 'enable_debug', (type, value)->
        try 
          if null == value or false == value
            APP.settings.db.debug_enabled = false
            $('#debug').hide()
          else
            APP.settings.db.debug_enabled = true
            APP.logger.debug 'Debug enabled!'
            $('#debug').show()
          APP.settings.save_db_settings()
          true
        catch e
          APP.logger.error 'APP.ui.load_main_setup::{APP.lib.api_setting \'enable_debug\'}: ' + e
        false

      APP.lib.api_update 'theme_updated', (type, update_bool)->
        fs = require 'fs'
        mkdirp = require 'mkdirp'
        if update_bool == true
          http = require 'http'
          if !fs.existsSync APP.settings.db.theme.theme_dir
            mkdirp APP.settings.db.theme.theme_dir, (err)->
              if err 
                APP.logger.error 'Could not create directory: ' + APP.settings.db.theme.theme_dir
              else
                APP.logger.debug 'Created dir: ' + APP.settings.db.theme.theme_dir
              true
          # download the zip to the home folder
          saved_file = fs.createWriteStream APP.settings.db.theme.theme_file
          http.get APP.settings.db.theme.theme_url, (res)->
            if res.statusCode == 200
              res.pipe saved_file
              APP.logger.debug 'Saved file to: ' + saved_file.path
              APP.ui.extract_file true
            else
              APP.logger.debug 'Status code: ' + res.statusCode + ' returned'
            true
          .on 'error', (e)->
            APP.logger.error e.message
            false
        else
          APP.ui.extract_file false
        true
      false
    catch e
      APP.logger.log 'APP.ui.load_main_setup: ' + e
  set_height: ()->
    win = this.win()    
    $(APP.settings.body).css 'height', win.height+'px'
  enable_aside: ()->
    $('#aside')
    .on
      'mouseover.app-side': (e)->
        $(this).addClass('shown')
      'mouseout.app-aside': (e)->
        #$(this).removeClass('shown')
    .find('#aside-close')
    .on
      'click.app-aside': (e)->
        e.preventDefault()
        $('#aside').removeClass('shown')
        return false

    true
  enable_external_interval: ()->
    # 1 min interval
    interval_external = setInterval APP.ui.retrieve_external, (1 * 60 * 1000)
    APP.ui.set_interval_external interval_external
  enable_internal_interval: ()->
    # 1 min interval
    interval_internal = setInterval APP.ui.retrieve_internal, (1 * 60 * 1000)
    APP.ui.set_interval_internal interval_internal
    true
  retrieve_all: ()->
    APP.ui.retrieve_external()
    APP.ui.retrieve_internal()
    true
  retrieve_external: ()->
    APP.logger.debug 'Checking for external news update..'
    APP.external_news.retrieve()
    true
  retrieve_internal: ()->
    APP.logger.debug 'Checking for internal news update..'
    APP.internal_news.retrieve()
    APP.internal_alerts.retrieve()
    true
  enable_resize: ()->
    win = this.win()
    win.window.onresize = (e)->
      APP.ui.set_height()
      APP.ui.retrieve_all()
      true
    true
  init: ()->
    $('#version span').html " {0}".format APP.settings.version
    self = this
    # setup the items
    APP.settings.$article = APP.settings.$app.find '#article'
    APP.settings.get_db_settings()
    # load the welcome screen
    this.load 'welcome', APP.events.welcome, () =>
      self.show()
      self.set_height()
      #@inspect()
      #return true
      # check the app settings
      self.app_set (check_successful)->
        if check_successful
          self.load_main_setup()
        else
          $('#app-loading').fadeOut 'slow', ()->
            $('#app-info-set').fadeIn 'fast'
            true
        self.enable_aside()
        self.enable_resize()
        self.enable_external_interval()
        self.enable_internal_interval()
        true
      true
    true
