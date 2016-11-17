require 'rails_helper'

describe AccountActivationsController do
  let(:organization) { create(:organization) }
  let(:user)  { create(:user, activated: false) }
  let(:admin) { create(:user, activated: false, admin: true) }
  
  describe 'GET #edit' do

    def edit_account_activation
      params = { 
          id: user.activation_token, 
          email: user.email, 
          organization_name: organization.name, 
          organization_token: organization.activation_token
        } 
      get :edit, params
    end

    before(:each) do |spec|
      unless spec.metadata[:skip_edit]
        organization
        user
        edit_account_activation
      end
    end

    it 'finds the correct organization from the email link' do
      expect(assigns(:organization).name).to eq(organization.name)
    end

    it 'finds the correct user within the organization' do
      expect(assigns(:user).email).to eq(user.email)
    end

    it 'can authenticate organization from activation_token param' do
      expect(organization.authenticated?(:activation, organization.activation_token)).to be(true)
    end

    it 'activates the user' do      
      user.reload # because database is directly changed
      expect(user.activated?).to be(true)
    end
    
    it 'logs in the user' do
      #get :edit, id: user.activation_token, email: user.email
      expect(session[:user_id]).to eq(user.id)
    end
    
    it 'displays a danger flash if user does not exist', :skip_edit do
      params = { 
          id: user.activation_token, 
          email: nil, 
          organization_name: organization.name, 
          organization_token: organization.activation_token
        }  
      get :edit, params     
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a danger flash if user is already activated', :skip_edit do
      user.update_attribute(:activated, true)
      edit_account_activation
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a danger flash if user cannot be authenticated', :skip_edit do
      params = { 
        id: User.new_token, 
        email: user.email, 
        organization_name: organization.name, 
        organization_token: organization.activation_token
      } 
      get :edit, params
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a success flash for successful activations' do
      expect(flash[:success]).to be_present #success
    end

    it 'redirects to help page on success if user is admin', :skip_edit do
      params = { 
        id: admin.activation_token, 
        email: admin.email, 
        organization_name: organization.name, 
        organization_token: organization.activation_token
      } 
      get :edit, params      
      expect(response).to redirect_to(admin_help_path)
    end
    
    it 'redirects users to their home page on success' do
      expect(response).to redirect_to(user_path(user))
    end

    it 'redirects to root on failure' do
      params = { 
          id: user.activation_token, 
          email: "invalid@wrong.com", 
          organization: organization.name, 
          organization_token: organization.activation_token
        } 
      get :edit, params
      expect(response).to redirect_to(root_path)
    end
  end
end