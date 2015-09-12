require 'rails_helper'

describe AccountActivationsController do
  let(:organization) { create(:organization) }
  let(:user)  { create(:user, activated: false) }
  let(:admin) { create(:user, activated: false, admin: true) }
  
  before(:each) { organization }
  
  describe 'GET #edit' do
    it 'activates the user' do
      get :edit, id: user.activation_token, email: user.email
      user.reload # because database is directly changed
      expect(user.activated?).to be(true)
    end
    
    it 'logs in the user' do
      get :edit, id: user.activation_token, email: user.email
      expect(session[:user_id]).to eq(user.id)
    end
    
    it 'displays a danger flash if user does not exist' do
      get :edit, id: user.activation_token, email: nil
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a danger flash if user is already activated' do
      user.update_attribute(:activated, true)
      get :edit, id: user.activation_token, email: user.email
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a danger flash if user cannot be authenticated' do
      get :edit, id: User.new_token, email: user.email
      expect(flash[:danger]).to be_present
    end
    
    it 'displays a success flash for successful activations' do
      get :edit, id: user.activation_token, email: user.email
      expect(flash[:success]).to be_present
    end

    it 'redirects to help page on success if user is admin' do
      get :edit, id: admin.activation_token, email: admin.email
      expect(response).to redirect_to(admin_help_path)
    end
    
    it 'redirects users to their home page on success' do
      get :edit, id: user.activation_token, email: user.email
      expect(response).to redirect_to(user_path(user))
    end

    it 'redirects to root on failure' do
      get :edit, id: user.activation_token, email: "invalid@wrong.com"
      expect(response).to redirect_to(root_path)
    end
  end
end