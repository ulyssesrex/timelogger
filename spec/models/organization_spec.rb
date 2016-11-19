require 'rails_helper'

describe Organization do 
  let(:org) { create(:organization) }
  
  it "has a valid factory" do
    expect(org).to be_valid
  end
  
  describe "relationship associations" do
    let(:org) { create(:organization, :fully_loaded) }
    
    it "destroys associated users upon its own destruction" do      
      users = org.users
      org.destroy
      expect(users).to be_empty
    end
    
    it "destroys associated grants upon its own destruction" do
      grants = org.grants
      org.destroy
      expect(grants).to be_empty
    end
    
    it { should accept_nested_attributes_for :users }
  end
  
  describe "validations" do
    let(:no_name_org)     { build(:organization, name: nil) }
    let(:no_password_org) { build(:organization, password: nil) }
  
    it "requires presence of name" do
      expect(no_name_org).not_to be_valid
    end
    
    it "requires presence of keyword" do
      expect(no_password_org).not_to be_valid
    end

    it "does not require password upon update" do
      updated_params = { name: "Different Name" }
      org.update(updated_params)
      expect(org).to be_valid
    end
  end
end