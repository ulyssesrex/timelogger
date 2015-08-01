require 'rails_helper'

describe SupervisionsController do  
  describe 'filters' do
    describe '#logged_in' do
      # See application_controller_spec.rb
    end 
  end
  
  describe 'actions' do    
    let(:organization) { create(:organization) }    
    before(:each) { organization }
    
    describe '#create' do
      let(:supervisor) { organization.users.first }
      let(:supervisee) { create(:user) }
            
      before(:each) do |spec|
        unless spec.metadata[:skip_before]
          log_in supervisee
          post :create, supervisor_id: supervisor.id
        end
      end        
      
      it "finds a user from the supervisor_id param" do
        expect(assigns(:user).id).to eq(supervisor.id)
      end
      
      it "sets a instance of User" do
        expect(assigns(:user)).to be_an_instance_of(User)
      end
      
      it "creates a supervision", :skip_before do
        log_in supervisee
        expect { 
          post :create, supervisor_id: supervisor.id 
        }.to change(Supervision, :count).by(1)
      end
      
      it "creates a supervisor for the supervisee" do
        expect(supervisee.supervisors).to include(supervisor)
      end
      
      it "creates a supervisee for the supervisor" do
        expect(supervisor.supervisees).to include(supervisee)
      end
      
      it "displays a success message" do
        expect(flash[:success]).to be_present
      end
      
      it "redirects to users#index" do
        expect(response).to redirect_to(users_path)
      end
    end
    
    describe '#all_coworkers' do
      let(:user) { organization.users.first } # activated: true
      let(:non)  { create(:user, organization_id: organization.id, activated: false) }
      
      before(:each) do 
        non
        log_in user 
        get :all_coworkers
      end
      
      it "assigns all activated users to @users" do
        expect(assigns(:users).count).to eq(1)
      end
      
      it "renders the :all_coworkers template" do
        expect(response).to render_template(:all_coworkers)
      end
    end
    
    describe '#supervisees' do
      let(:supervisor)   { create(:user, :supervisor) }
      let(:unsupervised) { create(:user) }
      
      before(:each) do
        unsupervised
        log_in supervisor
        get :supervisees
      end
      
      it "assigns all current user's supervisees to @supervisees" do
        expect(assigns(:supervisees)).to include(supervisor.supervisees.last)
      end
      
      it "does not include other users in @supervisees" do
        expect(assigns(:supervisees)).not_to include(unsupervised)
      end
      
      it "renders the :supervisees template" do
        expect(response).to render_template(:supervisees)
      end
    end
    
    describe '#destroy' do
      let(:supervisor) { create(:user) }
      let(:supervisee) { create(:user) }
      
      before(:each) do |spec|
        unless spec.metadata[:skip_login]
          log_in supervisee          
        end
      end
      
      before(:each) do |spec|
        unless spec.metadata[:skip_add_supervisor]
          supervisee.supervisors << supervisor
        end
      end
      
      before(:each) do |spec|
        unless spec.metadata[:skip_delete_supervisor]
          delete :destroy, id: supervisor.id
        end
      end
      
      it "finds a User from the id param" do
        expect(assigns(:user).id).to eq(supervisor.id)
      end
      
      context "invalid supervision request" do        
        let(:unsupervised) { create(:user) }
        
        before(:each) do
          log_in unsupervised
          delete :destroy, id: supervisor.id
        end
        
        it "displays a danger flash", :skip_delete_supervisor do
          expect(flash[:danger]).to be_present
        end
          
        it "redirects to users_path", :skip_delete_supervisor do
          expect(response).to redirect_to(users_path)
        end
      end

      it "finds the Supervision between 
        current_user and @user", :skip_delete_supervisor do     
        @boss = current_user.supervisors.first
        delete :destroy, id: supervisor.id   
        expect(assigns(:supervision).supervisor).to eq(@boss)
      end
      
      it "sets an instance of Supervision" do
        expect(assigns(:supervision)).to be_an_instance_of(Supervision)
      end
            
      it "destroys the supervision", :skip_delete_supervisor do
        expect { delete :destroy, id: supervisor.id }.to change(Supervision, :count).by (-1)
      end
      
      it "displays a success message" do
        expect(flash[:success]).to be_present
      end
      
      it "redirects to users#index" do
        expect(response).to redirect_to(users_path)
      end
    end
  end  
end