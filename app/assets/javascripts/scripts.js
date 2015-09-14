$(document).ready(function() {

//////////////////////////////////////////////////////////////////////////////
// Timer

	var $start_time, $end_time, clocktimer, currenttime;
	var $timerText = $('#timelog-timer');
	var $clockText = $('#current-time');		 

	// Timer object
	var timeloggerClock = function() {
		$start_time  = 0;
		$end_time = 0;

		// Now.
		var now = function() {
			return Math.floor(Date.now() / 1000);
		}
		
		// Start time is now.
		this.start = function() {
			$start_time = now();
		}

		// Start time was when user first clicked button. 
		this.continueTimer = function() {
			$start_time = parseInt(getCookie('start_time'), 10);
		}
		
		// end time is now.
		this.end = function() {
			$end_time = now();
		}
		
		// Time elapsed since user clicked button.
		this.time = function() {
			return now() - $start_time;
		}
	}

	var x = new timeloggerClock();

	// Pads a number with zeros.
	// Examples: pad(2,3) -> '002'; pad(30, 2) -> '30'
	function pad(num, size) {
		var s;
		s = '0000' + num;
		return s.substr(s.length - size);
	}

	// Given UNIX timestamp, formats it to hhh:mm:ss.
	function formatTime(time) {
		var h, m, s, newTime;
		h = m = s = 0;
		newTime = '';
		h = Math.floor(time / (60 * 60));
		time = time % (60 * 60);
		m = Math.floor(time / 60);
		time = time % 60;
		s = Math.floor(time);
		newTime = pad(h, 3) + ':' + pad(m, 2) + ':' + pad(s, 2);
		return newTime;
	}

	function formatClock() {
    var currentTime = new Date();
    var currentTimeText = '';
    var diem = "AM";
    var h = currentTime.getHours();
    var m = currentTime.getMinutes();
    var s = currentTime.getSeconds();
    if (h == 0) {
        h = 12
    } 
    else if (h > 12) {
        h = h - 12;
        diem = "PM";
    }
    currentTimeText = h.toString() + ':' + pad(m, 2) + ':' + pad(s, 2) + " " + diem;
    return currentTimeText;
	}

	// Updates timer text to time elapsed, formatted nicely.
	function update() {
		$timerText.html(function() {
			return formatTime(x.time());
		});
	}

	// Updates clock test to current time, formatted nicely.
	function updateRegularClock() {
		$clockText.html(function() {
			return formatClock;
		});
	}

	// Sets clock running, updated every second.
	function runClock() {
		currenttime = setInterval(updateRegularClock, 1000);
	}

	// Sets timer running, updated every second.
	// Start is when user first clicked 'start' button.
	function activateTimer() {
		if(isCookie('start_time')) {
			x.continueTimer();
		}
		else {
			x.start();
		}
		clocktimer = setInterval(update, 1000);
	}

	// Sets end time to now.
	// Stops timer running.
	function end() {
		x.end();
		clearInterval(clocktimer);
	}

	var runningButtons = $('.timelog-button-running');
	var restingButtons = $('.timelog-button-resting');

	// Shows or hides the appropriate set of timelog button options.
	function timerRunningDisplay() {
		runningButtons.removeClass('hidden');
		restingButtons.addClass('hidden');
	}

	function timerRestingDisplay() {
		restingButtons.removeClass('hidden');
    runningButtons.addClass('hidden');
	}

//////////////////////////////////////////////////////////////////////////////
// Cookies and Storage
	
	// Returns cookie's value, given its name.
	function getCookie(cname) {
	  var name = cname + "=";
	  var ca = document.cookie.split(';');
	  for(var i=0; i<ca.length; i++) {
	    var c = ca[i];
	    while (c.charAt(0)==' ') c = c.substring(1);
	    if (c.indexOf(name) == 0) return c.substring(name.length,c.length);
	  }
	  return "";
	}

	// Given a name, a value, and an expiration date in days,
	// sets a cookie.
	function setCookie(cname, cvalue, exdays) {
	  var d = new Date();
	  d.setTime(d.getTime() + (exdays*24*60*60*1000));
	  var expires = "expires="+d.toUTCString();
	  document.cookie = cname + "=" + cvalue + "; " + expires;
	}

	// Deletes a cookie.
	// Deleted cookies return -> ""
	function deleteCookie(cname, cvalue) {
		setCookie(cname, cvalue, -1);
	} 

	// Checks if cookie has been set.
	function isCookie(cname) {
		if(getCookie(cname) == "") {
			return false
		}
		else {
			return true
		}
	}

//////////////////////////////////////////////////////////////////////////////
// Listeners

	// Set user id hidden field value to null on page load.
	$('#user-id-catch').val(null);

	// Run current time clock on page load.
	runClock();

	// Handles grants fulfillments menu selections.
	$(document).on("change", "#since_date", function(e) {
		e.preventDefault();
		var select_val  = $('#since_date option:selected').val();
		var date_inputs = $('.date-input');
		// When "other date" option is selected,
		if(select_val === "other") {
			// show manual date entry field.
			date_inputs.removeClass('hidden');
		}
		// When a selection other than "other date" is made,
		else {
			if(!(date_inputs.hasClass('hidden'))) {
				// hide manual date entry fields if they're shown.
				date_inputs.addClass('hidden');
			}
			$.get("http://localhost:3000/get_current_user_id", function() {
				$.ajax({
					type: "POST",
					url: "http://localhost:3000/users/" + $('#user-id-catch').val() + "/grants_fulfillments_table",
					data: { since_date: select_val }
				});
			});
		}
		if($('#user-id-catch').val() !== null) {
			$('#user-id-catch').val(null);
		}
	});

	$(document).on("click", "#date-input-submit", function(e) {
		e.preventDefault;
		var select_val = $('#date-input-entry').val();
		$.get("http://localhost:3000/get_current_user_id", function() {
			$.ajax({
				type: "POST",
				url: "http://localhost:3000/users/" + $('#user-id-catch').val() + "/grants_fulfillments_table",
				data: { since_date: select_val }
			});
		});
		if($('#user-id-catch').val() !== null) {
			$('#user-id-catch').val(null);
		}		
	});

	// On page load, check if user has previously
	// clicked the timelog start button but not the 
	// timelog end button.
	// If so, start the timer from when the user first
	// clicked the button.
	if(isCookie('start_time') || $start_time) {
		timerRunningDisplay();
		activateTimer();			
	}

	// When user clicks timelog start button,
	// start timer and save the click time in cookies.
  $(document).on("click", '#start-timelog', function(e) {
  	e.preventDefault();
  	timerRunningDisplay();
  	activateTimer();
  	setCookie('start_time', $start_time, 7);
	});

  // When user clicks timelog end button, stop timer.
  // Then find start time and post both start and end times
  // to controller. Finally, delete the start time cookie if it exists.
	$(document).on("click", '#end-timelog', function(e) {
		e.preventDefault();
		end();
		timerRestingDisplay();		
		if ((typeof $start_time === 'undefined') || $start_time === null) {
			$start_time = getCookie('start_time');
		}
		$.get("http://localhost:3000/get_current_user_id", function() {
			$.ajax({
				type: "POST",
				url: "http://localhost:3000/users/" + $('#user-id-catch').val() + "/timelogs/end_from_button",
				data: {
					start_time: $start_time,
					end_time: $end_time
				}
			});
		});		
		deleteCookie('start_time', $start_time);
		if($('#user-id-catch').val() !== null) {
			$('#user-id-catch').val(null);
		}
	});		

	$(document).on("defaultClick", '#cancel-timelog', function() {}
	);

	// When user clicks cancel timelog button, delete the start time
	// cookie if it exists and toggle the start button options.
	$(document).on("click", '#cancel-timelog', function(e) {
		e.preventDefault();
		deleteCookie('start_time', $start_time);
		timerRestingDisplay();
		$('#cancel-timelog').trigger("defaultClick");
		if($('#user-id-catch').val() !== null) {
			$('#user-id-catch').val(null);
		}
	});

});