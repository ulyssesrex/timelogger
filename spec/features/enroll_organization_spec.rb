require 'rails_helper'

feature "Enrolling organization" do
  
  def enroll_organization_steps
    visit root_path
    click_link 'Enroll organization'
    # Redirects to :new
    fill_in("organization_name", with: "TimeloggerTest")
    fill_in("organization_description", with: "Just a test.")
    fill_in("organization_password", with: "foobar")
    fill_in("organization_password_confirmation", with: "foobar")
    fill_in("organization_users_attributes_0_first_name", with: "Admin")
    fill_in("organization_users_attributes_0_last_name", with: "McAdmin")
    fill_in("organization_users_attributes_0_position", with: "Tester")
    fill_in("organization_users_attributes_0_email", with: "example@test.com")
    fill_in("organization_users_attributes_0_password", with: "password")
    fill_in("organization_users_attributes_0_password_confirmation", with: "password")
    click_button "Enroll"
  end
  
  def incorrect_enroll_organization_steps
    visit root_path
    click_link 'Enroll organization'
    click_button "Enroll"
  end
  
  def cancel_enroll_organization
    visit root_path
    click_link 'Enroll organization'
    click_link "Cancel"
  end
  
  feature "Enrolling with correct credentials" do
    it "creates an organization" do
      expect { 
        enroll_organization_steps 
      }.to change(Organization, :count).by(1)
    end
    
    it "creates a user" do
      expect {
        enroll_organization_steps
      }.to change(User, :count).by(1)
    end
    
    it "creates an admin user" do
      enroll_organization_steps
      expect(User.last.admin?).to be true
    end
    
    it "sends an email to the admin user" do
      expect {
        enroll_organization_steps
      }.to change {
        ActionMailer::Base.deliveries.count
      }.by(1)
    end

    it "redirects to the root url" do
      enroll_organization_steps
      expect(current_path).to eq root_path  
    end
    
    it "displays a flash success message" do
      enroll_organization_steps
      expect(page.find('.alert')).to have_content(/was created/)
    end
  end
  
  feature "Enrolling with incorrect credentials" do
    it "does not create an organization" do
      expect { 
        incorrect_enroll_organization_steps
      }.not_to change(Organization, :count)
    end
    
    it "does not create an admin user" do
      expect {
        incorrect_enroll_organization_steps
      }.not_to change(User, :count)
    end
    
    it "re-displays the organization creation form" do
      incorrect_enroll_organization_steps
      expect(page).to have_title("Enroll organization")
    end
  end
  
  feature "Cancel enroll form" do
    it "redirects to root" do
      cancel_enroll_organization
      expect(page.title).to match("Timelogger")
    end
  end
end