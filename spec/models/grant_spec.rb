require 'rails_helper'

describe Grant do 
  let(:grant) { create(:grant) }

  it "has a valid factory" do
    expect(grant).to be_valid
  end
  
  describe "relationship associations" do
    let(:grant) { create(:grant_with_grantholdings) }
    
    it "destroys associated records upon its own destruction" do
      expect(grant.grantholdings).not_to be_empty
      grant.destroy
      expect(grant.grantholdings).to be_empty
    end

      
  end
end
      