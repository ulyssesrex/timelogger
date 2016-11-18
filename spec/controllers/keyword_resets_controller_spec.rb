require 'rails_helper'

describe KeywordResetsController, type: :controller do
  let(:organization)   { create(:organization) }
  let(:organization_a) { create(:organization_with_reset_info) }
  let(:admin)   { organization.users.first   }  
  let(:admin_a) { organization_a.users.first }


  def edit_keyword_reset
    get :edit, params: { id: organization_a.reset_token, email: admin_a.email }
  end

  before(:each) { organization; organization_a }

  describe "filters" do
    describe "#find_organization" do
      it "assigns instance of organization based on user email param" do
        edit_keyword_reset
        expect(assigns(:organization)).to eq(admin_a.organization)
      end
    end

    describe "#valid_org_scenario" do
      context "@organization is nil" do 
        it "redirects to root" do
          get :edit, params: { id: organization_a.reset_token, email: 'invalid' }
          expect(response).to redirect_to(root_path)
        end
      end

      context "can't authenticate reset token" do
        it "redirects to root" do
          get :edit, params: { id: 'invalid', email: admin_a.email }
          expect(response).to redirect_to(root_path)
        end
      end

      context "valid organization scenario" do
        it "proceeds with action" do
          edit_keyword_reset # with valid parameters
          expect(response).to render_template(:edit)
        end
      end
    end

    describe "#check_expiration" do
      context "reset was sent more than two hours ago" do
        let(:reset_token) { User.new_token }
        let(:org_with_expired_password_reset) do
          create(:organization, 
            reset_token: reset_token, 
            reset_digest: User.digest(reset_token), 
            reset_sent_at: 3.hours.ago
          )
        end

        let(:admin_b) do 
          create(:user, 
            admin: true, 
            organization: org_with_expired_password_reset
          )
        end

        before(:each) do
          get :edit, params: {
            id: org_with_expired_password_reset.reset_token, 
            email: admin_b.email
          }
        end

        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end

        it "redirects to the keyword reset form" do
          expect(response).to redirect_to(new_keyword_reset_path)
        end
      end

      context "reset was sent less than two hours ago" do
        it "proceeds with action" do
          edit_keyword_reset
          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "actions" do  
    describe "GET #new" do
      def new_keyword_reset
        get :new
      end 
           
      it "displays :new template" do
        new_keyword_reset
        expect(response).to render_template(:new)
      end
    end

    describe "GET #create" do
      def create_keyword_reset
        post :create, params: { keyword_reset: { email: admin.email } }
      end 
           
      it "sets an instance of User" do
        create_keyword_reset
        expect(assigns(:admin)).to be_an_instance_of(User)
      end

      it "sets an instance of Organization" do
        create_keyword_reset
        expect(assigns(:organization)).to be_an_instance_of(Organization)
      end

      context "@admin and @organization both valid" do
        before(:each) do |spec|
          unless spec.metadata[:skip_create]
            create_keyword_reset
          end
        end

        it "creates a reset digest for @organization" do
          reset_digest = Organization.find(organization.id).reset_digest
          expect(reset_digest).not_to be_nil
        end

        it "sends an email to @admin", :skip_create do
          expect { create_keyword_reset }.to change { ActionMailer::Base.deliveries.count }.by(1)
        end

        it "displays an info flash" do
          expect(flash[:info]).to be_present
        end

        it "redirects to root" do
          expect(response).to redirect_to(root_path)
        end
      end

      context "either/both @admin or @organization are nil" do
        def invalid_create
          post :create, params: { keyword_reset: { email: 'invalid' } }
        end

        before(:each) do |spec|
          unless spec.metadata[:skip_create]
            invalid_create
          end
        end

        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end

        it "renders :new template" do
          expect(response).to render_template(:new)
        end

        it "does not create a reset digest" do
          reset_digest = Organization.find(organization.id).reset_digest
          expect(reset_digest).to be_nil
        end

        it "does not send an email", :skip_create do
          expect {
            invalid_create
          }.not_to change(
            ActionMailer::Base.deliveries, :count
          )
        end
      end
    end

    describe "GET #edit" do
      def edit_keyword_reset
        get :edit, params: { id: organization_a.reset_token, email: admin_a.email }
      end

      it "sets @reset from id param" do
        edit_keyword_reset
        expect(assigns(:reset)).to eq(organization_a.reset_token)
      end

      it "renders :edit template" do
        edit_keyword_reset
        expect(response).to render_template(:edit)
      end
    end

    describe "GET #update" do
      def update_keyword_reset
        put :update, params: {
          id: organization_a.reset_token, 
          email: admin_a.email, 
          organization: { 
            password: 'different', 
            password_confirmation: 'different' 
          }
        }
      end      

      it "sets an instance of User" do
        update_keyword_reset
        expect(assigns(:admin)).to be_an_instance_of(User)
      end

      context "user submits blank keyword" do
        def blank_keyword_reset
          put :update, params: {
            id: organization_a.reset_token, 
            email: admin_a.email, 
            organization: { 
              password: '', 
              password_confirmation: '' 
            }
          }
        end

        before(:each) do |spec|
          blank_keyword_reset unless spec.metadata[:skip_update]
        end

        it "renders :edit template" do
          expect(response).to render_template(:edit)
        end

        it "does not update organization keyword", :skip_update do
          old_password_digest = organization_a.password_digest
          blank_keyword_reset
          expect(organization_a.password_digest).to equal(old_password_digest)
        end
      end

      context "user submits non-blank keyword" do
        before(:each) do |spec|
          unless spec.metadata[:skip_update]
            update_keyword_reset
          end
        end

        it "updates organization keyword", :skip_update do
          expect do 
            update_keyword_reset 
            organization_a.reload
          end.to change(
            organization_a, :password_digest
          )
        end

        it "logs in admin" do
          expect(session[:user_id]).to eq(admin_a.id)
        end

        it "displays a success flash" do
          expect(flash[:success]).to be_present
        end

        it "redirects to admin home page" do
          expect(response).to redirect_to(user_path(admin_a))
        end
      end

      context "update error" do
        def keyword_reset_update_error
          put :update, params: {
            id: organization_a.reset_token, 
            email: admin_a.email, 
            organization: { 
              password: 'short', 
              password_confirmation: 'short' 
            } 
          }
        end

        it "does not update organization keyword" do
          expect { 
            keyword_reset_update_error 
          }.not_to change(
            organization_a, :reset_digest
          )
        end

        it "renders :edit template" do
          keyword_reset_update_error
          expect(response).to render_template(:edit)
        end
      end
    end
  end
end