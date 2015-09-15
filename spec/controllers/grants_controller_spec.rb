require 'rails_helper'

describe GrantsController do
  let(:organization)   { create(:organization) }
  let(:organization_2) { create(:organization, name: 'Organization2') }
  let(:user)    { create(:user, admin: false) }
  let(:admin)   { create(:user, admin: true) }
  let(:admin_2) { create(:user, admin: true, organization: organization_2) }
  let(:grant)   { create(:grant) }
  let(:grant_2) { create(:grant, organization: organization_2) }

  before(:each) { organization }
  
  describe 'filters' do    
    describe "#logged_in" do      
      context "user isn't logged in" do
        before(:each) do
          session[:user_id] = nil
          get :new
        end
        
        it "redirects to login page" do
          expect(response).to redirect_to(login_url)
        end
      
        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end
      end
      
      context "user is logged in" do
        before(:each) do
          log_in admin
          get :new
        end

        it "does not redirect to login page" do
          expect(response).not_to redirect_to(login_url)
        end
      end
    end
    
    describe "#admin" do      
      context "user isn't an admin" do        
        before(:each) do
          log_in user          
          get :new
        end
        
        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end
        
        it "redirects to user home when user is not an admin" do
          expect(response).to redirect_to(user_path(user))
        end
      end
      
      context "user is an admin" do
        before(:each) do
          log_in admin
          get :new
        end
        
        it "does not redirect to user home" do
          expect(response).not_to redirect_to(user_path(user)) 
        end
      end
    end
  end
  
  describe 'actions' do
    before(:each) do 
      # Most Grant actions are in admin scope, so admin is used as example.
      log_in admin
    end
    
    describe "GET #new" do
      before(:each) { get :new } 

      it "creates a Grant instance" do
        expect(assigns(:grant)).to be_an_instance_of(Grant)
      end
      
      it "renders the :new template" do
        expect(response).to render_template(:new)
      end
    end
    
    describe "POST #create" do    
      def create_grant
        post :create, grant: attributes_for(:grant)
      end  

      def attempt_to_create_invalid_grant
        post :create, grant: attributes_for(:grant, name: nil)
      end
      
      before(:each) do |spec| 
        create_grant unless spec.metadata[:skip_create]
      end      
      
      it "creates a Grant instance" do
        expect(assigns(:grant)).to be_an_instance_of(Grant)
      end
      
      context "successful save" do
        it "saves the Grant record", :skip_create do
          expect { create_grant }.to change(Grant, :count).by(1)
        end
        
        it "displays a flash success message" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to :index page" do
          expect(response).to redirect_to(grants_path)
        end
      end
      
      context "unsuccessful save" do
        it "renders the :new template", :skip_create do
          attempt_to_create_invalid_grant
          expect(response).to render_template(:new)
        end
      end
    end
    
    describe "GET #index" do       
      before(:each) do 
        grant
        get :index
      end
      
      it "creates instance of Grants" do
        expect(assigns(:grants).take).to be_a_kind_of(Grant)
      end
      
      it "renders the :index template" do
        expect(response).to render_template(:index)
      end
    end
    
    describe "GET #edit" do            
      it "renders the :edit template" do
        get :edit, id: grant.id
        expect(response).to render_template(:edit)
      end
    end
    
    describe "PUT #update" do            
      context "successful update" do
        def update_grant
          put :update, id: grant.id, grant: { name: 'Updated Name' }
          grant.reload
        end

        before(:each) { |spec| update_grant unless spec.metadata[:skip_update] }

        it "saves the changes to the record", :skip_update do
          expect { 
            update_grant 
          }.to change(grant, :name).to('Updated Name')
        end
        
        it "displays a success flash" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to organization page" do
          expect(response).to redirect_to(organization_path(organization))
        end
      end
      
      context "unsuccessful update" do
        it "renders the :edit template" do
          put :update, id: grant.id, grant: { name: nil }
          expect(response).to render_template(:edit)
        end
      end
    end
    
    describe "DELETE #destroy" do
      def delete_grant
        grant
        delete :destroy, id: grant.id
      end

      before(:each) { |spec| delete_grant unless spec.metadata[:skip_delete] }
               
      it "destroys the grant record", :skip_delete do
        grant
        expect { 
          delete :destroy, id: grant.id 
        }.to change(Grant, :count).by(-1)
      end
      
      it "displays a success flash" do
        expect(flash[:success]).to be_present
      end
      
      it "redirects to organization page" do
        expect(response).to redirect_to(organization_path(organization))
      end
    end    
  end
end