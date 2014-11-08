APP.ns 'external_news'
APP.external_news =
  _interval: null
  _news_content: null
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
  get_news_content: () ->
    if null == this._news_content
      this._news_content = $ '#external-news-content .content'
    this._news_content
  container_animate: () ->
    $news_content = APP.external_news.get_news_content()
    $news_content.find('.external-news-item').trigger 'change.external-news'
    true
  retrieve: (force, cbfunc) ->
    if this._retrieve_lock == true
      APP.logger.debug 'External news retrieval lock is activated, returning..'
      return false
    this._retrieve_lock = true
    cb = cbfunc or () ->
      true
    $news_content = this.get_news_content()
    adjust = 127
    offset = 0
    total = 0
    APP.lib.api_update 'external_news', (type, update_bool)->
      if force == true
        update_bool = true
      if update_bool == true
        external_news_url = '{0}{1}'.format APP.settings.db.panel.url, APP.settings.db.api.external_news
        $.ajax
          url: external_news_url
          method: 'GET'
          dataType: 'json'
        .done (data, textStatus, jqXHR)->
          $existing_feed_items = $news_content.find '.external-news-item'
          if $existing_feed_items.length > 0
            $existing_feed_items.each ()->
              $this = $(this)
              $this.fadeOut('slow').remove()
              true
          total = data.feeds.length
          for feed_item, i in data.feeds
            id = 'external-feed-{0}'.format feed_item.id
            item_top = ((i*adjust)+offset)
            #APP.logger.debug 'Item top: {0}'.format item_top
            title = feed_item.title
            desc = feed_item.description
            desc = desc.replace /(<([^>]+)>)/ig,''
            #desc = desc.substring 0, 180
            desc = $.trim desc
            $item = $ '<div id="{0}" class="external-news-item"><h4>{1}</h4><p>{2}</p></div>'.format id, title, desc
            $item.css 'top':item_top + 'px','z-index':(100+i)
            if i == (total - 1)
              $item.addClass 'last'
            $news_content.append $item
            $item.on 'change.external-news', (e) ->
              $this = $(this)
              current_top = parseInt $this.css 'top'
              new_top = ((current_top - adjust)+offset)
              $last = $news_content.find('.external-news-item.last')
              last_top = parseInt $last.css 'top'
              if new_top < (adjust-(adjust*2))
                $last.removeClass 'last'
                $this.hide()
                $this.animate 'top':(last_top)+'px'
                $this.fadeIn 'slow'
                $this.addClass 'last'
              else
                $this.animate top:new_top+'px'
              true
          # end for
          if total > 1
            interval = setInterval APP.external_news.container_animate, 12000
            APP.external_news.set_interval interval
          else
            APP.external_news.clear()
          APP.external_news.unlock()
          cb true
        .fail (jqXHR, textStatus, errorThrown)->
          APP.external_news.clear()
          $news_content.html APP.message.get_message 'An error occurred retrieving the external news data'
          APP.external_news.unlock()
          cb false
      # if update_bool == true
      else 
        APP.external_news.unlock()
      true
    true
  init: (cbfunc) ->
    cb = cbfunc or () ->
      true
    $news_content = this.get_news_content()
    this.clear()
    if APP.settings.db.panel.url == ''
      $news_content.html APP.message.get_message 'The url for the external news is missing.'
    else
      this.retrieve(true)
    cb()
