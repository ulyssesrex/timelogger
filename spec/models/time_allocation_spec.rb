require 'rails_helper'

describe TimeAllocation do
 	describe "factory" do
 		it { expect(build(:time_allocation)).to be_valid }
 	end

 	describe "associations" do
 		it { should belong_to(:grantholding) }
 		it { should belong_to(:timelog) }
 	end

 	describe "public instance methods" do
 		describe "#to_grant?" do
 			let(:organization)    { 
 				create(:organization) 
 			}
 			let(:grant) 			    { 
 				create(:grant, organization: organization) 
 			}
 			let(:other_gr) 		    { 
 				create(:grant, name: "Other Grant", organization: organization) 
 			}
 			let(:user) 				    { 
 				create(:user, organization: organization)  
 			}
 			let(:grantholding)    { 
 				create(:grantholding, user: user) 
 			}
 			let(:other_g) 		    { 
 				create(:grantholding, user: user, grant: other_gr)   
 			}
 			let(:time_allocation) { 
 				create(:time_allocation, grantholding: grantholding) 
 			}
 			let(:other_ta) 		    { 
 				create(:time_allocation, grantholding: other_g) 
 			}

 			it "returns true if its user's grant matches specified grant" do
 				expect(time_allocation.to_grant?(grant.name)).to be true
 			end

 			it "returns false if its user's grant doesn't match specified grant" do
 				expect(other_ta.to_grant?(grant.name)).to be false
 			end
 		end
 	end
end 