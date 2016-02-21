require 'rails_helper'

describe TimelogsController do
  
  let(:organization)   { create(:organization) }
  let(:grant_1)        { create(:grant, organization: organization) }
  let(:grant_2)        { create(:grant, organization: organization) }
  let(:user)           { create(:user,  organization: organization) }
  let(:other_user)     { create(:user,  organization: organization) }
  let(:admin)          { create(:user,  organization: organization, admin: true) }
  let(:timelog)        { create(:timelog, user: user) }
  let(:timelog_yesterday) { create(:timelog_yesterday, user: user) }
  let(:grantholding_1) { create(:grantholding, user: user, grant: grant_1) }
  let(:grantholding_2) { create(:grantholding, user: user, grant: grant_2)}
  let(:timelog_attributes) do
    {
      :user_id    => user.id,
      :start_time => '2014-02-05 09:00:00 -0500',
      :end_time   => '2014-02-05 17:00:00 -0500',
      :comments   => 'This is a timelog.',
      :time_allocations_attributes => {
        '0' => {
          hours: 1.0,
          comments: 'Worked one hour.',
          grantholding_id: grantholding_1.id
        },
        '1' => {
          hours: 2.0,
          comments: 'Worked two hours.',
          grantholding_id: grantholding_2.id
        }
      }
    }
  end
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
        expect(assigns(:timelog).start_time).not_to be_nil
      end

      it "sets end_time field value from params" do
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
        post :create, user_id: user.id, timelog: timelog_attributes
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
          timelog_attributes[:start_time] = Time.zone.now
          timelog_attributes[:end_time]   = Time.zone.now - 2.hours
          post :create, user_id: user.id, timelog: timelog_attributes
          expect(response).to render_template(:new)
        end
      end      
    end

    describe "GET #index" do
      def get_index
        get :index, user_id: user.id
      end

      before(:each) do 
        timelog; timelog_yesterday
        log_in user
        get_index
      end

      it "sets @start_date_table to a Time object" do
        expect(assigns(:start_date_table)).to be_an_instance_of(Time)
      end

      it "sets @start_date_table to two Mondays ago" do
        expect(assigns(:start_date_table).strftime("%A")).to eq('Monday')
      end

      it "sets @end_date_table to a Time object" do
        expect(assigns(:end_date_table)).to be_an_instance_of(Time)
      end

      it "sets @end_date_table to now" do
        expect(assigns(:end_date_table).strftime("%R")).to eq(Time.now.strftime("%R"))
      end

      it "creates an instance of Timelog" do
        expect(assigns(:timelogs).take).to be_an_instance_of(Timelog)
      end

      it { expect(assigns(:timelogs).take.user_id).to eq(user.id) }

      it { expect(assigns(:grantholdings).count).to eq(user.grantholdings.count) }

      it "renders :index template" do
        expect(response).to render_template(:index)
      end
    end

    describe "POST #filter_index" do
      def index_ordered_old_first
        post :filter_index, 
          user_id: user.id, 
          order: 'oldfirst',
          format: :js
      end

      def index_filtered_by_date
        post :filter_index, 
          user_id: user.id, 
          start_date_table: '2/1/2014', 
          end_date_table: '2/10/2014',
          format: :js
      end

      it "converts start date param to a Time object" do
        log_in user
        index_ordered_old_first
        expect(assigns(:start_date_table)).to be_an_instance_of(Time)
      end

      it "converts end date param to a Time object" do
        log_in user
        index_filtered_by_date
        expect(assigns(:end_date_table)).to be_an_instance_of(Time)
      end
    end

    describe "POST #day_index" do
      def post_day_index
        post :day_index, user_id: user.id, date: '2014-2-5', format: :js
      end

      before(:each) do
        timelog; timelog_yesterday
        log_in user
        post_day_index
      end

      it "assigns a User" do
        expect(assigns(:user)).to eq(user)
      end

      it "assigns the correct Date" do
        expect(assigns(:date)).to eq(Date.parse('2014-2-5'))
      end

      it "displays the correct Timelogs" do
        expect(assigns(:timelogs_on_day).count).to eq(1)
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
        expect(response).to redirect_to(user_timelogs_path(user: user))
      end
    end    
  end
end