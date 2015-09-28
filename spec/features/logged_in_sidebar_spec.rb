require 'rails_helper'
require 'support/session_helpers'
require 'support/wait_for_ajax'
include SessionHelpers
include WaitForAjax

describe "Logged-in sidebar", js: true do
	let(:user) { create(:user) }
  before(:each) { spec_login(user) }
    
  describe "Start timelog button" do
    it "initially displays" do
      expect(find('#start-timelog')).not_to have_css('.hidden')
    end

    describe "On click" do
      before(:each) do 
        click_link("Start Timelog")
      end

      it "creates a cancel link" do
        expect(page).to have_content("CANCEL TIMELOG")
    	end

      it "creates a end timelog link" do
        expect(page).to have_content("FINISH TIMELOG")
      end

      it "displays the timelog timer" do
        expect(find('#timelog-timer')).to be_visible
      end

      it "becomes invisible" do
        expect(page).not_to have_content("START TIMELOG")
      end
    end
  end

  describe "Finish timelog button" do
    it "does not initially display" do
      expect(page).not_to have_content("FINISH TIMELOG")
    end

    it "displays after user clicks start timelog button" do
      click_link("Start Timelog")
      expect(page).to have_content("FINISH TIMELOG")
    end

    describe "On click" do
      before(:each) do
        click_link("Start Timelog")
        click_link("end-timelog")
      end

      before(:each) do |spec|
        wait_for_ajax unless spec.metadata[:skip_wait]
      end

      it "becomes invisible" do
        expect(page).not_to have_content("FINISH TIMELOG")
      end

      it "makes cancel timelog button invisible" do
        expect(page).not_to have_content("CANCEL TIMELOG")
      end

      it "makes the timer invisible" do
        expect(find("#timelog-timer", visible: false)).not_to be_visible
      end

      it "displays start timelog button" do
        expect(page).to have_content("START TIMELOG")
      end

      it "does not hide Create New Timelog button" do
        expect(page).to have_content("CREATE NEW TIMELOG")
      end
    end
  end

  describe "Cancel Timelog button" do
    it "does not display initially" do
      expect(page).not_to have_content("CANCEL TIMELOG")
    end

    it "displays when timelog timer is active" do
      click_link("Start Timelog")
      expect(page).to have_content("CANCEL TIMELOG")
    end

    describe "On click" do
      before(:each) do 
        click_link "Start Timelog"
        click_link "Cancel Timelog"
      end

      it "hides finish timelog button" do
        expect(page).not_to have_content("FINISH TIMELOG")
      end

      it "hides timelog timer" do
        expect(find('#timelog-timer', visible: false)).not_to be_visible
      end

      it "displays start timelog button" do
        expect(find(:css, '#start-timelog')).to be_visible
      end
    end
  end

	describe "Create New Timelog button" do
	  it "displays initially" do
      expect(page).to have_content("CREATE NEW TIMELOG")
	  end

	  it "redirects to form for new Timelog when clicked", js: false do
	  	click_link("Create New Timelog")
	  	expect(page.title).to have_content(/New Timelog/)
	  end

    it "does not hide finish timelog button if clicked while timer is active" do
      click_link("Start Timelog")
      click_link("Create New Timelog")
      expect(page).to have_content("FINISH TIMELOG")
    end
	end

  describe "Current time clock" do
  	it "displays the current time" do
      expect(page).to have_css("#current-time")
  	end

  	it "changes every second" do
  		time_1 = page.find('#current-time').text
  		sleep 2
  		expect(page.find('#current-time').text).not_to eq(time_1)
  	end

    it "displays on subsequent page loads" do
      click_link("Home")
      expect(page.find(:css, "#current-time")).to be_visible
    end
  end

  describe "Timelog timer" do
    it "does not display intially" do
      expect(find("#timelog-timer", visible: false)).not_to be_visible
    end

    it "displays after start timelog button has been clicked" do
      click_link("Start Timelog")
      expect(find("#timelog-timer")).to be_visible
    end

    it "changes every second" do
      click_link("Start Timelog")
      timelog_timer_text_1 = find("#timelog-timer").text
      sleep 2
      expect(find("#timelog-timer").text).not_to eq(timelog_timer_text_1)
    end
  end
end