class UserMailer < ApplicationMailer
  helper :mail
  # TODO: password reset mailers.

  def account_activation(user, organization)
    @user = user
    @organization = @user.organization
    #@organization.activation_token ||= Organization.new_token
    @greeting = "Hello #{full_name(@user, last_first=false)},"    
    mail to: @user.email, subject: "Activate your Timelogger account"
  end

  def password_reset(user)
    @user = user
    @user.reset_token ||= User.new_token
    @greeting = "Hello #{@user.first_name},"
    mail to: @user.email, subject: "Reset your Timelogger password"
  end
  
  def organization_activation(organization, admin, token)
    @organization = organization
    @admin = admin
    @organization_token = token
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
