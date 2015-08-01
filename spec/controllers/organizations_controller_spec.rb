require 'rails_helper'

describe OrganizationsController do
  let(:organization)   { create(:organization) }
  let(:admin)          { create(:user, admin: true) }
  
  def organization_attributes
    { name: "Organization",
      description: "A test organization.",        
      password: "password",
      password_confirmation: "password",
      users_attributes: [
        first_name: "Admin",
        last_name: "McAdmin",
        position: "Admin",
        email: "test@example.com",
        password: "password",
        password_confirmation: "password"          
      ]
    }
  end
  
  def invalid_attributes
    organization_attributes.update({ name: '' })
  end
  
  def new_organization
    get :new
  end
  
  def create_organization
    post :create, organization: organization_attributes
  end
  
  def show_organization
    get :show, id: organization.id
  end
  
  def edit_organization
    get :edit, id: organization.id
  end
  
  def update_organization
    put :update, id: organization.id, organization: { name: 'Different Name' } 
    organization.reload
  end
  
  def delete_organization
    delete :destroy, id: organization.id
  end
  
  def sets_organization_correctly
    expect(assigns(:organization)).to eq(organization)
  end
  
  describe "filters" do
    describe "#set_organization" do
      before(:each) { log_in admin }
      
      context "finds organization by param" do
        before(:example) { show_organization }
        it { sets_organization_correctly }
        
        before(:example) { edit_organization }
        it { sets_organization_correctly }
        
        before(:example) { delete_organization }
        it { sets_organization_correctly }
      end
    end
    
    describe "#logged_in" do
      it { # is already tested.
      }
    end
    
    describe "#admin" do
      it { # is already tested.
      }
    end
  end
  
  describe "actions" do        
    describe "#new" do
      before(:each) { new_organization }
      
      it "renders the :new template" do
        expect(response).to render_template(:new)
      end  
    end
    
    describe "#create" do
      before(:each) do |spec|
        create_organization unless spec.metadata[:skip_create]
      end

      it "creates an instance of Organization" do
        expect(assigns(:organization)).to be_an_instance_of(Organization)
      end

      context "successful save" do
        it "saves a new Organization record", :skip_create do
          expect {
            create_organization
          }.to change(Organization, :count).by(1)
        end

        it "saves a new User record through nested attributes", :skip_create do
          expect {
            create_organization
          }.to change(User, :count).by(1)
        end

        it "displays a success flash" do
          expect(flash[:success]).to be_present
        end

        it "redirects to the login page" do
          expect(response).to redirect_to(root_url)
        end
      end

      context "unsuccessful save" do
        def invalid_create
          post :create, organization: invalid_attributes
        end

        it "does not save a new Organization record", :skip_create do
          expect { invalid_create }.not_to change(Organization, :count)
        end

        it "renders the :new template", :skip_create do
          invalid_create
          expect(response).to render_template(:new)
        end
      end
    end
    
    describe "#show" do
      before(:each) do
        log_in admin
        show_organization
      end 
      
      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
    end
    
    describe "#edit" do
      before(:each) do
        log_in admin
        edit_organization
      end
      
      it "assigns the organization to @organization" do
        expect(assigns(:organization)).to eq(organization)
      end 
      
      it "renders the :edit template" do
        expect(response).to render_template(:edit)
      end
    end
    
    describe "#update" do
      before(:each) { log_in admin }
      
      before(:each) do |spec|
        update_organization unless spec.metadata[:skip_update]
      end
      
      context "successful update" do
        it "saves the changes to the record", :skip_update do
          expect {
            update_organization
          }.to change(organization, :name).to('Different Name')
        end
        
        it "displays a flash success message" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to the organization's :show page" do
          expect(response).to redirect_to(@organization)
        end
      end
      
      context "unsuccessful update" do
        let(:unsuccessful_update) do
          put :update, 
            id: organization.id, 
            organization: { 
              name: '' 
            }
        end
        
        it "does not save the changes to the record", :skip_update do
          expect { 
            unsuccessful_update 
          }.not_to change(Organization, :name)
        end
        
        it "renders the :edit template", :skip_update do
          unsuccessful_update
          expect(response).to render_template(:edit)
        end
      end
    end
    
    describe "#destroy" do            
      before(:each) { log_in admin }       
      
      before(:each) do |spec|
        unless spec.metadata[:skip_delete]
          organization
          delete_organization 
        end
      end
      
      it "destroys the record", :skip_delete do
        organization
        expect { 
          delete_organization
        }.to change(Organization, :count).by(-1)
      end
      
      it "displays a flash success message" do
        expect(flash[:success]).to be_present
      end
      
      it "redirects to root" do
        expect(response).to redirect_to(root_url)
      end
    end
  end
end