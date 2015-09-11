require 'rails_helper'

describe GrantholdingsController do
  let(:organization) { create(:organization) }
  let(:grant) { create(:grant) }
  let(:user)  { create(:user)  }
  let(:grantholding) {
    create(:grantholding,
      user_id: user.id, 
      grant_id: grant.id, 
      required_hours: 8.0
    )
  }
  let(:grantholding_attributes) {
    { 
      grant_id: grant.id, 
      required_hours: 8.0 
    }
  }
  let(:invalid_attributes) {
    { 
      grant_id: nil, 
      required_hours: 8.0
    }
  }
  
  before(:each) do 
    organization
    organization.grants << grant
    log_in user
    user.grantholdings << grantholding
  end
  
  describe "filters" do
    # Already tested
    # before_action :logged_in
  end
  
  describe "actions" do
    describe "#new" do
      before(:each) { get :new, user_id: user.id }
      
      it "creates an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end

      it "creates an instance of Grant" do
        expect(assigns(:grants).first).to be_an_instance_of(Grant)
      end

      it { expect(assigns(:grants).count).to eq(Grant.count) }
      
      it "renders the :new template" do
        expect(response).to render_template(:new)
      end
    end
    
    describe "#create" do
      def successful_create
        post :create, {user_id: user.id, grantholding: grantholding_attributes}
      end
      
      def unsuccessful_create
        post :create, {user_id: user.id, grantholding: invalid_attributes}
      end
      
      before(:each) do |spec|
        user.grantholdings = []
        successful_create unless spec.metadata[:skip_create]
      end
      
      it "creates an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end
      
      context "successful create" do
        it "assigns record to current user" do
          expect(assigns(:grantholding).user_id).to eq(user.id)
        end

        it "saves the record", :skip_create do
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
        it "does not save the record", :skip_create do
          expect { unsuccessful_create }.not_to change(Grantholding, :count)
        end

        it "creates an instance of Grants", :skip_create do
          unsuccessful_create
          expect(assigns(:grants).first).to be_an_instance_of(Grant)
        end

        it "scopes @grants to all user's grants" do
          unsuccessful_create
          expect(assigns(:grants).count).to eq(Grant.count)
        end
        
        it "renders the new template", :skip_create do
          unsuccessful_create
          expect(response).to render_template(:new)
        end
      end

      context "canceled create form" do
        it "does not save the record", :skip_create do
          g = user.grantholdings
          expect { 
            get :create, user_id: user.id, commit: 'Cancel' 
          }.not_to change(g, :count)
        end

        it "redirects to grantholdings#index", :skip_create do
          get :create, user_id: user.id, commit: 'Cancel'
          expect(response).to redirect_to(user_grantholdings_path(user))
        end
      end
    end
    
    describe "#index" do      
      let(:bob)  { create(:user, first_name: 'Bob') }

      before(:each) do |spec| 
        unless spec.metadata[:skip_index]
          get :index, user_id: user.id
        end
      end
      
      it "sets @grantholdings as an instance of Grantholding" do
        expect(assigns(:grantholdings).take).to be_a_kind_of(Grantholding)
      end
      
      it "finds all current user's grantholdings" do
        expect(assigns(:grantholdings).count).to eq(1)
      end

      it "does not find other users' grantholdings", :skip_index do
        create(:grantholding, user_id: bob.id)
        get :index, user_id: user.id
        expect(assigns(:grantholdings)).not_to include(bob.grantholdings.take)
      end

      it "renders the :index template" do
        expect(response).to render_template(:index)
      end
    end

    describe "#show" do
      before(:each) { get :show, user_id: user.id, id: grantholding.id }

      it "creates an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end

      it "renders the :show template" do
        expect(response).to render_template(:show)
      end
    end
    
    describe "#edit" do
      before(:each) { get :edit, user_id: user.id, id: grantholding.id }
      
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
          user_id: user.id,
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
            user_id: user.id,
            id: grantholding.id, 
            grantholding: { grant_id: nil }
          grantholding.reload
        end
        
        before(:each) do |spec|
          invalid_update unless spec.metadata[:skip_invalid_update]
        end
        
        it "does not save the changes 
          to the Grantholding record", :skip_invalid_update do
          expect { invalid_update }.not_to change(grantholding, :grant_id)
        end
        
        it "renders the :edit template" do
          expect(response).to render_template(:edit)
        end
      end

      context "canceled edit form" do
        def cancel_edit_form
          put :update, user_id: user.id, id: grantholding.id, commit: "Cancel"
        end 

        it "does not save changes" do
          expect { cancel_edit_form }.not_to change(grantholding, :attributes)
        end

        it "redirects to :index" do
          cancel_edit_form
          expect(response).to redirect_to(user_grantholdings_path(user))
        end
      end
    end
    
    describe "#destroy" do
      def destroy_grantholding
        delete :destroy, user_id: user.id, id: grantholding.id
      end

      before(:each) do |spec|
        destroy_grantholding unless spec.metadata[:skip_destroy]
      end
      
      it "finds the correct Grantholding record from id param" do        
        expect(assigns(:grantholding).id).to eq(grantholding.id)
      end
      
      it "sets an instance of Grantholding" do
        expect(assigns(:grantholding)).to be_an_instance_of(Grantholding)
      end

      it "destroys the record", :skip_destroy do
        expect { destroy_grantholding }.to change(Grantholding, :count).by(-1)
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