require 'rails_helper'
require 'support/session_helpers'
include SessionHelpers

feature "New timelog from button", :js => true do


	feature "Timelog button click" do

		def timelog_button_click
			spec_login(user)
			click_link("timelog-button-resting")
		end

		let(:user) do 
			create(:user)
		end

		let(:activated_button) do
			page.find_by_id('timelog-button-running') 
		end

		let(:timer) do
			page.find_by_id('timelog-timer')
		end

		before(:each) do |spec|
			timelog_button_click
		end

		it "changes the timelog button id" do
			expect(activated_button).to be_present		
		end

		it "changes the timelog button text" do
			expect(activated_button).to have_content("Finish Timelog")
		end

		it "starts the timer" do
			begin_time = timer.text
			sleep 1
			end_time = timer.text
			expect(end_time).not_to eq begin_time
		end
	end

	feature "Create timelog from button" do

		def create_timelog_from_button
			timelog_button_click
			sleep 1
			click_link("timelog-button-running")
		end
		
		before(:each) { create_timelog_from_button }

		it "ends the timer"
		it "redirects to the new timelog page"
		it "autofills the start and finish time fields"
	end
end