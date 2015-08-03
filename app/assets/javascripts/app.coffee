#	Simple example of using private variables
#
#	To start the stopwatch:
#		obj.start();
#
#	To get the duration in milliseconds:
#		var	x = obj.time();
#
#	To stop the stopwatch:
#		var	x = obj.finish();	// Result is duration in milliseconds

clsTimer = ->
	startAt = 0
	
	now = ->
		(new Date).getTime()
		
	@start = ->
		now()
		return
		
	@finish = ->
		now()
		return
		
	return
	
x = new clsTimer
$time = undefined
clocktimer = undefined

pad = (num, size) ->
	s = '0000' + num
	s.substr s.length - size
	
formatTime = (time) ->
	h = m = s = 0
	newTime = ''
	h = Math.floor(time / (60 * 60 * 1000))
	time = time % 60 * 60 * 1000
	m = Math.floor(time / (60 * 1000))
	time = time % 60 * 1000
	s = Math.floor(time / 1000)
	newTime = pad(h, 2) + ':' + pad(m, 2) + ':' + pad(s, 2)
	newTime
	
show = ->
	$time = $(document).ready.getElementById('js-timer')
	update()
	return
	
update = ->
	$time.innerHTML = formatTime(x.time())
	return
	
start = ->
	clocktimer = setInterval('update()', 100)
	x.start
	return
	
finish = ->
	x.finish
	clearInterval clocktimer
	return

# Listeners

$(document).ready ->
			
	$('#since-date').change ->
		$.ajax
			type: 'POST'
	    url: 'users/grants_fulfillments_table'			
			data: {since_date: $(this).val() }
			success: (msg) ->
				alert 'Does the grants table work? ' + msg
				return
		
	$('#timelog-button').click ->
		$start_time = (new Date).getTime()
		$(this).text("Finish Timelog")
		$(this).toggleClass('tracking')
		$('#timelog-cancel-button').fadeToggle('fast')
		
	$('#timelog-button .tracking').click ->
		$end_time = (new Date).getTime()
		$(this).text("")
		$(this).toggleClass('tracking')
		$('#timelog-cancel-button').fadeToggle('fast')
		$.ajax
			type: 'GET'
			url: 'timesheets/new_from_timer_button'
			data: {start_time: $start_time, end_time: $end_time}
			success: (msg) ->
				alert 'Does the button work?' + msg
				return
				
		
		
		
		
