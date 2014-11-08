APP.ns 'debug'
APP.debug =
	r: null
	correction: 1000*2
	fcgr: 
		graph: null
		total: null
		R: null
		color: "#000"
	marks_attrs:
		fill: "#777"
		stroke: "none"
	param:
		stroke: "#fff"
		"stroke-width": 8
	get_forecast_value: ()->
		fcv = Math.ceil(APP.forecast.get_current_dt()-APP.forecast.last_check())
		fcv = fcv/APP.forecast.get_api_check_interval()
		fcv = Math.floor((fcv)*this.fcgr.total)
		if fcv > this.fcgr.total
			fcv = this.fcgr.total
		this.update_value(this.fcgr.graph, fcv, this.fcgr.total, this.fcgr.R)
		true
	update_value: (graph, value, total, R, color) ->
		graph.animate({arc:[value, total, R, color]}, 750, "elastic")
		true
	draw_graphs: () ->
		this.r = Raphael("debug-info", 250, 250)
		R = 16

		# Custom Attribute
		this.r.customAttributes.arc = (value, total, R) ->
			alpha = 360 / total * value
			a = (90 - alpha) * Math.PI / 180
			rd2 = 125
			x = rd2 + R * Math.cos(a)
			y = rd2 - R * Math.sin(a)
			path = null
			if total == value
				path = [["M", rd2, rd2 - R], ["A", R, R, 0, 1, 1, (rd2-.01), rd2 - R]]
			else
				path = [["M", rd2, rd2 - R], ["A", R, R, 0, +(alpha > 180), 1, x, y]]
			return {path: path}

		# Add the forecast
		this.fcgr.R = 28
		this.fcgr.total = (APP.forecast.get_api_check_interval()/this.correction)
		this.fcgr.color = "#abc"
		this.draw_marks(this.fcgr.R, this.fcgr.total)
		this.fcgr.graph = this.r.path().attr(this.param).attr({stroke: this.fcgr.color}).attr({arc: [0, this.fcgr.total, this.fcgr.R]})
		this.get_forecast_value()
		
		# Setup the circle
		this.r.circle(125, 125, 16).attr(this.marks_attrs)

		(()->
			APP.debug.get_forecast_value()
			setTimeout arguments.callee, 2000
		)()

		return true
	draw_marks: (R, total) ->
		out = this.r.set()
		for value in [0..total] by 1
			alpha = 360 / total * value
			a = (90 - alpha) * Math.PI / 180
			x = 125 + R * Math.cos(a)
			y = 125 - R * Math.sin(a)
			out.push(this.r.circle(x, y, 1).attr(this.marks_attrs))
		return out
	init: () ->
		if APP.settings.db.debug_enabled == true
			this.draw_graphs()
			return true
		return false
