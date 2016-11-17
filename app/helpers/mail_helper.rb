module MailHelper
  def account_activations_url(user, organization, token)
	domain = "http://localhost:3000/"
    controller = "account_activations?"
    id = "id=" + user.activation_token
    email = "&email=" + user.email
    organization_name = "&organization_name=" + organization.name
    organization_token = "&organization_token=" + token

    account_activations_url = "#{domain}#{controller}#{id}#{email}#{organization_name}#{organization_token}"
  end

  def user_activations_url(user, organization)
    domain = "http://localhost:3000/"
    controller = "account_activations?"
    id = "id=" + user.activation_token
    email = "&email=" + user.email
    organization_name = "&organization_name=" + organization.name
    organization_token = "&organization_token=" + token

    user_activations_url = "#{domain}#{controller}#{id}#{email}#{organization_name}#{organization_token}"
  end
end