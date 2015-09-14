require 'rails_helper'

describe TimelogsController do
  
  let(:organization) { create(:organization) }
  let(:user)       { create(:user, organization: organization) }
  let(:other_user) { create(:user, organization: organization) }
  let(:admin)      { create(:user, organization: organization, admin: true) }
  let(:timelog)    { create(:timelog, user: user) }
  let(:timelog_attr) { attributes_for(:timelog, user: user) }
  let(:grant)      { create(:grant, organization: organization) }
  let(:grantholding) { create(:grantholding, grant: grant, user: user) }
  
  describe 'actions' do
    def new_timelog
      log_in user
      get :new, user_id: user.id
    end

    def new_timelog_with_params
      log_in user
      get :new, 
        user_id: user.id, 
        start_time: Time.zone.now, 
        end_time:   Time.zone.now
    end     

    describe 'GET #new' do            
      it "creates a new instance of User" do
        new_timelog
        expect(assigns(:user)).to be_an_instance_of(User)
      end

      it "creates a new instance of @timelog" do
        new_timelog
        expect(assigns(:timelog)).not_to be_nil
      end

      it "builds time allocations from user's grantholdings" do
        new_timelog
        expect(
          assigns(:timelog).time_allocations.count
        ).to eq(user.grantholdings.count)
      end

      it "sets start_time field value from params" do
        new_timelog_with_params
        expect(assigns(:start)).not_to be_nil
      end

      it "sets end_time field value from params" do
        new_timelog_with_params
        expect(assigns(:end)).not_to be_nil
      end

      it "doesn't set @timelog attributes when no params" do
        new_timelog
        expect(assigns(:timelog).start_time).to be_nil
      end

      it "renders the :new template" do
        new_timelog
        expect(response).to render_template(:new)
      end
    end

    describe 'POST #end_from_button' do
      before(:each) do |spec|
        new_timelog_with_params unless spec.metadata[:skip_button]
      end

      # Variables setup already tested in #new.

      it "renders javascript" do
        # Tested in feature specs.
      end
    end
    
    describe 'POST #create' do      
      let(:timelog) { build(:timelog) }
      
      def create_timelog_for(user)
        post :create, user_id: user.id, timelog: timelog_attr
      end
      
      before(:each) { log_in user }
            
      it "creates a new Timelog instance" do
        create_timelog_for(user)
        expect(assigns(:timelog)).not_to be_nil
      end

      it "assigns @timelog to current user" do
        create_timelog_for(user)
        expect(assigns(:timelog).user).to eq(current_user)
      end
      
      it "redirects if current user isn't the timelog's user, or if not, not an admin" do
        log_in other_user
        create_timelog_for(user)
        expect(response).to redirect_to(user_path(other_user))        
      end

      it "redirects if user cancels new timelog form" do
        post :create, user_id: user.id, commit: "Cancel"
        expect(response).to redirect_to(user_path(current_user))
      end
      
      it "passes if current user is the timelog's user or an admin" do
        log_in admin
        expect { 
          create_timelog_for(user) 
        }.to change { Timelog.count }.by(1)
      end
      
      context "successful save" do   
        before(:each) do |spec|
          create_timelog_for user unless spec.metadata[:skip_create]
        end

        it "saves a new record", :skip_create do
          expect {
           create_timelog_for(user)
          }.to change { user.timelogs.count }.by(1)
        end
        
        it "displays a success flash" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to the user page" do
          expect(response).to redirect_to(user_path(user))
        end
      end
      
      context "unsuccessful save" do        
        it "renders the :new template" do
          # Attempt to save timelog where end is earlier than start.
          # Raises validation error on Timelog.
          post :create, user_id: user.id,
            timelog: {  
              start_time: Time.zone.now, 
              end_time:   Time.zone.now - 2.hours 
            }
          expect(response).to render_template(:new)
        end
      end      
    end
    
    describe 'GET #show' do      
      let(:supervisor) { create(:supervisor, organization: organization) }
      let(:supervisee) { supervisor.supervisees.first }
      let(:supervisee_timelog) { create(:timelog, user: supervisee) }
      let(:supervisor_timelog) { create(:timelog, user: supervisor) }
      
      def show_supervisee_timelog
        get :show, user_id: supervisee.id, id: supervisee_timelog.id
      end

      def show_supervisor_timelog
        get :show, user_id: supervisor.id, id: supervisor_timelog.id
      end
      
      it "creates an instance of Timelog" do
        log_in(supervisee)
        show_supervisee_timelog
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      it "passes if current user is user" do
        log_in(supervisee_timelog.user)
        show_supervisee_timelog
        expect(response).not_to redirect_to(user_path(current_user))
      end      

      it "passes if current user is user's supervisor" do
        log_in(supervisor)        
        show_supervisee_timelog
        expect(response).not_to redirect_to(user_path(supervisor))
      end
      
      it "passes if current user is admin" do
        log_in(admin)
        show_supervisee_timelog
        expect(response).not_to redirect_to(user_path(admin))
      end

      it "redirects if current user is timelog user's supervisee" do
        log_in(supervisee)
        show_supervisor_timelog
        expect(response).to redirect_to(user_path(supervisee))
      end
      
      it "redirects if current user is not user, 
        user's supervisor, or admin" do
        log_in(other_user)
        show_supervisor_timelog
        expect(response).to redirect_to(user_path(other_user))
      end
      
      it "renders the :show template" do
        log_in(supervisee)
        show_supervisee_timelog
        expect(response).to render_template(:show)
      end
    end
    
    describe 'GET #edit' do      
      def edit_timelog
        get :edit, user_id: user.id, id: timelog.id
      end
      
      it "creates an instance of Timelog" do
        log_in user
        edit_timelog
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      it "passes if current_user is user" do
        log_in user
        edit_timelog
        expect(response).not_to redirect_to(user_path(user))
      end
      
      it "passes if current_user is admin" do
        log_in admin
        edit_timelog
        expect(response).not_to redirect_to(user_path(admin))
      end
      
      it "redirects to user page if current_user is not user or admin" do
        log_in other_user
        edit_timelog
        expect(response).to redirect_to(users_path)
      end
      
      it "renders the :edit template" do
        log_in user
        edit_timelog
        expect(response).to render_template(:edit)
      end
    end
    
    describe 'PUT #update' do      
      def update_timelog
        put :update, user_id: user.id,
          id: timelog.id, 
          timelog: { start_time: Time.new(2014, 2, 4) }
      end
      
      it "passes if current_user is user" do
        log_in user
        expect do 
          update_timelog
          timelog.reload
        end.to change(timelog, :start_time)
      end
      
      it "passes if current_user is admin" do
        log_in admin
        expect do
          update_timelog
          timelog.reload
        end.to change(timelog, :start_time)
      end
      
      it "redirects if current_user is not user or admin" do
        log_in other_user
        expect do
          update_timelog
          timelog.reload
        end.not_to change(timelog, :start_time)
      end
      
      it "creates an instance of Timelog" do
        log_in user
        update_timelog
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      context "successful update and save" do        
        it "updates the record in the database" do
          # Already tested in previous block.
        end
        
        before(:each) do
          log_in user
          update_timelog
        end
        
        it "displays a success flash" do
          expect(flash[:success]).to be_present          
        end
        
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(user))
        end        
      end
      
      context "unsuccessful save" do        
        # Update raises validation error on Timelog (well_ordered_times)
        def invalid_update
          put :update, user_id: user.id,
            id: timelog.id, 
            timelog: { start_time: Time.zone.now }
        end
        
        before(:each) { log_in user }
        
        it "does not update the record" do
          expect { invalid_update }.not_to change(timelog, :start_time)
        end
        
        it "renders the :edit template" do
          invalid_update
          expect(response).to render_template(:edit)
        end
      end      
    end
    
    describe 'DELETE #destroy' do        
      def destroy_timelog
        delete :destroy, user_id: user.id, id: timelog.id
      end
      
      before(:each) do
        timelog
        log_in user
      end

      before(:each) do |spec|
        unless spec.metadata[:skip_destroy]
          destroy_timelog
        end
      end
      
      it "creates an instance of Timelog" do
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      it "finds timelog by id in params" do
        expect(assigns(:timelog).id).to eq(timelog.id)
      end
      
      it "passes if current user is user", :skip_destroy do
        expect { destroy_timelog }.to change(Timelog, :count).by(-1)
      end
      
      it "passes if current user is admin", :skip_destroy do
        expect { destroy_timelog }.to change(Timelog, :count).by(-1)
      end
      
      it "does not delete timelog record if 
        current user is not user or admin", :skip_destroy do        
        log_in other_user
        expect { destroy_timelog }.not_to change(Timelog, :count)
      end
      
      it "displays a success flash" do
        expect(flash[:success]).to be_present
      end
      
      it "redirects to user page" do
        expect(response).to redirect_to(user_path(user))
      end
    end    
  end
end