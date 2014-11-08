APP.ns 'logger'
APP.logger =
	TYPE_ERROR: 'error'
	TYPE_DEBUG: 'debug'
	error: (msg) ->
		this.log this.TYPE_ERROR, msg
		true
	debug: (msg) ->
		this.log this.TYPE_DEBUG, msg
		true
	log: (type, msg) ->
		log_message = false
		if type == this.TYPE_ERROR
			log_message = true
		else if type == this.TYPE_DEBUG and APP.settings.db.debug_enabled == true
			log_message = true
		if log_message == true
			console.log msg
		true