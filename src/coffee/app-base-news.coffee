APP.ns 'base_news'
APP.base_news =
  _interval: null
  _interval_check: null
  _internal_news: null
  _retrieve_lock: false
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
  get_internal_news: () ->
    if null == this._internal_news
      this._internal_news = $ '#internal-news-content .content'
    this._internal_news
  get_news_item: (news_item, total, i) ->
    title = news_item.title
    desc = news_item.description
    desc = desc.replace /(<([^>]+)>)/ig,''
    $item = $ '<div id="internal-news-item-{0}" rel="{0}" class="internal-news-item"><h4>{1}</h4><p>{2}</p></div>'.format i, title, desc
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
    $internal_news = APP.internal_news.get_internal_news()
    $internal_news.find('.internal-news-item:first').trigger 'change.internal-news-setup'
    true
  container_animate: () ->
    $internal_news = APP.internal_news.get_internal_news()
    $ready = $internal_news.find('.internal-news-item.ready')
    $total = $internal_news.find('.internal-news-item')
    if $ready.length == $total.length
      $ready.removeClass 'ready'
      $ready.trigger 'change.internal-news-animate'
    true
  retrieve: (cbfunc) ->
    if this._retrieve_lock == true
      return false
    this._retrieve_lock = true
    cb = cbfunc or () ->
      true
    $internal_news = this.get_internal_news()
    offset = 0
    total = 0
    APP.lib.api_update 'internal_news', (type, update_bool)->
      update_bool = true
      if update_bool == true
        internal_news_url = '{0}{1}'.format APP.settings.db.panel.url, APP.settings.db.api.internal_news
        $.ajax
          url: internal_news_url
          method: 'GET'
          dataType: 'json'
        .done (data, textStatus, jqXHR)->
          $internal_news.html ''
          total = data.feeds.length
          for news_item, i in data.feeds
            # get the news item
            $item = APP.internal_news.get_news_item(news_item, total, i)
            # append to the internal news content
            $internal_news.append $item
            # calculate the new top
            setup_new_top = APP.internal_news.get_item_top $item, offset
            $item.data 'new-top', setup_new_top
            $item.css 'top': setup_new_top + 'px','z-index':(100+i)
            $item.on 'change.internal-news-setup', (e) ->
              $this = $(this)
              $parent = $this.parent()
              total_items = $parent.find('.internal-news-item').length
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
                next_id = '#internal-news-item-' + (this_rel + 1)
                if $this.hasClass 'last'
                  next_id = '#internal-news-item-0'
                $next = $ next_id
                if $next.length > 0
                  $next.trigger 'change.internal-news-setup'
              else if $this.index() == (total_items-1)
                $ready = $internal_news.find('.internal-news-item.ready')
                $total = $internal_news.find('.internal-news-item')
                if $ready.length == $total.length
                  $ready.removeClass 'ready'
                  $ready.trigger 'change.internal-news-animate'
              true
            $item.on 'change.internal-news-animate', (e) ->
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
          if total > 1
            interval = setInterval APP.internal_news.container_setup, 16000
            APP.internal_news.set_interval interval
            interval_check = setInterval APP.internal_news.container_animate, 2000
            APP.internal_news.set_interval_check interval_check
          this._retrieve_lock = false
          cb true
        .fail (jqXHR, textStatus, errorThrown)->
          APP.internal_news.clear()
          $internal_news.html APP.message.get_message 'An error occurred retrieving the internal news data'
          this._retrieve_lock = false
          cb false
      # if update_bool == true    
      else
        APP.internal_news.clear()
        APP.internal_news.clear_check()
        $internal_news.html APP.message.get_message 'An error occurred retrieving the internal news events data.'
        this._retrieve_lock = false
        cb false
      true
    true
  init: (cbfunc) ->
    cb = cbfunc or () ->
      true
    $internal_news = this.get_internal_news()
    this.clear()
    this.clear_check()
    if APP.settings.db.panel.url == ''
      $internal_news.html APP.message.get_message 'The url for the internal news is missing.'
    else
      this.retrieve()
    cb()