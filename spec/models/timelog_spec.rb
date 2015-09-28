require 'rails_helper'

describe Timelog do  
  let(:timelog) { create(:timelog) }
  let(:ts_alloc)  { create(:timelog, time_allocations_count: 1) }
  
  describe 'factory' do
    it { expect(build(:timelog)).to be_valid }
    it { expect(build(:timelog_with_comments)).to be_valid }
    it { expect(build(:timelog_yesterday)).to be_valid }
    it { expect(build(:timelog_with_time_allocations, time_allocations_count: 2)).to be_valid }
  end
  
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:time_allocations) }
    it { should have_many(:grantholdings).through(:time_allocations) }
  end 
  
  describe 'validations' do    
    it 'rejects without user_id' do
      expect(build(:timelog, user_id: nil)).not_to be_valid
    end

    it 'rejects without start_time' do
      expect(
        build(:timelog, start_time: nil, end_time: Time.zone.now)
      ).not_to be_valid
    end

    it 'rejects without end_time' do
      expect(build(:timelog, end_time: nil)).not_to be_valid
    end
    
    it 'rejects when start_time > end_time' do
      expect(build(:timelog, end_time:   Time.zone.now, 
                               start_time: Time.zone.now
                               ))
      .not_to be_valid
    end
  end
  
  describe 'default scope' do
    let(:a_start) { Time.new(2015, 1, 1) }
    let(:a_end)   { a_start.advance(hours: 8) }
    let(:b_start) { Time.new(2015, 2, 1) }
    let(:b_end)   { b_start.advance(hours: 8) }
     
    before(:example) do
      @b_created_first = create(:timelog, 
                           start_time: b_start, 
                           end_time: b_end
                         )
      @a_created_second = create(:timelog, 
                            start_time: a_start, 
                            end_time: a_end
                          )
    end
    
    it "orders timelog records from most recent to earliest" do
      expect(Timelog.all.first.end_time).to eq(@a_created_second.end_time)
    end
  end  
end