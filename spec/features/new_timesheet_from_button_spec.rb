require 'rails_helper'
require 'support/session_helpers'
include SessionHelpers

feature "New timesheet from button", :js => true do

	feature "Timesheet button click" do

		def timesheet_button_click
			general_login
			click_link("timelog-button-resting")
		end

		let(:activated_button) do
			page.find_by_id('timesheet-button-running') 
		end

		let(:timer) do
			page.find_by_id('timelog-time')
		end

		before(:each) { timesheet_button_click }

		it "changes the timesheet button id" do
			expect(activated_button).to be_present		
		end

		it "changes the timesheet button text" do
			expect(activated_button).to have_content("Finish Timelog")
		end

		it "starts the timer" do
			begin_time = timer.text
			sleep 1
			end_time = timer.text
			expect(end_time).not_to eq begin_time
		end
	end

	feature "Create timesheet from button" do

		def create_timesheet_from_button
			timesheet_button_click
			sleep 1
			click_link("timelog-button-running")
		end
		
		before(:each) { create_timesheet_from_button }

		it "ends the timer"
		it "redirects to the new timesheet page"
		it "autofills the start and finish time fields"
	end
end