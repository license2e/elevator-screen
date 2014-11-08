APP.ns 'models.forecast'
APP.models.forecast = APP.models.extend()
APP.models.forecast.init = () ->
  this.add_columns lastcheck: null, currently:{}, daily:{}
  this.type = 'forecast'
  this._keep = 2
  true