require 'rails_helper'

feature "Home page", logins: :available do  

  feature "User info blurb" do
    let(:user_info) { page.find('#user-blurb') }
    before(:each) { general_signup }   
    #it { puts page.html } 
    it { expect(user_info).to have_css("img[src*='gravatar']") }
    it { expect(user_info).to have_content(/Van User/) }
    it { expect(user_info).to have_content(/Worker/) }
    it { expect(user_info).to have_content(/Organization/) }
  end
  
  feature "Admin info blurb" do
    before(:each) do
      admin_signup 
    end
    
    it { puts page.text }
  end
  
  feature "Grants table" do
    # TODO: test for grants table javascript
  end
  
  feature "Timelogs menu" do
    # TODO: test for timelog feed selectors
    # TODO: test for timelog feed
  end  
end