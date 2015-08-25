require 'rails_helper'

describe User do
  let(:user) { create(:user) }
  let(:token) { User.new_token }
  
  describe 'factory' do
    it { expect(build(:user)).to be_valid }
    it { expect(build(:user, admin: true)).to be_valid }
    it { expect(build(:user, :with_grantholdings)).to be_valid }
    it { expect(build(:user, :supervisor)).to be_valid }
    it { expect(build(:user, :supervisee)).to be_valid }
    it { expect(build(:user, :intermediate)).to be_valid }
  end
  
  describe 'callbacks' do
    it { expect(create(:user, email: 'FOO@bar.com').email).to eq('foo@bar.com')}
    it { expect(create(:user).activation_digest).not_to be(nil) }
  end
   
  describe 'validations' do
    it { expect(build(:user, first_name: nil)).not_to be_valid }
    it { expect(build(:user, last_name: nil)).not_to be_valid }
    it { expect(build(:user, email: nil)).not_to be_valid }
    it { expect(build(:user, email: 'd' * 250 + '@o.com')).not_to be_valid }
    it { expect(build(:user, email: 'foo@bar')).not_to be_valid }
    before(:example) { create(:user, email: 'foo@bar.com') }       
    it { expect(build(:user, email: 'foo@bar.com')).not_to be_valid }
    DatabaseCleaner.clean    
    it { expect(build(:user, password: nil)).not_to be_valid }
    it { expect(build(:user, password: '*' * 5)).not_to be_valid }
    it { expect(build(:user, password_confirmation: 'not_password'))
         .not_to be_valid
       }    
  end  
      
  describe 'associations' do
    it { should belong_to(:organization) }
    it { should have_many(:grantholdings) }
    it { should have_many(:grants).through(:grantholdings) }
    it { should have_many(:initiated_supervisions)
         .class_name('Supervision')
         .dependent(:destroy) 
       }
    it { should have_many(:non_initiated_supervisions)
         .class_name('Supervision')
         .dependent(:destroy) 
       }
    it { should have_many(:supervisors)
         .through(:initiated_supervisions)
         .class_name('User') 
       }
    it { should have_many(:supervisees)
         .through(:non_initiated_supervisions)
         .class_name('User') 
       }
    it { should have_many(:timelogs) }
    
    let(:nested_user) do 
      create(:user, 
             :with_timelogs, 
             :with_grantholdings)
    end   
  end
  
  describe 'public instance methods' do
    context 'responds to its methods' do      
      it { expect(user).to respond_to(:activate) }
      it { expect(user).to respond_to(:authenticated?) }
      it { expect(user).to respond_to(:remember) }
      it { expect(user).to respond_to(:forget) }
    end
    
    context 'executes its methods correctly' do    
      let(:supervisor) { create(:user, :supervisor) }
      let(:supervisee) { supervisor.supervisees.first }  
      
      context '#activate' do        
        it 'toggles the activated column to true' do
          expect(user.activated?).to eq(true)
        end
        
        it 'sets the activated_at column to the current time' do
          expect(user.activated_at).to be < Time.zone.now
        end
      end
      
      context '#authenticated?' do        
        it 'returns false if activation digest is nil' do
          user.activation_digest = nil
          expect(user.authenticated?(:activation, 'nil')).to eq(false)
        end
        
        it 'returns false if the token does not produce the digest' do
          user.activation_digest = User.digest(token)
          expect(user.authenticated?(:activation, 'bad token')).to eq(false)
        end
 
        it 'returns true if the token produces the digest' do
          user.activation_digest = User.digest(token)
          expect(user.authenticated?(:activation, token)).to eq(true)
        end
      end
      
      context "#supervises?" do        
        it "returns true if user is another user's supervisor" do
          expect(supervisor.supervises?(supervisee)).to be true
        end
        
        it "returns false if user is not another user's supervisor" do
          expect(supervisee.supervises?(supervisor)).to be false
        end
      end
      
      context "#is_supervisee_of?" do
        it "returns true if user is another user's supervisee" do
          expect(supervisee.is_supervisee_of?(supervisor)).to be true
        end
        
        it "returns false if user is not another user's supervisee" do
          expect(supervisor.is_supervisee_of?(supervisee)).to be false
        end
      end
      
      context '#remember' do
        it 'creates a remember token attibute' do
          expect { user.remember }.to change { user.remember_digest }
        end
        
        it 'updates the remember_digest attribute to 
          a hashed version of the remember_token' do
          user.remember
          expect(user.remember_digest.size).to eq(60)
        end
      end
      
      context '#forget' do
        it 'updates the remember digest to nil' do
          user.forget
          expect(user.remember_digest).to be_nil
        end
      end
      
      context '#add_supervisor' do
        let(:supervisor) { create(:user) }
        
        it 'creates an initiated supervision for the user' do
          expect { 
            user.add_supervisor(supervisor) 
          }.to change { user.initiated_supervisions.count }.by(1)
        end
        
        it 'makes another user the current users supervisor' do
          user.add_supervisor(supervisor)
          expect(user.supervisors).to include(supervisor)
        end
      end
      
      context '#delete_supervisor' do
        let(:supervisee) { create(:user, :supervisee) }
        let(:supervisor) { supervisee.supervisors.first }
        
        it 'deletes an initiated supervision for the user' do
          expect {
            supervisee.delete_supervisor(supervisor)            
          }.to change { supervisee.initiated_supervisions.count }.by(-1)
        end
        
        it 'removes supervisor status from a supervisor of the current user' do
          supervisee.delete_supervisor(supervisor)
          supervisee.reload
          expect(supervisee.supervisors).not_to include(supervisor)
        end
      end
      
      context '#delete_supervisee' do
        let(:supervisor) { create(:user, :supervisor) }
        let(:supervisee) { supervisor.supervisees.first }
        
        it 'deletes a non-initiated supervision for the user' do
          expect { 
            supervisor.delete_supervisee(supervisee) 
          }.to change { supervisor.non_initiated_supervisions.count }.by(-1)
        end
        
        it 'removes supervisee status from a supervisee of the current user' do
          supervisor.delete_supervisee(supervisee)
          supervisor.reload
          expect(supervisor.supervisees).not_to include(supervisee)
        end
      end
      
      context '#total_hours_worked' do
        let(:now) { Time.zone.now }        
        let(:user_with_timelogs) { create(:user, :with_timelogs) }
        
        it 'totals all specified timelogs within date range' do
          expect( 
            user_with_timelogs.total_hours_worked(Time.new(2014), now) 
          ).to eq(8)
        end
        
        it 'does not total timelogs outside date range' do
          user_with_timelogs.timelogs <<
            create(:timelog, 
                   user_id: user.id, 
                   start_time: now - 6.hours, 
                   end_time: now - 5.hours
                   )
          expect(
            user_with_timelogs
            .total_hours_worked(Time.new(2014), Time.new(2015))
          ).to eq(8)
        end
      end
      
      context '#send_user_activation_email' do
        it 'sends an email to the user' do
          expect { 
            user.send_user_activation_email 
          }.to change { ActionMailer::Base.deliveries.size }.by(1)
        end
      end
      
      context '#feed' do
        let(:current_user) { create(:user, :with_timelogs, :intermediate) }
        
        it 'returns the current users timelogs' do
          expect(current_user.feed).to eq(current_user.timelogs)
        end
        
        let(:supervisee) { current_user.supervisees.first }
        it 'returns the current users supervisees timelogs' do          
          supervisee.timelogs << create(:timelog)
          expect(current_user.feed).to include(supervisee.timelogs.first)
        end
        
        let(:supervisor) { current_user.supervisors.first }
        it 'does not return other timelogs' do
          supervisor.timelogs << create(:timelog)
          expect(current_user.feed).not_to include(supervisor.timelogs.first)
        end
      end
      
      context '#create_reset_digest' do
        let(:crd) { user.create_reset_digest }
        
        it "updates user's :reset_token virtual attribute" do
          expect { crd }.to change { user.reset_token }
        end
      
        it "updates user's reset_digest column" do
          expect { crd }.to change { user.reset_digest }
        end
        
        it "updates user's reset_sent_at column" do
          expect { crd }.to change { user.reset_sent_at }
        end
      end
      
      context '#send_password_reset_email' do
        it "sends a password reset message to the user's email" do
          expect { 
            user.send_password_reset_email 
          }.to change { ActionMailer::Base.deliveries.size }.by(1)
      end
      
      context '#password_reset_expired?' do
        context "reset email was sent more than or equal to two hours ago" do          
          it "returns true" do
            user.update_attribute(:reset_sent_at, 2.hours.ago)
            expect(user.password_reset_expired?).to be(true)
          end
        end
        
        context "reset email was sent less than two hours ago" do
          it "returns false" do
            user.update_attribute(:reset_sent_at, Time.zone.now)
            expect(user.password_reset_expired?).to be(false)
          end
        end
      end      
    end
  end
  
  describe 'public class methods' do
    context 'responds to its methods' do
      it { expect(User).to respond_to(:digest) }
      it { expect(User).to respond_to(:new_token) }
    end
    
    context 'executes its methods correctly' do      
      context 'User.digest' do
        it 'returns a string' do
          expect(User.digest(token)).to be_a(String)
        end
        
        it 'returns a random digest' do
          expect(User.digest(token)).not_to eq(User.digest(User.new_token))
        end
      end
      
      context 'User.new_token' do
        it 'returns a 22-character string' do
          expect(token.length).to eq(22)
        end
        
        it 'returns a random string' do
          expect(token).not_to eq(User.new_token)
        end
      end
    end
  end
end
end
