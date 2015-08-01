require 'rails_helper'

describe SessionsController do 
  let(:user) { create(:user, :with_remembering) }
  
  def create_session(current_user)
    post :create, session: { 
                    email: current_user.email, 
                    password:    'password', 
                    remember_me: '0' 
                  }
  end
  
  describe 'filters' do
          
    describe 'find_user' do      
      before(:each) { create_session(user) }
      
      it 'finds a user based on the email param' do
        expect(assigns(:user).email).to eq(user.email)
      end
      
      it 'creates an instance of class User' do
        expect(assigns(:user)).to be_an_instance_of(User)
      end
    end
    
    describe 'valid_user' do
      it "validates users by email and password" do
        create_session(user)
        expect(response).not_to render_template(:new)
      end
        
      context "invalid user" do        
        def create_session_badly
          post :create, session: { 
                          email: 'invalid', 
                          password: 'password', 
                          remember_me: '0' 
                        }
        end
        
        before(:each) { create_session_badly }
        
        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end        
        
        it "re-renders the :new template" do
          expect(response).to render_template(:new)
        end
      end

    end

    describe 'activated_user' do
      context "user is not activated" do
        let(:non_activated_user) { create(:user, activated: false) }        
        before(:each) { create_session(non_activated_user) }
        
        it "displays a warning flash message" do
          expect(flash[:warning]).to be_present
        end
        
        it "redirects to the root url" do
          expect(response).to redirect_to(root_url)
        end
      end
      
      context "user is activated" do
        it "passes the filter successfully" do
          create_session(user)
          expect(response).to redirect_to(root_url)
        end
      end
    end
  end
  
  describe 'actions' do
    describe 'GET #new' do
      it "renders the :new template" do
        get :new
        expect(response).to render_template(:new)
      end
    end
    
    describe 'POST #create' do      
      it "logs in the user" do
        create_session(user)
        expect(session[:user_id]).to eq(user.id)
      end
      
      context "remember me is checked" do
        it "remembers the user" do
          post :create, session: { 
                          email: user.email, 
                          password: 'password', 
                          remember_me: '1' 
                        }
          expect(cookies[:remember_token]).not_to be_nil
        end          
      end
      
      context "remember me is not checked" do
        
        it "forgets the user" do
          create_session(user)
          expect(user.remember_digest).to be_nil
        end
      end
      
      context "with friendly forwarding" do
        it "deletes the forwarding url in the session hash" do
          session[:forwarding_url] = users_url
          expect { create_session(user) }.to change { session[:forwarding_url] }.to nil
        end
        
        context "there is a forwarding url" do          
          before(:example) { session[:forwarding_url] = users_url }
          it "redirects to forwarding url" do 
            expect(create_session(user)).to redirect_to(users_url)
          end
        end
        
        context "there is no forwarding url" do
          it "redirects to default url" do
            expect(create_session(user)).to redirect_to(root_url)
          end
        end
      end     
    end
    
    describe 'DELETE #destroy' do
      
      before(:each) do
        create_session(user) 
        delete :destroy
      end
      
      it "logs the user out if they're logged in" do
        expect(session[:user_id]).to be_nil
      end
      
      it "redirects to the root url" do
        expect(response).to redirect_to(root_url)
      end    
    end
  end
end