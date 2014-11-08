APP.ns 'internal_alerts'
APP.internal_alerts =
  _interval: null
  _interval_check: null
  _internal_alerts: null
  _retrieve_lock: false
  unlock: ()->
    this._retrieve_lock = false
    true
  clear: (cbfunc) ->
    cb = cbfunc or () ->
      true
    if null != this._interval
      clearInterval this._interval  
    cb()
  set_interval: (interval) ->
    this.clear()
    this._interval = interval
    true
  clear_check: (cbfunc) ->
    cb = cbfunc or () ->
      true
    if null != this._interval_check
      clearInterval this._interval_check  
    cb()
  set_interval_check: (interval) ->
    this.clear_check()
    this._interval_check = interval
    true
  get_internal_alerts: () ->
    if null == this._internal_alerts
      this._internal_alerts = $ '#internal-alerts-content .content'
    this._internal_alerts
  get_news_item: (news_item, total, i) ->
    title = news_item.title
    desc = news_item.description
    desc = desc.replace /(<([^>]+)>)/ig,''
    $item = $ '<div id="internal-alerts-item-{0}" rel="{0}" class="internal-alerts-item"><h4>{1}</h4><p>{2}</p></div>'.format i, title, desc
    if i == (total - 1)
      $item.addClass 'last'
    $item
  get_item_top: ($item, offset) ->
    $prev = $item.prev()
    if $prev.length > 0
      prev_top = parseInt $prev.css 'top'
      prev_outerheight = parseInt $prev.outerHeight()
    else 
      prev_top = 0
      prev_outerheight = 0
    prev_top + prev_outerheight + offset
  container_setup: () ->
    $internal_alerts = APP.internal_alerts.get_internal_alerts()
    $internal_alerts.find('.internal-alerts-item:first').trigger 'change.internal-alerts-setup'
    true
  container_animate: () ->
    $internal_alerts = APP.internal_alerts.get_internal_alerts()
    $ready = $internal_alerts.find('.internal-alerts-item.ready')
    $total = $internal_alerts.find('.internal-alerts-item')
    if $ready.length == $total.length
      $ready.removeClass 'ready'
      $ready.trigger 'change.internal-alerts-animate'
    true
  retrieve: (force, cbfunc) ->
    if this._retrieve_lock == true
      return false
    this._retrieve_lock = true
    cb = cbfunc or () ->
      true
    $internal_alerts = this.get_internal_alerts()
    offset = 0
    total = 0
    APP.lib.api_update 'internal_alerts', (type, update_bool)->
      if force == true
        update_bool = true
      if update_bool == true
        internal_alerts_url = '{0}{1}'.format APP.settings.db.panel.url, APP.settings.db.api.internal_alerts
        $.ajax
          url: internal_alerts_url
          method: 'GET'
          dataType: 'json'
        .done (data, textStatus, jqXHR)->
          $existing_feed_items = $internal_alerts.find '.internal-alerts-item'
          if $existing_feed_items.length > 0
            $existing_feed_items.each ()->
              $this = $(this)
              $this.fadeOut('slow').remove()
              true
          total = data.feeds.length
          for news_item, i in data.feeds
            # get the news item
            $item = APP.internal_alerts.get_news_item(news_item, total, i)
            # append to the internal news content
            $internal_alerts.append $item
            # calculate the new top
            setup_new_top = APP.internal_alerts.get_item_top $item, offset
            $item.data 'new-top', setup_new_top
            $item.css 'top': setup_new_top + 'px','z-index':(100+i)
            $item.on 'change.internal-alerts-setup', (e) ->
              $this = $(this)
              $parent = $this.parent()
              total_items = $parent.find('.internal-alerts-item').length
              # this
              current_top = parseInt $this.css 'top'
              height = $this.outerHeight()
              this_rel = parseInt $this.attr 'rel'
              # calculate new top
              if current_top == 0
                new_top = ((current_top - height) + offset)
              else
                # prev
                $prev = $this.prev()
                prev_new_top = parseInt $prev.data 'new-top'
                prev_height = parseInt $prev.outerHeight()
                prev_after = (prev_new_top + prev_height)
                new_top = (prev_after + offset)
              $this.data 'new-top', new_top
              $this.addClass 'ready'
              # as long as this isnt the last one
              if $this.index() < (total_items-1)
                # next 
                next_id = '#internal-alerts-item-' + (this_rel + 1)
                if $this.hasClass 'last'
                  next_id = '#internal-alerts-item-0'
                $next = $ next_id
                if $next.length > 0
                  $next.trigger 'change.internal-alerts-setup'
              else if $this.index() == (total_items-1)
                $ready = $internal_alerts.find('.internal-alerts-item.ready')
                $total = $internal_alerts.find('.internal-alerts-item')
                if $ready.length == $total.length
                  $ready.removeClass 'ready'
                  $ready.trigger 'change.internal-alerts-animate'
              true
            $item.on 'change.internal-alerts-animate', (e) ->
              $this = $(this)
              duration = 400
              new_top = $this.data 'new-top'
              css_obj = top:new_top+'px'
              complete = () ->
                true
              # check to see if $this is out of sight
              if new_top < 0
                complete = () ->
                  $this = $(this)
                  $this.hide()
                  $parent = $this.parent()
                  $parent.append $this
                  $prev = $this.prev()
                  prev_new_top = parseInt $prev.data 'new-top'
                  prev_height = parseInt $prev.outerHeight()
                  prev_after = (prev_new_top + prev_height)
                  new_top = (prev_after + offset)
                  $this.css top:new_top+'px'
                  $this.show()
                  true
              $this.animate css_obj, duration, complete
              true
          # end for
          if total == 0
            $('#internal-news-section').removeClass 'smaller'
            $('#internal-alerts-section').removeClass 'larger'
          else
            $('#internal-news-section').addClass 'smaller'
            $('#internal-alerts-section').addClass 'larger'
            if total > 1
              interval = setInterval APP.internal_alerts.container_setup, 8000
              APP.internal_alerts.set_interval interval
              interval_check = setInterval APP.internal_alerts.container_animate, 2000
              APP.internal_alerts.set_interval_check interval_check
            else
              APP.internal_alerts.clear()
              APP.internal_alerts.clear_check()
          APP.internal_alerts.unlock()
          cb true
        .fail (jqXHR, textStatus, errorThrown)->
          APP.internal_alerts.clear()
          APP.internal_alerts.clear_check()
          $internal_alerts.html APP.message.get_message 'An error occurred retrieving the internal alerts data'
          APP.internal_alerts.unlock()
          cb false
      # if update_bool == true
      else
        APP.internal_alerts.unlock()
      true
    true
  init: (cbfunc) ->
    cb = cbfunc or () ->
      true
    $internal_alerts = this.get_internal_alerts()
    this.clear()
    this.clear_check()
    if APP.settings.db.panel.url == ''
      $internal_alerts.html APP.message.get_message 'The url for the internal alerts is missing.'
    else
      this.retrieve(true)
    cb()
