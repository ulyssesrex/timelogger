require 'rails_helper'
require 'support/session_helpers'
include SessionHelpers

describe "Logged-in sidebar"do
	let(:user) { create(:user) }
  before(:each) { spec_login(user) }
    
  describe "Start timelog button" do
    it "initially displays", js: true do
      expect(find('#start-timelog')).not_to have_css('.hidden')
    end

    describe "On click" do
      before(:each) { click_link("Start Timelog") }

      it "creates a cancel link", js: true do
    		using_wait_time 10 do
          expect(page.to have_content("Cancel Timelog"))
        end
        #expect(find('#cancel-timelog')).not_to have_css('.hidden')
    	end

      it "creates a finish timelog link", js: true do
        using_wait_time 10 do
          expect(page.to have_content("Finish Timelog"))
        end
        #expect(find('#finish-timelog')).not_to have_css('.hidden')
      end

      it "displays the timelog timer", js: true do
        using_wait_time 10 do
          expect(find("Cancel Timelog").to be_present)
        end
        #expect(find('#timelog-timer')).not_to have_css('.hidden')
      end

      it "becomes invisible", js: true do
        using_wait_time 10 do
          expect(page.not_to have_content("Start Timelog"))
        end
        #expect(find('#start-timelog')).to have_css('.hidden', :visible => false)
      end
    end
  end

  describe "Finish timelog button" do
    it "does not initially display", js: true do
      using_wait_time 10 do
          expect(page.not_to have_content("Finish Timelog"))
        end
      #expect(find('#finish-timelog')).to have_css('.hidden', :visible => false)
    end

    it "displays after user clicks start timelog button", js: true do
      click_link("Start Timelog")
      using_wait_time 10 do
          expect(page.to have_content("Finish Timelog"))
        end
      #expect(find('#finish-timelog')).not_to have_css('.hidden')
    end

    describe "On click" do
      before(:each)  do
        click_link("Start Timelog")
        click_link("Finish Timelog")
      end

      it "redirects to new timelog form", js: true do
        using_wait_time 10 do
          expect(page.title.to have_content("New"))
        end
        #expect(page.title).to have_content(/New Timelog/)
      end

      it "becomes invisible", js: true do
        using_wait_time 10 do
          expect(page.not_to have_content("Finish Timelog"))
        end
        #expect(find('#finish-timelog')).to have_css('.hidden', :visible => false)
      end

      it "makes cancel timelog button invisible", js: true do
        using_wait_time 10 do
          expect(page.not_to have_content("Cancel Timelog"))
        end
        #expect(find('#cancel-timelog')).to have_css('.hidden', :visible => false)
      end

      it "makes the timer invisible", js: true do
        using_wait_time 10 do
          expect(page.not_to have_css("#timelog-timer"))
        end
        #expect(find('#timelog-timer')).to have_css('.hidden', :visible => false)
      end

      it "displays start timelog button", js: true do
        using_wait_time 10 do
          expect(page.to have_content("Start Timelog"))
        end
        #expect(find('#start-timelog')).not_to have_css('.hidden')
      end

      it "does not hide timelog from scratch button", js: true do
        using_wait_time 10 do
          expect(page.to have_content("Timelog from scratch"))
        end
        #expect(find('Timelog from scratch')).not_to have_css('.hidden')
      end

      it "prefills new timelog start time field"
      it "prefills new timelog end time field"
    end
  end

  describe "Cancel Timelog button" do
    it "does not display initially", js: true do
      using_wait_time 10 do
        expect(page.not_to have_content("Cancel Timelog"))
      end
      #expect(find('#cancel-timelog')).to have_css('.hidden', :visible => false)
    end

    it "displays when timelog timer is active", js: true do
      click_link("Start Timelog")
      using_wait_time 10 do
        expect(page.to have_content("Cancel Timelog"))
      end
      #expect(find('#cancel-timelog')).not_to have_css('.hidden')
    end

    describe "On click" do
      it "redirects to the logged in home page"
      it "hides finish timelog button"
      it "hides timelog timer"
      it "displays start timelog button"
    end
  end

	describe "Timelog from scratch button" do
	  it "displays initially" do
	  	using_wait_time 10 do
        expect(page.to have_content("Timelog from scratch"))
      end
      #expect(find('Timelog from scratch')).not_to have_css('.hidden')
	  end

	  it "redirects to form for new Timelog when clicked" do
	  	click_link("Timelog from scratch")
	  	expect(page.title).to have_content(/New Timelog/)
	  end

    it "does not hide finish timelog button if clicked while timer is active", js: true do
      click_link("Timelog from scratch")
      using_wait_time 10 do
        expect(page.to have_content("Finish Timelog"))
      end
      #expect(find('#finish-timelog')).not_to have_css('.hidden')
    end
	end

  describe "Current time clock" do
  	it "displays the current time", js: true do
  		using_wait_time 10 do
        expect(page.to have_css("#current-time"))
      end
      #expect(find('#current-time')).not_to have_css('.hidden')
  	end

  	it "changes every second", js: true do
  		time_1 = page.find('#current-time').text
  		sleep 2
  		expect(page.find('#current-time').text).not_to eq(time_1)
  	end

    it "displays on subsequent page loads", js: true do
      click_link("Home")
      using_wait_time 10 do
        expect(page.to have_css("#current-time"))
      end
    end
  end

  describe "Timelog timer" do
    it "does not display intially"
    it "displays after start timelog button has been clicked"
    it "changes every second"
  end
end