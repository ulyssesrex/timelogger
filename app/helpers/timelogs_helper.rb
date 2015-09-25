module TimelogsHelper

	def day_display(day)
	  day.to_time.strftime("%a %b %e %Y")
	end

	def time_display(time)
		time.strftime("%l:%M:%S %p, %A %e %B %Y")
	end

end