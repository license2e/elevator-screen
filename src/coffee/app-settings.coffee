APP.ns 'settings'
APP.settings = 
  version: null
  gui: require 'nw.gui'
  win: null
  head: null
  body: null
  appdom: null
  root: null
  tpls: {}
  current: null
  $app: null
  $article: null
  $footer: null
  $inspect: null
  $inspectcontainer: null
  db_model: null
  db: {}
  model: null
  get_default_values: () ->
    default_values =
      settings_created: true
      forecast_displayed: false
      debug_enabled: false
      lastcheck:
        forecast: 0
        external_news: 0
        internal_news: 0
        internal_alerts: 0
        theme_updated: 0
      api:
        settings: '/api/settings'
        updated: '/api/updated'
        external_news: '/api/external-news'
        internal_news: '/api/internal-news'
        internal_alerts: '/api/internal-alerts'
        theme: '/theme/'
      panel:
        url: null
        token: null
        version: null
      position:
        latitude: null
        longitude: null
      theme:
        theme_dir: null
        theme_url: null
        theme_file: null
        app_theme_dir: null
        app_theme_dir_file: null
      app:
        forecast: null
    return default_values
  save_db_settings: () =>
    APP.settings.model.set 'values', APP.settings.db
    APP.settings.model.save()
    true
  get_db_settings: () =>
    AppSettings = Backbone.Model.extend  
      localStorage: new Backbone.LocalStorage "settings"
      id: "default"
    APP.settings.model = new AppSettings()
    APP.settings.model.fetch()
    APP.settings.db = APP.settings.model.get 'values'
    if undefined == APP.settings.db
      APP.settings.model.set 'values', APP.settings.get_default_values()
      APP.settings.model.save()
      APP.settings.db = APP.settings.model.get 'values'
    # APP.settings.db_model = APP.models.settings.find_or_create 'default', values: default_values
    # APP.settings.db = APP.settings.db_model.get 'values'
    true
  set_db_setting: (key, value) =>
    try
      # this.get_db_settings()
      APP.logger.debug 'Set the database key: ' + key + ' to: ' + value
      APP.settings.db[key] = value
      APP.settings.save_db_settings()
      return true
    catch e
      APP.logger.error 'APP.settings.set_db_setting: ' + e
    false  
    
