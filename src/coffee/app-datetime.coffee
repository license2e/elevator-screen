APP.ns 'datetime'
APP.datetime =
  date_check: false
  _today: null
  _interval: null
  _currenth: null
  _currentm: null
  clear: (cbfunc) ->
    cb = cbfunc or () ->
      true
    if null != this._interval
      clearTimeout this._interval  
    cb()
  set_interval: (interval) ->
    this.clear()
    this._interval = interval
    true
  get_today: () ->
    this._today = new Date()
  get_day_of_week: (d, abbr) ->
    day = 'Sunday'
    if d == 1
      day = 'Monday'
    else if d == 2
      day = 'Tuesday'
    else if d == 3
      day = 'Wednesday'
    else if d == 4
      day = 'Thursday'
    else if d == 5
      day = 'Friday'
    else if d != 0
      day = 'Saturday'
    if undefined != abbr && abbr == true
      day = day.substring 0, 3
    day
  get_month: (m) ->
    month = 'Jan'
    if m == 1
      month = 'Feb'
    else if m == 2
      month = 'Mar'
    else if m == 3
      month = 'Apr'
    else if m == 4
      month = 'May'
    else if m == 5
      month = 'Jun'
    else if m == 6
      month = 'Jul'
    else if m == 7
      month = 'Aug'
    else if m == 8
      month = 'Sep'
    else if m == 9
      month = 'Oct'
    else if m == 10
      month = 'Nov'
    else if m != 0
      month = 'Dec'
    month
  get_date: (id, cbfunc) ->
    cb = cbfunc or () ->
      true
    $this = $('#date')
    today = APP.datetime.get_today()
    dow = today.getDay()
    dowf = APP.datetime.get_day_of_week dow
    mon = today.getMonth()
    monf = APP.datetime.get_month mon
    dt = today.getDate()
    $this.html '{0}, {1} {2}'.format dowf,monf,dt
    cb()
  two_digits: (num) ->
    ("0" + num).slice(-2)
  get_time: (cbfunc) ->
    cb = cbfunc or () ->
      true    
    $this = $ '#time-display'
    $am = $ '#time-am'
    $pm = $ '#time-pm'
    today = APP.datetime.get_today()
    h = today.getHours()
    m = today.getMinutes()
    mf = APP.datetime.two_digits m
    s = today.getSeconds()
    sf = APP.datetime.two_digits s
    if h < 12
      if h == 0
        h = 12
      $am.fadeIn 'slow'
      $pm.fadeOut 'slow'
    else
      if h > 12
        h = h - 12
      $am.fadeOut 'slow'
      $pm.fadeIn 'slow'
    $this.html '{0}:{1}'.format h,mf
    if h == 12 and m == 0 and (s >= 0 or s <= 10) and APP.datetime.date_check == false
      APP.datetime.date_check = true
    if APP.datetime.date_check == true
      APP.datetime.get_date()
      APP.datetime.date_check = false
    interval = setTimeout APP.datetime.get_time, 2000
    APP.datetime.set_interval interval
    cb()
    true
  init: (cbfunc) ->
    cb = cbfunc or () ->
      true
    this.get_time()
    this.get_date()
    cb()
