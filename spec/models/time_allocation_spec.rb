require 'rails_helper'

describe TimeAllocation do
  let(:valid_time_allocation)   { build(:time_allocation) }
  let(:invalid_time_allocation) { build(:time_allocation, :invalid) }
  
  it "accepts a valid time range" do        
    expect(valid_time_allocation).to be_valid
  end
  
  it "rejects an invalid time range" do
    expect(invalid_time_allocation).not_to be_valid
  end
end 