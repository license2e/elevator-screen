APP.ns 'storage'
APP.storage = 
  find: (key, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    # return the storage
    this.orm.getObject key
  save: (key, data, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    # save to the storage
    this.orm.setObject key, data
  destroy: (key, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    # save to the storage
    this.orm.destroyObject key
  clear: (, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    # save to the storage
    this.orm.clear()

#-----------------------------
# ORM
#-----------------------------
APP.ns 'storage.orm'
APP.storage.orm = 
  destroyObject: (key, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    APP.logger.debug key
    localStorage.removeItem key
    cb(true)
  # key should be a string for you to get happy results
  setObject: (key, object, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    localStorage.setItem key, JSON.stringify object
    cb(object)
  # here, the key is also an object
  setObjectKey: (key_object, object, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    localStorage.setItem JSON.stringify key_object, JSON.stringify object
    cb(object)
  # again, key must be string
  getObject: (key, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    item = localStorage.getItem key
    cb(item and JSON.parse item)
  # key can/should be an object
  getObjectKey: (key_object, cbfunc) ->
    cb = cbfunc or (data) ->
      data
    item = localStorage.getItem JSON.stringify key_object
    cb(item and JSON.parse item)
  clear: (cbfunc) ->
    cb = cbfunc or (data) ->
      data
    APP.logger.debug "Cleared all the settings!"
    localStorage.clear()
    cb(true)
  generate_key: (len) ->
    chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz"
    string_length = len || 10
    randomstring = ''
    string_length++
    while string_length -= 1
      rnum = Math.floor Math.random() * chars.length
      randomstring += chars.substring rnum, rnum+1
    randomstring
