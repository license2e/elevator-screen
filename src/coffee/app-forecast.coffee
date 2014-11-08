APP.ns 'forecast'
APP.forecast =
  _forecast: null
  _interval: null
  _apicheck: 90000
  collection: null
  collection_history: 3
  reset_forecast_lastcheck: ()->
    APP.settings.db.lastcheck.forecast = APP.settings.db.lastcheck.forecast - APP.forecast.get_api_check_interval()
  get_api_check_interval: () ->
    this._apicheck
  get_current_dt: () ->
    new Date()
  last_check: () ->
    APP.settings.db.lastcheck.forecast
  next_check: () ->
    this.last_check() + this.get_api_check_interval()
  compare_last_check: () ->
    this.get_current_dt() > this.next_check()
  clear: (cbfunc) ->
    cb = cbfunc or () ->
      true
    if null != this._interval
      clearTimeout this._interval  
    cb()
  set_interval: () ->
    interval = setTimeout APP.forecast.get_current_forecast, 2000
    this.clear()
    this._interval = interval
    true
  get_skycons_type: (icon) ->
    if icon == "rain" then Skycons.RAIN else if icon == "snow" then Skycons.SNOW else if icon == "sleet" then Skycons.SLEET else if icon == "hail" then Skycons.SLEET else if icon == "wind" then Skycons.WIND else if icon == "fog" then Skycons.FOG else if icon == "cloudy" then Skycons.CLOUDY else if icon == "partly-cloudy-day" then Skycons.PARTLY_CLOUDY_DAY else if icon == "partly-cloudy-night" then Skycons.PARTLY_CLOUDY_NIGHT else if icon == "clear-day" then Skycons.CLEAR_DAY else if icon == "clear-night" then Skycons.CLEAR_NIGHT else Skycons.CLOUDY
  get_forecast_api: () ->
    if null == this._forecast
      Forecast = require 'forecast.io'
      this._forecast = new Forecast APIKey:APP.settings.db.app.forecast
    this._forecast
  get_current_forecast: (cbfunc) ->
    cb = cbfunc or () ->
      true
    if APP.forecast.compare_last_check()
      forecast = APP.forecast.get_forecast_api()
      forecast.get APP.settings.db.position.latitude, APP.settings.db.position.longitude, exclude:'minutely,hourly,flags,alerts', (err, res, data) ->
        if err
          APP.logger.error err
        else
          # store the new forecast
          dt = new Date()
          timestamp = dt.getTime()
          # APP.settings.set_db_setting
          APP.settings.db.lastcheck.forecast = timestamp
          db_storage = lastcheck:timestamp, currently:data.currently, daily:data.daily
          # db_forecast = APP.models.forecast.create db_storage
          db_forecast = APP.forecast.collection.create db_storage
          APP.forecast.cleanup_collection()
          APP.logger.debug 'Saved Forecast: {0}'.format db_forecast.id
          APP.forecast.process_forecast db_forecast, cb
        APP.forecast.set_interval()
    else if !APP.settings.db.forecast_displayed
      last_forecast = APP.forecast.collection.last()
      if last_forecast
        APP.logger.debug 'Last Forecast: {0}'.format last_forecast.id
        APP.forecast.process_forecast last_forecast, cb
      else
        APP.forecast.reset_forecast_lastcheck()        
      APP.forecast.set_interval()
    else
      APP.forecast.set_interval()
      cb()
    true
  process_forecast: (db_forecast, cbfunc) ->
    cb = cbfunc or () ->
      true
    $today_low = $ '#temp-low .temp-num'
    $today_num = $ '#temp-num'
    $today_high = $ '#temp-high .temp-num'
    currently = db_forecast.get 'currently'
    daily = db_forecast.get 'daily'
    idx = 0
    daily_today = daily.data[idx]
    skycons = new Skycons "color":"white"
    skycons_color = $('#date').css('color')
    weekly_skycons = new Skycons "color":skycons_color
    skycons.add "temp-skycon", this.get_skycons_type currently.icon
    skycons.play()
    $today_num.html parseInt currently.temperature
    $today_low.html parseInt daily_today.temperatureMin
    $today_high.html parseInt daily_today.temperatureMax
    for d in [1..6]
      idx++
      daily_data = daily.data[idx]
      $weekday = $ '#weekday-' + d
      $weekday_low = $weekday.find '.temp-low .temp-num'
      $weekday_high = $weekday.find '.temp-high .temp-num'
      $weekday_dow = $weekday.find '.temp-dow'
      weekday_dt = new Date(daily_data.time*1000)
      $weekday_low.html parseInt daily_data.temperatureMin
      $weekday_high.html parseInt daily_data.temperatureMax
      $weekday_dow.html APP.datetime.get_day_of_week weekday_dt.getDay(), true
      weekly_skycons.add 'weekday-skycon-' + d, this.get_skycons_type daily_data.icon
    weekly_skycons.play()
    if !APP.settings.db.forecast_displayed
      APP.settings.set_db_setting 'forecast_displayed', true
    cb()
    true
  cleanup_collection: () ->
    if APP.forecast.collection_history > 1 and APP.forecast.collection.length > APP.forecast.collection_history
      for idx in [0...(APP.forecast.collection.length - APP.forecast.collection_history)]
        if APP.forecast.collection.models.hasOwnProperty idx
          APP.logger.debug "Destroying {0}".format APP.forecast.collection.models[idx].id
          APP.forecast.collection.models[idx].destroy()
    true
  setup_collection: () ->
    ForecastCollection = Backbone.Collection.extend
      localStorage: new Backbone.LocalStorage "forecast"
    APP.forecast.collection = new ForecastCollection()
    APP.forecast.collection.fetch()
    # clean up the unneeded forecast models
    APP.forecast.cleanup_collection()
    true
  init: (cbfunc) ->
    cb = cbfunc or () ->
      true
    APP.forecast.setup_collection()
    # APP.forecast.collection.on 'add', APP.forecast.forecast_added
    APP.settings.set_db_setting 'forecast_displayed', false
    this.get_current_forecast()
    cb()
