$(document).ready ->
	
	$('#since-date').change ->
		$.ajax
	    url: $(this).attr('ajax_path')
			data: $(this).val()
	  return
		
	$('#timelog-button').click ->
		start_time = (new Date).getTime()
		$(this).text("Finish Timelog")
		$(this).toggleClass('tracking')
		$('#timelog-cancel-button').fadeToggle('fast')
		
	$('#timelog-button')
		
		
		
# Timer function
	
doTimer = (length, resolution, oninstance, oncomplete) ->
  steps = length / 100 * resolution / 10
  speed = length / steps
  count = 0
  start = (new Date).getTime()

  instance = ->
    if count++ == steps
      oncomplete steps, count
    else
      oninstance steps, count
      diff = (new Date).getTime() - start - (count * speed)
      window.setTimeout instance, speed - diff
    return

  window.setTimeout instance, speed
  return