module SessionHelpers
  def general_signup
    create(:organization)
    visit root_path
    click_link 'Sign up'
    fill_in("user_first_name", with: "User")
    fill_in("user_last_name", with: "Van User")
    fill_in("user_position", with: "Worker")
    fill_in("user_email", with: "example@test.com")
    fill_in("user_password", with: "password")
    fill_in("user_password_confirmation", with: "password")
    select(Organization.first.name, from: 'user_organization_id')
    fill_in("user_organization_password", with: "password")
    click_button 'Sign up'
    open_email("example@test.com")
    #puts current_email.body
    current_email.click_link "Activate your Timelogger account here"
  end
  
  def admin_signup
    visit root_path
    click_link 'Enroll organization'
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
    open_email("example@test.com")
    current_email.click_link "Click here to activate your Timelogger account and log in."
  end

  def spec_login(registered_user)
    create(:organization)
    visit root_path
    click_link 'Log in'
    fill_in("session_email", with: "#{registered_user.email}")
    fill_in("session_password", with: "password")
    click_button "Log in"
  end
end