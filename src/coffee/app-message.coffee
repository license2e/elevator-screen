APP.ns 'message'
APP.message =
  get_message: (msg) ->
    '<div class="message"><em>We apologize for the inconvenience. {0} Thank you for your patience while we correct the issue!</em></div>'.format msg
  init: (cbfunc) ->
    cb = cbfunc or () ->
      true    
    cb()