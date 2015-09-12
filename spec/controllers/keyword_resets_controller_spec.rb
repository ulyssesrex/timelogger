require 'rails_helper'

describe KeywordResetsController, type: :controller do
  let(:organization) { create(:organization) }
  let(:admin)        { create(:user, admin: true) }
  let(:reset_token)  { User.new_token }

  def edit_keyword_reset
    get :edit, id: reset_token, email: admin.email
  end

  before(:each) { organization }

  describe "filters" do
    describe "#find_organization" do
      it "assigns instance of organization based on user email param" do
        edit_keyword_reset
        expect(assigns(:organization)).to eq(admin.organization)
      end
    end

    describe "#valid_org_scenario" do
      context "@organization is nil" do 
        it "redirects to root" do
          get :edit, id: reset_token, email: 'invalid'
          expect(response).to redirect_to(root_path)
        end
      end

      context "can't authenticate reset token" do
        it "redirects to root" do
          get :edit, id: 'invalid', email: admin.email
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
        let(:org_with_expired_password_reset) do
          create(
            :organization, 
            reset_token: reset_token, 
            reset_digest: User.digest(reset_token), 
            reset_sent_at: 3.hours.ago
          )
        end

        let(:other_admin) do 
          create(
            :user, 
            admin: true, 
            organization: org_with_expired_password_reset
          )
        end

        before(:each) do
          get :edit, 
            id: org_with_expired_password_reset.reset_token, 
            email: other_admin.email
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
        post :create, keyword_reset: { email: admin.email } }
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
          unless spec.metadata[:skip]
            create_keyword_reset
          end
        end

        it "creates a reset digest for @organization", :skip do
          expect { 
            create_keyword_reset 
          }.to change(
            organization,:reset_digest
          )
        end

        it "sends an email to @admin", :skip do
          expect {
            create_keyword_reset
          }.to change { 
            ActionMailer::Base.deliveries.count 
          }.by(1)
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
          post :create, keyword_reset: { email: 'invalid' }
        end

        before(:each) do |spec|
          unless spec.metadata[:skip]
            invalid_create
          end
        end

        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end

        it "renders :new template" do
          expect(response).to render_template(:new)
        end

        it "does not create a reset digest", :skip do
          expect { 
            invalid_create 
          }.not_to change { 
            assigns(:organization).reset_digest 
          }
        end

        it "does not send an email", :skip do
          expect {
            invalid_create
          }.not_to change { 
            ActionMailer::Base.deliveries.count 
          }.by(1)
      end
    end

    describe "GET #edit" do
      def edit_keyword_reset
        get :edit, id: reset_token, email: admin.email
      end

      it "sets @reset from id param" do
        edit_keyword_reset
        expect(assigns(:reset)).to eq(organization.reset_token)
      end

      it "renders :edit template" do
        edit_keyword_reset
        expect(response).to render_template(:edit)
      end
    end

    describe "GET #update" do
      def update_keyword_reset
        put :update, 
          id: organization.id, 
          email: admin.email, 
          organization: 
          { 
            password: 'password', 
            password_confirmation: 'password' 
          }
        organization.reload
      end      

      it "sets an instance of User" do
        update_keyword_reset
        expect(assigns(:admin)).to be_an_instance_of(User)
      end

      context "user submits blank keyword" do
        def blank_keyword_reset
          put :update, 
            id: organization.id, 
            email: admin.email, 
            organization: 
            { 
              password: '', 
              password_confirmation: '' 
            }
          organization.reload
        end

        before(:each) do |spec|
          unless spec.metadata[:skip]
            blank_keyword_reset
          end
        end

        it "displays a danger flash" do
          expect(flash[:danger]).to be_present
        end

        it "renders :edit template" do
          expect(response).to render_template(:edit)
        end

        it "does not update organization keyword", :skip do
          expect { 
            blank_keyword_reset 
          }.not_to change(
            organization, :password_digest
          )
        end
      end

      context "user submits non-blank keyword" do
        before(:each) do |spec|
          unless spec.metadata[:skip]
            update_keyword_reset
          end
        end

        it "updates organization keyword", :skip do
          expect { 
            update_keyword_reset 
          }.to change(
            organization, :reset_digest
          )
        end

        it "logs in admin" do
          expect(session[:user_id]).to eq(admin.id)
        end

        it "displays a success flash" do
          expect(flash[:success]).to be_present
        end

        it "redirects to admin home page" do
          expect(response).to redirect_to(user_path(admin))
        end
      end

      context "update error" do
        def keyword_reset_update_error
          put :update, id: 'invalid'
        end

        it "does not update organization keyword" do
          expect { 
            keyword_reset_update_error 
          }.not_to change(
            organization, :reset_digest
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
