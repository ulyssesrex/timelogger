require 'rails_helper'

describe TimesheetsController do
  
  let(:timesheet)  { create(:timesheet) }
  let(:user)       { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin)      { create(:user, admin: true) }  
  
  describe 'actions' do    
    
    describe 'GET #new' do
      def new_timesheet
        log_in user
        get :new
      end

      def new_timesheet_with_params
        log_in user
        get :new, timesheet_start: Time.zone.now, timesheet_finish: Time.zone.now
      end
            
      it "creates a new instance of @timesheet" do
        new_timesheet
        expect(assigns(:timesheet)).not_to be_nil
      end

      it "sets @timesheet.start_time from params" do
        new_timesheet_with_params
        expect(assigns(:timesheet).start_time).not_to be_nil
      end

      it "sets @timesheet.end_time from params" do
        new_timesheet_with_params
        expect(assigns(:timesheet).end_time).not_to be_nil
      end

      it "doesn't set @timesheet attributes when no params" do
        new_timesheet
        expect(assigns(:timesheet).start_time).to be_nil
      end

      it "renders the :new template" do
        new_timesheet
        expect(response).to render_template(:new)
      end
    end
    
    describe 'POST #create' do
      
      let(:timesheet) { build(:timesheet) }
      
      def create_timesheet_for(a_user)
        post :create, 
          timesheet: { 
            user_id: a_user.id, 
            start_time: timesheet.start_time, 
            end_time: timesheet.end_time, 
            comments: timesheet.comments 
          }
      end
      
      before(:each) { log_in user }
            
      it "creates a new Timesheet instance" do
        create_timesheet_for(user)
        expect(assigns(:timesheet)).not_to be_nil
      end
      
      it "redirects if current user isn't the timesheet's user or an admin" do
        log_in other_user
        create_timesheet_for(user)
        expect(response).to redirect_to(user_path(other_user))        
      end
      
      it "passes if current user is the timesheet's user or an admin" do
        log_in admin
        expect { 
          create_timesheet_for(user) 
        }.to change { Timesheet.count }.by(1)
      end
      
      context "successful save" do        
                
        it "saves a new record" do
          expect {
           create_timesheet_for(user)
          }.to change { Timesheet.count }.by(1)
        end
        
        before(:each) { create_timesheet_for user }
        
        it "displays a success flash" do
          expect(flash[:success]).to be_present
        end
        
        it "redirects to the user page" do
          expect(response).to redirect_to(user_path(user))
        end
      end
      
      context "unsuccessful save" do
        
        it "renders the :new template" do
          # Attempt to save timesheet where end is earlier than start.
          post :create, 
            timesheet: { 
              user_id:    user.id, 
              start_time: Time.zone.now, 
              end_time:   Time.zone.now - 2.hours 
            }
          expect(response).to render_template(:new)
        end
      end      
    end
    
    describe 'GET #show' do
      
      let(:supervisor) { create(:user).supervisees << timesheet.user }
      
      def show_user_timesheet
        get :show, id: timesheet.id
      end
      
      it "creates an instance of Timesheet" do
        show_user_timesheet
        expect(assigns(:timesheet)).to be_an_instance_of(Timesheet)
      end
      
      it "passes if current user is user" do
        log_in(timesheet.user)
        show_user_timesheet
        expect(response).not_to redirect_to(user_path(timesheet.user))
      end      

      it "passes if current user is user's supervisor" do
        supervisor = create(:user)
        log_in(supervisor)
        supervisor.supervisees << timesheet.user        
        show_user_timesheet
        expect(response).not_to redirect_to(user_path(supervisor))
      end
      
      it "passes if current user is admin" do
        log_in(admin)
        show_user_timesheet
        expect(response).not_to redirect_to(user_path(admin))
      end
      
      it "redirects if current user is not user, 
        user's supervisor, or admin" do
        log_in(other_user)
        show_user_timesheet
        expect(response).to redirect_to(user_path(other_user))
      end
      
      it "renders the :show template" do
        log_in timesheet.user
        show_user_timesheet
        expect(response).to render_template(:show)
      end
    end
    
    describe 'GET #edit' do
      
      def edit_timesheet
        get :edit, id: timesheet.id
      end
      
      it "creates an instance of Timesheet" do
        edit_timesheet
        expect(assigns(:timesheet)).to be_an_instance_of(Timesheet)
      end
      
      it "passes if current_user is user" do
        log_in timesheet.user
        edit_timesheet
        expect(response).not_to redirect_to(user_path(timesheet.user))
      end
      
      it "passes if current_user is admin" do
        log_in admin
        edit_timesheet
        expect(response).not_to redirect_to(user_path(admin))
      end
      
      it "redirects to user page if current_user is not user or admin" do
        log_in other_user
        edit_timesheet
        expect(response).to redirect_to(user_path(other_user))
      end
      
      it "renders the :edit template" do
        log_in timesheet.user
        edit_timesheet
        expect(response).to render_template(:edit)
      end
    end
    
    describe 'PUT #update' do
      
      def update_timesheet
        put :update, 
          id: timesheet.id, 
          timesheet: { 
            start_time: Time.new(2014, 2, 4) 
          }
        timesheet.reload
      end
      
      it "passes if current_user is user" do
        log_in timesheet.user
        expect { update_timesheet }.to change(timesheet, :start_time)
      end
      
      it "passes if current_user is admin" do
        log_in admin
        expect { update_timesheet }.to change(timesheet, :start_time)
      end
      
      it "redirects if current_user is not user or admin" do
        log_in other_user
        expect { update_timesheet }.not_to change(timesheet, :start_time)
      end
      
      it "creates an instance of Timesheet" do
        update_timesheet
        expect(assigns(:timesheet)).to be_an_instance_of(Timesheet)
      end
      
      context "successful update and save" do
        
        it "updates the record in the database" do
          # Already tested
        end
        
        before(:each) do
          log_in timesheet.user
          update_timesheet
        end
        
        it "displays a success flash" do
          expect(flash[:success]).to be_present          
        end
        
        it "redirects to user page" do
          expect(response).to redirect_to(user_path(timesheet.user))
        end        
      end
      
      context "unsuccessful save" do
        
        def invalid_update
          put :update, 
            id: timesheet.id, 
            timesheet: { 
              start_time: Time.zone.now 
            }
        end
        
        before(:each) { log_in timesheet.user }
        
        it "does not update the record" do
          expect { invalid_update }.not_to change(timesheet, :start_time)
        end
        
        it "renders the :edit template" do
          invalid_update
          expect(response).to render_template(:edit)
        end
      end      
    end
    
    describe 'DELETE #destroy' do
      
      def destroy_timesheet
        delete :destroy, id: timesheet.id
      end
      
      before(:each) { log_in timesheet.user }
      
      it "creates an instance of Timesheet" do
        destroy_timesheet
        expect(assigns(:timesheet)).to be_an_instance_of(Timesheet)
      end
      
      it "finds timesheet by id in params" do
        destroy_timesheet
        expect(assigns(:timesheet).id).to eq(timesheet.id)
      end
      
      it "passes if current user is user" do
        expect { destroy_timesheet }.to change(Timesheet, :count).by(-1)
      end
      
      it "passes if current user is admin" do
        log_in admin
        expect { destroy_timesheet }.to change(Timesheet, :count).by(-1)
      end
      
      it "does not delete timesheet record if 
        current user is not user or admin" do
        log_in other_user
        expect { destroy_timesheet }.not_to change(Timesheet, :count)
      end
      
      it "deletes the timesheet record in the database" do
        # Tested in 'passes if current user is user'
      end
      
      it "displays a success flash" do
        destroy_timesheet
        expect(flash[:success]).to be_present
      end
      
      it "redirects to user page" do
        user = timesheet.user
        destroy_timesheet
        expect(response).to redirect_to(user_path(user))
      end
    end    
  end
end