require 'rails_helper'

feature "Home page", logins: :available do
  let(:user_info) { page.find('#user-info-blurb') }
  
  feature "User info blurb" do
    before(:each) { general_login }    
    it { expect(user_info).to have_css("img[src*='gravatar']") }
    it { expect(user_info).to have_link("Van User, User") }
    it { expect(user_info).to have_content(/Worker/) }
    it { expect(user_info).to have_content(/Organization/) }
  end
  
  feature "Admin info blurb" do
    before(:each) do
      admin_login 
      click_link 'Home'
    end
    
    it { expect(user_info).to have_content(/Admin/) }
  end
  
  feature "Grants graph" do
    # test for grants graph javascript
  end
  
  feature "Timelogs menu" do
    # test for timelog feed selectors
    # test for timelog feed
  end  
end