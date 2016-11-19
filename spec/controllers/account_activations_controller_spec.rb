require 'rails_helper'

describe AccountActivationsController do
  let(:organization) { create(:organization) }
  let(:user)  { create(:user, activated: false) }
  let(:admin) { create(:user, activated: false, admin: true) }
  
  describe 'GET #edit_organization' do

    def edit_organization
      params = {
        id: admin.activation_token, 
        email: admin.email, 
        organization_name: organization.name, 
        organization_token: organization.activation_token
      }
      get :edit_organization, params: params
    end

    before(:each) do |spec|
      edit_organization unless spec.metadata[:skip_edit]
    end

    it 'finds the correct organization from the email link' do
      expect(assigns(:organization).name).to eq(organization.name)
    end

    it 'finds the correct user within the organization' do
      expect(assigns(:admin).email).to eq(admin.email)
    end

    it 'can authenticate organization from activation_token param' do
      expect(organization.authenticated?(:activation, organization.activation_token)).to be(true)
    end

    it 'activates the user' do      
      admin.reload # because database is directly changed
      expect(admin.activated?).to be(true)
    end
    
    it 'logs in the user' do
      expect(session[:user_id]).to eq(admin.id)
    end
    
    it 'displays a danger flash if user does not exist', :skip_edit do
      params = { 
          id: admin.activation_token, 
          email: nil, 
          organization_name: organization.name, 
          organization_token: organization.activation_token
        }  
      get :edit_organization, params: params     
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a danger flash if user is already activated', :skip_edit do
      admin.update_attribute(:activated, true)
      edit_organization
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a danger flash if user cannot be authenticated', :skip_edit do
      params = { 
        id: User.new_token, 
        email: admin.email, 
        organization_name: organization.name, 
        organization_token: organization.activation_token
      } 
      get :edit_organization, params: params
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a success flash for successful activations' do
      expect(flash[:success]).to be_present
    end

    it 'redirects to help page on success' do
      expect(response).to redirect_to(admin_help_path)
    end

    it 'redirects to root on failure' do
      params = { 
          id: admin.activation_token, 
          email: "invalid@wrong.com", 
          organization: organization.name, 
          organization_token: organization.activation_token
        } 
      get :edit_organization, params: params
      expect(response).to redirect_to(root_path)
    end

    it 'redirects to admin help page on success' do
      expect(response).to redirect_to(admin_help_path)
    end
  end

  describe 'GET #edit_user' do
    let(:default_params) do 
      {
        id: user.activation_token, 
        user_id: user.id, 
        organization_id: organization.id 
      }
    end

    let(:non_existent_user_params) do
      {
        id: user.activation_token, 
        user_id: nil, 
        organization_id: organization.id 
      }
    end

    let(:already_activated_user_params) do
      {
        id: user.activation_token,
        user_id: user.id,
        organization_id: organization.id
      }
    end

    let(:unidentified_user_params) do 
      {
        id: User.new_token, 
        user_id: user.id, 
        organization_id: organization.id 
      }
    end

    def edit_user(params)
      get :edit_user, params: params
    end

    it 'finds the correct organization from organization_id param' do
      edit_user(default_params)
      expect(assigns(:organization).id).to eq(organization.id)
    end

    it 'finds a user under the correct organization' do
      edit_user(default_params)
      expect(assigns(:user).organization.id).to eq(organization.id)
    end

    it 'exits the activation process to root_path if user does not exist' do
      edit_user(non_existent_user_params)
      expect(response).to redirect_to(root_path)
    end

    it 'displays a danger flash if user does not exist' do
      edit_user(non_existent_user_params)
      expect(flash[:danger]).to be_present
    end

    it 'exits the activation process to root_path if user is already activated' do
      user.update_attribute(:activated, true)
      edit_user(default_params)
      expect(response).to redirect_to(root_path)
    end

    it 'displays a danger flash if user is already activated' do
      user.update_attribute(:activated, true)
      edit_user(default_params)
      expect(flash[:danger]).to be_present
    end

    it 'exits the activation process to root_path if user cannot be authenticated' do
      edit_user(unidentified_user_params)
      expect(response).to redirect_to(root_path)
    end

    it 'displays a danger flash if user cannot be authenticated' do
      edit_user(unidentified_user_params)
      expect(flash[:danger]).to be_present
    end

    it 'activates the user' do
      edit_user(default_params)
      expect(assigns(:user).activated).to be(true)
    end

    it 'logs in the user' do
      edit_user(default_params)
      expect(session[:user_id]).to eq(user.id)
    end

    it 'displays a success flash' do
      edit_user(default_params)
      expect(flash[:success]).to be_present
    end

    it 'redirects users to their home page on success' do
      edit_user(default_params)
      expect(response).to redirect_to(user_path(user))
    end
  end    
end