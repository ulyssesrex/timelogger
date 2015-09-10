require 'rails_helper'

describe UsersController do  
  let(:user)   { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin)  { create(:user, admin: true) }
  let(:non)    { create(:user, activated: false, activated_at: nil, activation_digest: nil) }
  let(:organization) { create(:organization) }

  before(:each) { organization }

  describe 'filters' do  
    before(:each) do |spec| 
      unless spec.metadata[:skip_login]
        user 
        log_in user
      end
    end
    
    describe '#find_user_by_id' do      
      it "finds the correct user by id" do
        get :show, id: user.id
        expect(assigns(:user).id).to eq(user.id)
      end
    end
     
    describe '#find_activated' do
      before(:each) do
        non
        get :index
      end
      
      it "assigns all activated Users to @users" do
        # Expecting site admin and user.
        expect(assigns(:users).count).to eq(2)
      end
    end
    
    describe '#logged_in' do      
      context "user is not logged in" do        
        before(:each) do
          log_out
          get :show, id: user.id
        end
                
        it 'stores the url of the attempted GET request' do
          expect(session[:forwarding_url]).to eq(request.url)
        end

        it "does not store request's url unless it is a GET" do
          session[:forwarding_url] = nil
          post :update, id: user.id, user: { first_name: 'Whippy' }
          expect(session[:forwarding_url]).to be_nil
        end
        
        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end              
          
        it 'redirects to login page' do
          expect(response).to redirect_to(login_path)
        end
      end
    end
    
    describe '#is_supervisor_or_user_or_admin' do      
      let(:supervisee) { create(:user, :supervisee) }
      let(:supervisor) { supervisee.supervisors.last }
      let(:some_guy)   { create(:user, admin: false) }
      
      before(:each) { supervisee; supervisor }
            
      it "passes when current user is user's supervisor" do 
        log_in supervisor
        get :show, id: supervisee.id
        expect(response).to render_template(:show)
      end

      it "passes when current user is user" do
        log_in supervisee
        get :show, id: supervisee.id
        expect(response).to render_template(:show)
      end
      
      it "passes when current user is admin" do
        log_in admin
        get :show, id: supervisor.id
        expect(response).to render_template(:show)
      end

      it "doesn't pass when current user 
      is not user, supervisor, or admin" do
        some_guy
        log_in some_guy
        get :show, id: supervisee.id
        expect(response).to redirect_to(user_path(some_guy))
      end    
    end
    
    describe '#is_user_or_admin' do      
      it "passes when current user is user" do
        log_in user
        get :edit, id: user.id
        expect(response).to render_template(:edit)
      end
      
      it "passes when current user is admin" do
        log_in admin
        get :edit, id: user.id
        expect(response).to render_template(:edit)
      end

      it "doesn't pass when current user is neither user nor admin" do
        log_in other_user
        get :edit, id: user.id
        expect(response).to redirect_to(user_path(other_user))
      end
    end
    
    describe '#admin' do
      it "passes when current user is admin" do
        log_in admin
        get :delete_other_user_index
        expect(response).to render_template(:delete_other_user_index)
      end
      
      it "doesn't pass when current user is not admin" do
        log_in user
        get :delete_other_user_index
        expect(response).to redirect_to(user_path(user))
      end
    end
  end
  
  describe 'actions' do
    describe "GET #new" do      
      before(:each) { get :new }
    
      it "creates an instance of User" do
        expect(assigns(:user)).to be_an_instance_of(User)
      end
    
      it "renders the :new template" do
        expect(response).to render_template :new
      end
    end
  
    describe "POST #create" do
      let(:organization)        { create(:organization) }        
      let(:new_user_attributes) { attributes_for(:user, :new) }
        
      def create_user
        post :create, { user: new_user_attributes }
      end
          
      before(:each) do |spec|
        unless spec.metadata[:skip_create]
          create_user
        end
      end
      
      it "creates an instance of User" do
        expect(assigns(:user)).to be_an_instance_of(User)
      end
    
      context "successful user creation" do        
        it "saves a new user record", :skip_create do
          expect { create_user }.to change(User, :count).by(1)
        end
      
        it "delivers an email to the correct user", :skip_create do      
          expect { create_user }
          .to change(ActionMailer::Base.deliveries, :count)
          .by(1)
        end
      
        it "displays an info flash" do   
          expect(flash[:info]).to be_present
        end
      
        it "redirects to root" do
          expect(response).to redirect_to(root_url)
        end
      end
    
      context "unsuccessful user creation" do              
        it "renders the :new template" do
          post :create, user: attributes_for(:user, :new, password: nil)
          expect(response).to render_template :new
        end
      end
    end  
  
    describe "GET #index" do      
      before(:each) do
        user; log_in user
      end
      
      it "populates an array of all activated users" do
        create(:user, activated: false)
        get :index
        # Expecting site admin and user.
        expect(assigns(:users).count).to eq(2)        
      end
    
      it "renders the :index template" do
        get :index
        expect(response).to render_template :index
      end
    end
  
    describe "GET #edit" do      
      before(:each) do 
        user; log_in user
        get :edit, id: user.id
      end
    
      it "assigns the requested user to @user" do
        expect(assigns(:user)).to eq(user)
      end
    
      it "renders the :edit template" do
        expect(response).to render_template :edit
      end
    end
  
    describe "PUT #update" do      
      before(:each) do
        user; log_in user
      end
      
      def update_user
        put :update, id: user.id, user: { first_name: 'Different' }
      end      
    
      it "assigns the requested user to @user" do
        update_user
        expect(assigns(:user)).to eq(user)
      end
    
      context "successful attributes update" do       
        before(:each) do |spec|
          update_user unless spec.metadata[:skip_update]
        end
          
        it "updates the specified user attributes", :skip_update do
          update_user
          expect(assigns(:user).first_name).to eq("Different")
        end
      
        it "displays a success flash" do
          expect(flash[:success]).not_to be_empty
        end
      
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(user))
        end
      end
    
      context "unsuccessful attributes update" do        
        def update_user_unsuccessfully
          put :update, id: user.id, user: { first_name: nil }
          user.reload
        end
      
        it "does not update the user record" do
          expect {
            update_user_unsuccessfully
          }.not_to change(user, :first_name)
        end
      
        it "renders the :edit template" do
          update_user_unsuccessfully
          expect(response).to render_template :edit
        end
      end
    end
  
    describe "GET #show" do      
      before(:each) do |spec|
        unless spec.metadata[:skip_show]
          user; log_in user
          get :show, id: user.id
        end
      end
      
      it "redirects to :index if @user isn't activated", :skip_show do
        user; log_in user
        user.supervisees << non
        get :show, id: non.id
        expect(response).to redirect_to(users_path)
      end
    
      it "assigns the requested user to @user" do
        expect(assigns(:user)).to eq(user)
      end
    
      it "renders the :show template" do
        expect(response).to render_template :show
      end
    end
  
    describe "DELETE #destroy" do      
      before(:each) { user; log_in user }
            
      it "destroys the requested user" do
        expect {
          delete :destroy, { id: user.id }
        }.to change(User, :count).by(-1)
      end
    
      it "displays a success flash" do
        delete :destroy, { id: user.id }
        expect(flash[:success]).not_to be_empty
      end
      
      it "redirects to root_url" do
        # Delete your own profile.
        delete :destroy, { id: user.id }
        expect(response).to redirect_to(root_url)
      end
    end
    
    describe "GET #delete_other_user_index" do     
      context "user is an admin" do    
        let(:non) { create(:user, activated: false) }
        
        before(:each) do |spec|
          unless spec.metadata[:skip_login]
            admin; non; log_in admin
            get :delete_other_user_index
          end
        end
        
        it "assigns all users to @users" do
          expect(assigns(:users).count).to eq 3
        end
        
        it "renders the :delete_other_user_index template" do
          expect(response).to render_template(:delete_other_user_index)
        end
      end
      
      context "user is not an admin" do
        before(:each) do
          # Log in non-admin user
          user; log_in user
          # Attempt to load 'delete_other_user_index' page
          get :delete_other_user_index
        end
        
        it "does not render the :delete_other_user_index template" do
          expect(response).not_to render_template(:delete_other_user_index)
        end
        
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(user))
        end
      end
    end

    describe "DELETE #delete_other_user" do
      def delete_other_user
        admin; user; log_in admin
        delete :delete_other_user, id: user.id
      end

      before(:each) do |spec|
        unless spec.metadata[:skip_delete]
          delete_other_user
        end
      end

      it "creates an instance of @user" do
        expect(assigns(:user)).not_to be_nil
      end

      it "destroys user", :skip_delete do
        admin; user
        log_in admin
        expect do 
          delete :delete_other_user, id: user.id
        end.to change(User, :count).by(-1)
      end

      it "displays a success flash" do
        expect(flash[:success]).to be_present
      end

      it "redirects to delete user index" do
        expect(response).to redirect_to(delete_user_path)
      end

      context "user is not admin" do
        it "does not delete user", :skip_delete do
          expect do
            user; log_in user
            delete :delete_other_user, id: other_user.id
          end.not_to change(User, :all)
        end

        it "redirects to user page", :skip_delete do
          user; other_user; log_in user
          delete :delete_other_user, id: other_user.id
          expect(response).to redirect_to(user_path(current_user))
        end
      end
    end
    
    describe "GET #make_admin_index" do
      context "user is admin" do
        before(:each) do
          # Log in admin user, load 'make_admin_index' page         
          admin; non; log_in admin
          get :make_admin_index
        end
        
        it "assigns all activated users to @users" do
          expect(assigns(:users)).not_to include(non)
        end
        
        it "renders the :make_admin_index template" do
          expect(response).to render_template(:make_admin_index)
        end
      end
      
      context "user is not admin" do
        before(:each) do
          # Log in non-admin user
          user; log_in user
          # Attempt to load 'make_admin'
          get :make_admin_index
        end
        
        it "does not render the :make_admin template" do
          expect(response).not_to render_template(:make_admin_index)
        end
        
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(user))
        end
      end
    end

    describe "PUT #make_admin" do
      def grant_admin_status_to(user)
        admin; user; log_in admin
        put :make_admin, id: user.id
        user.reload
      end

      before(:each) do |spec|
        grant_admin_status_to user unless spec.metadata[:skip_grant]
      end

      it "makes the selected user an admin" do
        expect(user.admin?).to be true
      end

      it "displays a flash success message" do
        expect(flash[:success]).to be_present
      end

      it "redirects to the user index" do
        expect(response).to redirect_to(users_path)
      end

      context "current user is not admin" do
        def no_admin_for_you
          user; log_in user
          put :make_admin, id: user.id
          user.save
        end

        it "does not make the selected user an admin", :skip_grant do
          no_admin_for_you
          expect(user.admin?).to be false
        end

        it "redirects to user page", :skip_grant do
          no_admin_for_you
          expect(response).to redirect_to(user_path(user))
        end
      end
    end
  end  
end