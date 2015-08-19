var timeloggerClock = function() {
	var $startAt = 0;
	var $finishAt = 0;
	var now = function() {
		return Date.now();
	};
	
	this.start = function() {
		$startAt = now();
	};
	
	this.finish = function() {
		$finishAt = now();
	};
	
	this.time = function() {
		return $finishAt - $startAt;
	};
};

var x = new timeloggerClock();
var $time_text, clocktimer;

function pad(num, size) {
	var s;
	s = '0000' + num;
	return s.substr(s.length - size);
};

function formatTime(time) {
	var h, m, newTime, s;
	h = m = s = 0;
	newTime = '';
	h = Math.floor(time / (60 * 60 * 1000));
	time = time % 60 * 60 * 1000;
	m = Math.floor(time / (60 * 1000));
	time = time % 60 * 1000;
	s = Math.floor(time / 1000);
	newTime = pad(h, 2) + ':' + pad(m, 2) + ':' + pad(s, 2);
	return newTime;
};

function show() {
	$time_text = document.getElementById('timelog-timer');
	update();
};

function update() {
	$time_text.innerHTML = formatTime(x.time());
};

function start() {
	clocktimer = setInterval("update()", 100);
	x.start();
	$.post('/timesheets/start_from_button',
		{ timesheet_start: $startAt }
	);
};

function finish() {
	x.finish();
	clearInterval(clocktimer);
	$.post('/timesheets/finish_from_button',
		{ timesheet_finish: $finishAt },
	);
};

$(document).ready(function() {
	
  $('#since-date').change(function() {
    $.post('users/grants_fulfillments_table',
      { since_date: $(this).val() }
    );
  });
	
  $('#timelog-button-resting').click(function() {
  	start();
	});
	
	$('#timelog-button-running').click(function() {
		finish();
	});
});