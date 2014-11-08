APP.ns 'events'
APP.events =
  welcome:
    'app-generic-func': (cbfunc) ->
      cb = cbfunc or () ->
        true
      cb()
    '#set-app-url':
      events:
        'submit.app-url': (e) ->
          e.preventDefault()
          app_url = $.trim $('#app-url').val()
          app_token = $.trim $('#app-token').val()
          if app_url.slice(-1) == '/'
            app_url = app_url.substring 0, (app_url.length - 1)
          settings_url = '{0}{1}'.format app_url, APP.settings.db.api.settings
          $.ajax
            url: settings_url
            method: 'GET'
            dataType: 'json'
          .done (data, textStatus, jqXHR)->
            if data.settings.app_token.value == app_token
              APP.settings.db.panel.url = app_url
              APP.settings.db.panel.token = data.settings.app_token.value
              APP.settings.db.panel.version = data.settings.app_version.value
              APP.settings.db.position.latitude = data.settings.forecast_lat.value
              APP.settings.db.position.longitude = data.settings.forecast_long.value
              APP.settings.db.app.forecast = data.settings.forecast_api.value
              APP.settings.db.theme.theme_dir = '{0}{1}'.format window.setup.localcore, APP.settings.db.api.theme.slice(1)
              APP.settings.db.theme.theme_url = '{0}{1}{2}.zip'.format APP.settings.db.panel.url, APP.settings.db.api.theme, APP.settings.db.panel.token
              APP.settings.db.theme.theme_file = '{0}{1}.zip'.format APP.settings.db.theme.theme_dir, APP.settings.db.panel.token
              APP.settings.db.theme.app_theme_dir = '{0}{1}'.format APP.settings.db.theme.theme_dir, APP.settings.db.panel.token
              APP.settings.db.theme.app_theme_dir_file = '{0}{1}/theme.css'.format APP.settings.db.theme.theme_dir, APP.settings.db.panel.token
              APP.settings.save_db_settings()
              APP.logger.error 'APP setup: settings saved'
              APP.ui.load_main_setup()
            else
              APP.logger.error 'Error in the data from: ' + settings_url
            true
          .fail (jqXHR, textStatus, errorThrown)->
            APP.logger.error textStatus + ': ' + errorThrown
            true
          false
    '#inspect':
      events:
        'click.inspect-code': (e) ->
          e.preventDefault()
          APP.ui.inspect()
          false
    '#clear-settings':
      events:
        'click.clear-settings': (e) ->
          e.preventDefault()
          APP.storage.clear()
          false
  main:
    'app-generic-func': (cbfunc) ->
      cb = cbfunc or () ->
        true
        
      APP.datetime.init()
      APP.forecast.init()
      APP.external_news.init()
      APP.internal_news.init()
      APP.internal_alerts.init()
      APP.debug.init()
      cb()
    'window':
      jwerty:
        'esc': (context, event, jwertyCodeIs) -> 
          APP.ui.min_screen()
          false
        'ctrl+w': (context, event, jwertyCodeIs) -> 
          APP.ui.quit()
          false
    '#min':
      events:
        'click.controls': (e) ->
          e.preventDefault()
          APP.ui.min_screen()
          false
    '#full':
      events:
        'click.controls': (e) ->
          e.preventDefault()
          APP.ui.full_screen()
          false
    '#quit':
      events:
        'click.controls': (e) ->
          e.preventDefault()
          APP.ui.quit()
          false
    # '#inspect':
    #   events:
    #     'click.inspect-code': (e) ->
    #       e.preventDefault()
    #       APP.ui.inspect()
    #       false
