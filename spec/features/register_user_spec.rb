require 'rails_helper'

feature "Register user" do
  let(:organization) { create(:organization) }
  before(:each)      { organization }
  
  def correct_user_registration
    visit root_path
    click_link 'Sign up'
    fill_in("user_first_name", with: "User")
    fill_in("user_last_name", with: "Van User")
    fill_in("user_position", with: "User")
    fill_in("user_email", with: "example@test.com")
    fill_in("user_password", with: "password")
    fill_in("user_password_confirmation", with: "password")
    select(organization.name, from: 'user_organization_id')
    fill_in("user_organization_password", with: "password")
    click_button 'Sign up'
  end
  
  def incorrect_user_registration
    visit root_path
    click_link 'Sign up'
    click_button 'Sign up'
  end
  
  def cancel_user_registration
    visit signup_path
    click_link "Cancel"
  end
  
  def activate_user
    correct_user_registration
    open_email("example@test.com")
    current_email.click_link "Activate Timelogger account"
  end
  
  feature "User registers with correct credentials" do    
    it "sends an email to the user" do
      expect {
        correct_user_registration
      }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
    end
    
    it "redirects to the root url" do
      correct_user_registration
      expect(page).to have_content(/Timelogger/)
    end
  end
  
  feature "User attempts to register with incorrect credentials" do
    it "re-displays the user registration form" do
      incorrect_user_registration
      expect(page.title).to have_content(/Sign up/)
    end
  end
  
  feature "User cancels registration form" do
    it "redirects to the root url" do
      cancel_user_registration
      expect(page).to have_content(/Timelogger/)
    end
  end
  
  feature "User activates account" do
    before(:each) { activate_user }
    
    it "displays the logged-in home page" do
      expect(page.title).to have_content(/Home/)
    end
    
    it "displays a logged-in navigation bar" do
      expect(page).to have_content(/Log out/)
    end
  end
  
  feature "Admin activates account", logins: :available do
    before(:each) { admin_signup }
    
    it "redirects to the help page" do
      expect(page.title).to have_content(/Admin help/)
    end
  end  
end