require 'rails_helper'

describe TimelogsController do
  
  let(:timelog)  { create(:timelog) }
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin)      { create(:user, admin: true) }  
  
  describe 'actions' do    
    
    describe 'GET #new' do
      def new_timelog
        log_in user
        get :new
      end

      def new_timelog_with_params
        log_in user
        get :new, timelog_start: Time.zone.now, timelog_finish: Time.zone.now
      end
            
      it "creates a new instance of @timelog" do
        new_timelog
        expect(assigns(:timelog)).not_to be_nil
      end

      it "sets @timelog.start_time from params" do
        new_timelog_with_params
        expect(assigns(:timelog).start_time).not_to be_nil
      end

      it "sets @timelog.end_time from params" do
        new_timelog_with_params
        expect(assigns(:timelog).end_time).not_to be_nil
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
    
    describe 'POST #create' do
      
      let(:timelog) { build(:timelog) }
      
      def create_timelog_for(a_user)
        post :create, 
          timelog: { 
            user_id: a_user.id, 
            start_time: timelog.start_time, 
            end_time: timelog.end_time, 
            comments: timelog.comments 
          }
      end
      
      before(:each) { log_in user }
            
      it "creates a new Timelog instance" do
        create_timelog_for(user)
        expect(assigns(:timelog)).not_to be_nil
      end
      
      it "redirects if current user isn't the timelog's user or an admin" do
        log_in other_user
        create_timelog_for(user)
        expect(response).to redirect_to(user_path(other_user))        
      end
      
      it "passes if current user is the timelog's user or an admin" do
        log_in admin
        expect { 
          create_timelog_for(user) 
        }.to change { Timelog.count }.by(1)
      end
      
      context "successful save" do        
                
        it "saves a new record" do
          expect {
           create_timelog_for(user)
          }.to change { Timelog.count }.by(1)
        end
        
        before(:each) { create_timelog_for user }
        
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
          post :create, 
            timelog: { 
              user_id:    user.id, 
              start_time: Time.zone.now, 
              end_time:   Time.zone.now - 2.hours 
            }
          expect(response).to render_template(:new)
        end
      end      
    end
    
    describe 'GET #show' do
      
      let(:supervisor) { create(:user).supervisees << timelog.user }
      
      def show_user_timelog
        get :show, id: timelog.id
      end
      
      it "creates an instance of Timelog" do
        show_user_timelog
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      it "passes if current user is user" do
        log_in(timelog.user)
        show_user_timelog
        expect(response).not_to redirect_to(user_path(timelog.user))
      end      

      it "passes if current user is user's supervisor" do
        supervisor = create(:user)
        log_in(supervisor)
        supervisor.supervisees << timelog.user        
        show_user_timelog
        expect(response).not_to redirect_to(user_path(supervisor))
      end
      
      it "passes if current user is admin" do
        log_in(admin)
        show_user_timelog
        expect(response).not_to redirect_to(user_path(admin))
      end
      
      it "redirects if current user is not user, 
        user's supervisor, or admin" do
        log_in(other_user)
        show_user_timelog
        expect(response).to redirect_to(user_path(other_user))
      end
      
      it "renders the :show template" do
        log_in timelog.user
        show_user_timelog
        expect(response).to render_template(:show)
      end
    end
    
    describe 'GET #edit' do
      
      def edit_timelog
        get :edit, id: timelog.id
      end
      
      it "creates an instance of Timelog" do
        edit_timelog
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      it "passes if current_user is user" do
        log_in timelog.user
        edit_timelog
        expect(response).not_to redirect_to(user_path(timelog.user))
      end
      
      it "passes if current_user is admin" do
        log_in admin
        edit_timelog
        expect(response).not_to redirect_to(user_path(admin))
      end
      
      it "redirects to user page if current_user is not user or admin" do
        log_in other_user
        edit_timelog
        expect(response).to redirect_to(user_path(other_user))
      end
      
      it "renders the :edit template" do
        log_in timelog.user
        edit_timelog
        expect(response).to render_template(:edit)
      end
    end
    
    describe 'PUT #update' do
      
      def update_timelog
        put :update, 
          id: timelog.id, 
          timelog: { 
            start_time: Time.new(2014, 2, 4) 
          }
        timelog.reload
      end
      
      it "passes if current_user is user" do
        log_in timelog.user
        expect { update_timelog }.to change(timelog, :start_time)
      end
      
      it "passes if current_user is admin" do
        log_in admin
        expect { update_timelog }.to change(timelog, :start_time)
      end
      
      it "redirects if current_user is not user or admin" do
        log_in other_user
        expect { update_timelog }.not_to change(timelog, :start_time)
      end
      
      it "creates an instance of Timelog" do
        update_timelog
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      context "successful update and save" do
        
        it "updates the record in the database" do
          # Already tested
        end
        
        before(:each) do
          log_in timelog.user
          update_timelog
        end
        
        it "displays a success flash" do
          expect(flash[:success]).to be_present          
        end
        
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(timelog.user))
        end        
      end
      
      context "unsuccessful save" do
        
        def invalid_update
          put :update, 
            id: timelog.id, 
            timelog: { 
              start_time: Time.zone.now 
            }
        end
        
        before(:each) { log_in timelog.user }
        
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
        delete :destroy, id: timelog.id
      end
      
      before(:each) { log_in timelog.user }
      
      it "creates an instance of Timelog" do
        destroy_timelog
        expect(assigns(:timelog)).to be_an_instance_of(Timelog)
      end
      
      it "finds timelog by id in params" do
        destroy_timelog
        expect(assigns(:timelog).id).to eq(timelog.id)
      end
      
      it "passes if current user is user" do
        expect { destroy_timelog }.to change(Timelog, :count).by(-1)
      end
      
      it "passes if current user is admin" do
        log_in admin
        expect { destroy_timelog }.to change(Timelog, :count).by(-1)
      end
      
      it "does not delete timelog record if 
        current user is not user or admin" do
        log_in other_user
        expect { destroy_timelog }.not_to change(Timelog, :count)
      end
      
      it "deletes the timelog record in the database" do
        # Tested in 'passes if current user is user'
      end
      
      it "displays a success flash" do
        destroy_timelog
        expect(flash[:success]).to be_present
      end
      
      it "redirects to user page" do
        user = timelog.user
        destroy_timelog
        expect(response).to redirect_to(user_path(user))
      end
    end    
  end
end