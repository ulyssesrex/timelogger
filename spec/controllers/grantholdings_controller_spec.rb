require 'rails_helper'

describe GrantholdingsController do
  let(:grant) { create(:grant) }
  let(:user)  { create(:user)  }
  let(:grantholding) do 
    create(:grantholding, 
      user_id: user.id, 
      grant_id: grant.id, 
      required_hours: 8.0)
  end
  let(:grantholding_attributes) do 
    { grantholding: { 
        user_id: user.id, 
        grant_id: grant.id, 
        required_hours: 8.0 
      }
    }
  end
  let(:invalid_attributes) do
    { grantholding: { 
        user_id: nil, 
        grant_id: nil, 
        required_hours: 8.0
      }
    }
  end
  
  before(:each) do 
    log_in user
    user.grantholdings << grantholding
  end
  
  describe "filters" do
    # Already tested
    # before_action :logged_in
  end
  
  describe "actions" do
    describe "#new" do
      before(:each) { get :new }
      
      it "creates an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end
      
      it "renders the :new template" do
        expect(response).to render_template(:new)
      end
    end
    
    describe "#create" do
      def successful_create
        post :create, grantholding_attributes
      end
      
      def unsuccessful_create
        post :create, invalid_attributes
      end
      
      before(:each) do |spec|
        successful_create unless spec.metadata[:skip_create]
      end
      
      it "creates an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end
      
      context "successful create" do
        it "saves the Grantholding record", :skip_create do
          expect { successful_create }.to change(Grantholding, :count).by(1)
        end
        
        it "displays a flash success message" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to home" do
          expect(response).to redirect_to(user_path(user))
        end
      end
      
      context "unsuccessful create" do
        it "does not save the Grantholding record", :skip_create do
          expect { unsuccessful_create }.not_to change(Grantholding, :count)
        end
        
        before(:example) { unsuccessful_create }
        it "renders the new template", :skip_create do
          expect(response).to render_template(:new)
        end
      end
    end
    
    describe "#index" do      
      before(:each) { get :index }
      
      it "sets an instance of Grantholding" do
        expect(assigns(:grantholdings).first).to be_a_kind_of(Grantholding)
      end
      
      it "finds all current user's grantholdings" do
        expect(assigns(:grantholdings).count).to eq(1)
      end

      it "renders the :index template" do
        expect(response).to render_template(:index)
      end
    end
    
    describe "#edit" do
      before(:each) { get :edit, id: grantholding.id }
      
      it "finds the correct instance of Grantholding from id param" do
        expect(assigns(:grantholding).id).to eq(grantholding.id)
      end
      
      it "renders the :edit template" do
        expect(response).to render_template(:edit)
      end
    end
    
    describe "#update" do
      def update_grantholding
        put :update, 
          id: grantholding.id, 
          grantholding: { required_hours: 7.0 }  
      end
      
      before(:each) do |spec|
        update_grantholding unless spec.metadata[:skip_update]
      end
      
      it "finds the correct Grantholding record from id param" do
        expect(assigns(:grantholding).id).to eq(grantholding.id)
      end
      
      it "sets an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end
      
      context "successful update" do
        it "saves the changes to the Grantholding record", :skip_update do
          expect do 
            update_grantholding
            grantholding.reload
          end.to change(grantholding, :required_hours)
        end
        
        it "displays a success flash" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to :index" do
          expect(response).to redirect_to(user_grantholdings_path(user))
        end
      end

      context "unsuccessful update" do
        def invalid_update
          put :update, 
            id: grantholding.id, 
            grantholding: { user_id: nil }
          grantholding.reload
        end
        
        before(:each) do |spec|
          invalid_update unless spec.metadata[:skip_invalid_update]
        end
        
        it "does not save the changes 
          to the Grantholding record", :skip_invalid_update do
          expect { invalid_update }.not_to change(grantholding, :user_id)
        end
        
        it "renders the :edit template" do
          expect(response).to render_template(:edit)
        end
      end
    end
    
    describe "#destroy" do
      before(:each) { delete :destroy, id: grantholding.id }
      
      it "finds the correct Grantholding record from id param" do        
        expect(assigns(:grantholding).id).to eq(grantholding.id)
      end
      
      it "sets an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end
      
      it "displays a success flash" do
        expect(flash[:success]).to be_present
      end
      
      it "redirects to :index" do
        expect(response).to redirect_to(user_grantholdings_path(user))
      end
    end
  end  
end