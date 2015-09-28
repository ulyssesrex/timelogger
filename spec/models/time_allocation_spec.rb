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
 				create(:grant, organization_id: organization.id) 
 			}
 			let(:other_gr) 		    { 
 				create(:grant, name: "Other Grant", organization_id: organization.id) 
 			}
 			let(:user) 				    { 
 				create(:user, organization_id: organization.id)  
 			}
 			let(:grantholding)    { 
 				create(:grantholding, user: user, grant: grant) 
 			}
 			let(:other_g) 		    { 
 				create(:grantholding, user: user, grant: other_gr)   
 			}
 			let(:timelog) {
 				create(:timelog, user: user)
 			}
 			let(:time_allocation) { 
 				create(:time_allocation, grantholding: grantholding, timelog: timelog) 
 			}
 			let(:other_ta) 		    { 
 				create(:time_allocation, grantholding: other_g, timelog: timelog) 
 			}

 			before(:each) do
 				organization; user
 				grant; other_gr
 				grantholding; other_g
 				time_allocation; other_ta
 			end

 			it "returns true if its user's grant matches specified grant" do
 				expect(time_allocation.to_grant?(grant)).to be true
 			end

 			it { expect(other_ta.to_grant?(other_gr)).to be true }

 			it "returns false if its user's grant doesn't match specified grant" do
 				expect(other_ta.to_grant?(grant.name)).to be false
 			end
 		end
 	end
end 