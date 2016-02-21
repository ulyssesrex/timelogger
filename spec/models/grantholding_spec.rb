require 'rails_helper'

describe Grantholding do 
  let(:grantholding) { create :grantholding, :with_time_allocations }
  let(:user)         { create(:user) }
  let(:other_user)   { create(:user) }
  let(:grant)        { create(:grant) }
  
  it "has a valid factory" do
    expect(create(:grantholding)).to be_valid
  end
  
  describe "associations" do
    
    before(:each) do
      @gh = create(:grantholding, grant_id: grant.id, user_id: user.id)
    end
    
    it "has a read-only grant attribute" do
      expect {
        @gh.update_column(:grant_id, grant.id + 1) 
      }.to raise_error(ActiveRecord::ActiveRecordError, 'grant_id is marked as readonly')
    end
    
    it "has a read-only user attribute" do
      expect { 
        @gh.update_column(:user_id, other_user.id) 
      }.to raise_error(ActiveRecord::ActiveRecordError, 'user_id is marked as readonly')
    end
  end
  
  describe "validations" do
    let(:user)  { create(:user)  }
    let(:grant) { create(:grant) }
    
    it "is invalid without grant" do
      expect(
        build(:grantholding, user_id: user.id, grant_id: nil)
      ).not_to be_valid
    end
    
    it "is invalid without user" do
      expect(
        build(:grantholding, user_id: nil, grant_id: grant.id)
      ).not_to be_valid
    end
    
    it "is only valid with both grant and user" do
      expect( 
        build(:grantholding, user_id: user.id, grant_id: grant.id)
      ).to be_valid
    end
  end

  describe "conditions set after initialize" do
    let(:grantholding) { create(:grantholding) }

    it "sets required hours to 0.0 by default" do
      expect(grantholding.required_hours).to eq 0.0
    end

    it "does not have a default value of nil for required_hours" do
      expect(grantholding.required_hours).not_to be_nil
    end
  end  
end