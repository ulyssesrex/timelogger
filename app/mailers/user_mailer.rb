class UserMailer < ApplicationMailer
  # TODO: password reset mailers.

  def account_activation(user)
    @user = user
    @greeting = "Hello #{full_name(@user, last_first=false)},"    
    mail to: @user.email, subject: "Activate your Timelogger account"
  end

  def password_reset(user)
    @user = user
    @greeting = "Hello #{@user.first_name},"
    mail to: @user.email, subject: "Reset your Timelogger password"
  end
  
  def organization_activation(organization, admin)
    @organization = organization
    @admin        = admin
    @greeting = "Hello #{full_name(@admin, last_first=false)},"
    mail to: @admin.email, subject: "Activate #{@organization.name}'s Timelogger account"
  end

  def keyword_reset(organization, admin)
    @admin = admin
    @organization = organization
    @greeting = "Hello #{@admin.first_name},"
    mail to: @admin.email, subject: "Reset #{@organization.name}'s keyword"
  end
end
