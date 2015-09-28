require 'rails_helper'

describe GrantholdingsController do
  let(:organization) { create(:organization) }
  let(:grant) { create(:grant) }
  let(:grant_2) { create(:grant) }
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

  def successful_create
    post :create, { user_id: user.id, grant_ids: [grant.id] }
  end
  
  before(:each) do 
    organization.grants << grant << grant_2
    log_in user
  end
  
  describe "actions" do
    describe "#new" do
      before(:each) { get :new, user_id: user.id }

      it "creates an instance of Grant" do
        expect(assigns(:grants).first).to be_an_instance_of(Grant)
      end

      it { expect(assigns(:grants).count).to eq(Grant.count - user.grants.count) }
      
      it "renders the :new template" do
        expect(response).to render_template(:new)
      end
    end
    
    describe "#create" do
      def successful_create
        post :create, { user_id: user.id, grant_ids: [grant.id] }
      end
      
      def unsuccessful_create
        post :create, {user_id: user.id, grant_ids: 'invalid'}
      end
      
      before(:each) do |spec|
        user.grantholdings = []
        successful_create unless spec.metadata[:skip_create]
      end
      
      context "successful create" do

        it "saves the record", :skip_create do
          expect { successful_create }.to change(Grantholding, :count).by(1)
        end
        
        it "displays a flash success message" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to home" do
          expect(response).to redirect_to(edit_user_path(user))
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
        grantholding
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