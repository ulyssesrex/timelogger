require 'rails_helper'

feature "Home page", logins: :available do
  let(:user_info) { page.find('#user-info-blurb') }
  
  feature "User info blurb" do
    before(:each) { general_signup }    
    it { expect(user_info).to have_css("img[src*='gravatar']") }
    it { expect(user_info).to have_link("Van User, User") }
    it { expect(user_info).to have_content(/Worker/) }
    it { expect(user_info).to have_content(/Organization/) }
  end
  
  feature "Admin info blurb" do
    before(:each) do
      admin_signup 
      click_link 'Home'
    end
    
    it { expect(user_info).to have_content(/Admin/) }
  end
  
  feature "Grants table" do
    # TODO: test for grants table javascript
  end
  
  feature "Timelogs menu" do
    # TODO: test for timelog feed selectors
    # TODO: test for timelog feed
  end  
end