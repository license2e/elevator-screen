APP.ns 'lib'
APP.lib =
  api_update: (type, cbfunc)->
    cb = cbfunc or (type, value) ->
      true
    update_url = '{0}{1}'.format APP.settings.db.panel.url, APP.settings.db.api.updated
    $.ajax
      url: update_url
      method: 'GET'
      dataType: 'json'
    .done (data, textStatus, jqXHR)->
      try
        if data.hasOwnProperty(type) && null != data[type]
          type_lastcheck = APP.settings.db.lastcheck[type]
          if data[type] > type_lastcheck
            APP.settings.db.lastcheck[type] = data[type]
            cb type, true
          else
            cb type, false
        else
          cb type, false
        return true
      catch e
        APP.logger.error 'APP.lib.api_update: ' + e
      false
    .fail (jqXHR, textStatus, errorThrown)->
      cb type, false 
      false
    true
  api_setting: (setting, cbfunc)->
    cb = cbfunc or (setting, value) ->
      true
    settings_url = '{0}{1}'.format APP.settings.db.panel.url, APP.settings.db.api.settings
    $.ajax
      url: settings_url
      method: 'GET'
      dataType: 'json'
    .done (data, textStatus, jqXHR)->
      try
        if data.settings.hasOwnProperty(setting) && null != data.settings[setting]
          cb setting, data.settings[setting].value
        else
          cb setting, null
        return true
      catch e
        APP.logger.error 'APP.lib.api_setting: ' + e
      false
    .fail (jqXHR, textStatus, errorThrown)->
      cb setting, null
      false
    true