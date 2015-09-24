module TimelogsHelper

	def day_display(day)
	  day.to_time.strftime("%a %b %e %Y")
	end

end