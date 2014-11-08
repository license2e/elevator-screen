APP.ns 'models'
APP.models = 
  init: () ->
    true
  extend: () ->
    $.extend true, {}, APP.models.base
      
APP.ns 'models.base'
APP.models.base =
  _real_key: (key) ->
    real_key = null
    if undefined != key and null != key
      real_key = key
    else if this._work.hasOwnProperty 'key' and null != this._work['key']
      real_key = this._work['key']
    else
      real_key = APP.storage.orm.generate_key()
    # check for type
    if real_key.indexOf(this.type) == -1
        real_key = this.type + '_' + real_key
    real_key
  init: () ->
    true
  get: (col) ->
    this._work[col] or null
  set: (data) ->
    if undefined == data
      throw new APP.models.exceptions.data_undefined data
    this._dirty = true
    this._work = $.extend true, this._work, data
    this.save()
  find_or_create: (key, dt) ->
    this.init()
    if 'object' == typeof key
      dt = key
      if dt.hasOwnProperty 'key'
        key = dt['key']
      else
        key = dt['key'] = APP.storage.orm.generate_key()
    found = this.find key
    if null == found
      if undefined != dt and !dt.hasOwnProperty 'key'
        dt['key'] = key
      return this.create dt
    this
  find: (key) ->
    this.init()
    real_key = this._real_key key
    data = APP.storage.find real_key
    if null != data
      this._work = $.extend true, {}, data
      this._dirty = false
      return this
    null
  destroy: (key) ->
    data = this.find key
    if null != data
      APP.storage.destroy key
    null
  save: () ->
    if this._dirty == false
      return this
    # for safety and checks
    key_check = this._work['key']
    this._work['key'] = this._real_key key_check
    # update the timestamp
    this._work['updated_timestamp'] = (new Date()).getTime()
    # save this
    data = APP.storage.save this._work['key'], this._work
    if null != data
      # set _dirty to false
      this._dirty = false
      if this._save_collection == true
        collection = APP.models.collections.find this.type
        if null == collection 
          collection = APP.models.collections.create key:this.type
        else
          APP.logger.debug 'Time to clean up this type: ' + this.type + ' and keep: ' + this._keep
          collection._cleanup this._keep, this.type
        existing_collection = collection.get 'collection'
        existing_collection.push key:this._work['key'],timestamp:(new Date()).getTime(),active:true
        overwrite_collection = collection:existing_collection, last_key:this._work['key']
        APP.logger.debug overwrite_collection
        collection.set overwrite_collection
        APP.logger.debug 'New last_key should be: ' + this._work['key']
    this
  create: (dt) ->
    this.init()
    this._work = $.extend true, {}, this._data
    if undefined != dt
      this._work = $.extend true, this._work, dt
      if !this._work['key']
        this._work['key'] = APP.storage.orm.generate_key()
      this._work['created_timestamp'] = (new Date()).getTime()
      this._work['updated_timestamp'] = (new Date()).getTime()
      this._dirty = true
      this.save()
    this
  add_columns: (cols) ->
    this._data = $.extend true, this._data, cols
    true
  _work: {}
  _save_collection: true
  _dirty: false
  _keep: -1
  type: 'base'
  _data:
    key: null
    created_timestamp: null
    updated_timestamp: null

#------------------------------------------------
#     PRIVATE
#------------------------------------------------  

APP.ns 'models.collections'
APP.models.collections = APP.models.extend()
APP.models.collections.init = () ->
  this.add_columns collection: [], last_key:null
  this.type = 'collections'
  this._save_collection = false
  true
APP.models.collections._cleanup = (keep, type) ->
  if undefined == keep or keep < 0
    return false
  new_collection = []
  keep = keep - 1
  APP.logger.debug 'Cleanup everything, but the last: ' + keep
  if keep > 0
    collection = this.get 'collection'
    last_key = this.get 'last_key'
    if collection and [] != collection
      total = collection.length
      total_keep = total - keep
      for item, i in collection
        keep = false
        if i >= total_keep
          keep = true
        if last_key == item.key
          keep = true
        if keep == true
          new_collection.push item
        else
          if undefined == type
            type = this._work['key'].replace this.type+'_'
          if APP.models.hasOwnProperty type
            db_model = APP.models[type].find item.key
            db_model.destroy()
            db_model = null
  this.set 'collection':new_collection
  true

APP.ns 'models.settings'
APP.models.settings = APP.models.extend()
APP.models.settings.init = () ->
  this.add_columns values: {}
  this.type = 'settings'
  this._save_collection = false
  true
APP.models.settings.set_value = (key, value) ->
  values = this.get 'values'
  values[key] = value
  this.set values:values
  this.save()
  APP.settings.db = values
  true

#------------------------------------------------#

APP.ns 'models.exceptions'
APP.models.exceptions = 
  model_undefined: (value) ->
    this.value = value.toString()
    this.message = 'Model: {{value}} could not be found!'
    this.toString = () ->
      this.message.replace('{{value}}', this.value)
  data_undefined: (value) ->
    this.value = value.toString()
    this.message = 'Data: "{{value}}" not set!'
    this.toString = () ->
      this.message.replace('{{value}}', this.value)
  key_undefined: (value) ->
    this.value = value.toString()
    this.message = 'Data: "{{value}}" not set!'
    this.toString = () ->
      this.message.replace('{{value}}', this.value)
  key_cant_be_set: (value) ->
    this.value = value.toString()
    this.message = 'Key can not be set: "{{value}}"!'
    this.toString = () ->
      this.message.replace('{{value}}', this.value)
