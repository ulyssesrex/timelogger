require 'rails_helper'

describe PasswordResetsController do
  let(:user) { create(:user_with_reset) }
  
  describe 'filters' do               
    describe '#valid_user' do     
      it "does not redirect a valid user" do
        get :edit, id: user.reset_token, email: user.email
        expect(response).not_to redirect_to(root_url)
      end
      
      it "redirects an invalid user" do
        get :edit, id: user.reset_token, email: 'invalid'
        expect(response).to redirect_to(root_url)
      end
    end
    
    describe '#check_expiration' do      
      context 'expired password_reset' do
        let(:expired_reset_user) do 
          user.update_attribute(:reset_sent_at, 2.hours.ago)
          user.save; user
        end
        
        def get_expired_reset
          get :edit, 
              id:    expired_reset_user.reset_token, 
              email: expired_reset_user.email
        end
                                 
        it "displays a danger flash" do      
          get_expired_reset    
          expect(flash[:danger]).to be_present
        end
        
        it "redirects to the new_password_reset_url" do
          get_expired_reset
          expect(response).to redirect_to(new_password_reset_url)
        end
      end
      
      context 'non-expired password_reset' do        
        it "does not redirect a non-expired password reset" do
          get :edit, id: user.reset_token, email: user.email
          expect(response).not_to redirect_to(root_url)
        end          
      end
    end
  end
  
  describe 'public instance methods' do
    describe 'GET #new' do
      it 'renders the :new template' do
        get :new
        expect(response).to render_template :new
      end
    end
    
    describe 'POST #create' do       
      let(:create_password_reset) do
        post :create, password_reset: { email: user.email }
      end
      
      it "creates an instance of user" do
        create_password_reset
        expect(assigns(:user)).to be_an_instance_of(User)
      end
      
      context "valid user instance" do
        it "creates a new reset digest for the user" do
          expect do
            create_password_reset 
            user.reload
          end.to change { user.reset_digest }
        end
        
        it "sends a password reset email to the user's email" do
          expect { create_password_reset }.to change {
            ActionMailer::Base.deliveries.size
          }.by(1)
        end
        
        it "displays an info flash" do
          create_password_reset
          expect(flash[:info]).to be_present
        end
        
        it "redirects to the root_url" do
          create_password_reset
          expect(response).to redirect_to(root_url)
        end
      end
      
      context "invalid user instance" do
        let(:invalid_password_reset) do
          post :create, password_reset: { email: 'invalid@wrong.com' }
        end
                
        it "displays a danger flash" do
          invalid_password_reset
          expect(flash[:danger]).to be_present
        end  
        
        it "renders the :new template" do
          invalid_password_reset
          expect(response).to render_template :new
        end
      end
    end
    
    describe 'GET #edit' do
      it 'renders the :edit template' do
        get :edit, id: user.reset_token, email: user.email
        expect(response).to render_template(:edit)
      end
    end
    
    describe 'POST #update' do
      context "password is blank" do
        
        def user_submits_blank_password
          post :update, 
               id:    user.reset_token, 
               email: user.email, 
               user: { 
                 password: '', 
                 password_confirmation: 'password' 
               }
        end
                
        it "displays a danger flash" do
          user_submits_blank_password
          expect(flash[:danger]).to be_present
        end
        
        it "re-renders the :edit template" do
          user_submits_blank_password
          expect(response).to render_template(:edit)
        end
      end
      
      context "successfully updates password" do
        
        def update_password_reset
          post :update, 
               id: user.reset_token, 
               email: user.email, 
               user: { 
                 password: 'new_password', 
                 password_confirmation: 'new_password' 
               }
        end
                
        it "updates user's password" do
          expect do
            update_password_reset
            user.reload
          end.to change { user.password_digest }
        end
                
        it "logs in the user" do
          update_password_reset
          expect(session[:user_id]).not_to be_nil
        end
        
        it "displays a success flash" do
          update_password_reset
          expect(flash[:success]).to be_present
        end
        
        it "redirects to the user page" do
          update_password_reset
          expect(response).to redirect_to(user_path(user))
        end
      end
      
      context "other error" do
        it "re-renders the :edit template" do
          post :update, 
               id: user.reset_token, 
               email: user.email, 
               user: { 
                 # Password is too short, raises error.
                 password: 'error', 
                 password_confirmation: 'error'
               }
          expect(response).to render_template(:edit)
        end
      end
    end    
  end  
end
