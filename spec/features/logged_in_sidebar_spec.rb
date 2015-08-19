require 'rails_helper'
require 'support/session_helpers'
include SessionHelpers

feature "Logged-in sidebar", feature: true do
	let(:user) { create(:user) }
	let(:unactivated_button)  { page.find_by_id('timelog-button-resting') }

	before(:each) { spec_login(user) }

  feature "Start timelog button" do
  	it "initially displays in unactivated state" do
      expect(unactivated_button).to be_present
  	end

  	it "creates a cancel link when clicked" do
  		click_link("timelog-button-resting")
  		expect(page.find_by_id('timelog-button-cancel')).to be_present
  	end

  	it "toggles its id when clicked" do
  		preclick_id = page.find_by_id('timelog-button-resting')
  		click_link("timelog-button-resting")
  		postclick_id = page.find_by_id('timelog-button-running')
  		expect(preclick_id.attr('id')).not_to eq(postclick_id.attr('id'))
  	end

  	it "toggles its text when clicked" do
  		expect{ click_link("timelog-button-resting") }.to change(unactivated_button, :text)
  	end
  end

	feature "Timelog from scratch button" do
	  it "displays a timelog-from-scratch button" do
	  	expect(find_link("Timelog from scratch")).to be_present
	  end

	  it "redirects to form for new Timelog when clicked" do
	  	click_link("Timelog from scratch")
	  	expect(page.title).to have_content(/New Timelog/)
	  end
	end

  it "displays the timelog timer" do
  	expect(page.find_by_id('timelog-timer')).to be_present
  end

  feature "Current time clock" do
  	it "displays the current time" do
  		expect(page.find_by_id('current-time')).to be_present
  	end

  	it "changes every second" do
  		time_1 = page.find_by_id('current-time').text
  		sleep 1
  		expect(page.find_by_id('current-time').text).not_to eq(time_1)
  	end
  end
end