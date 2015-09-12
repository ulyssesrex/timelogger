require 'faker'

FactoryGirl.define do
  
  factory :grant do
    name     "Grant"
    comments "Comments."
    organization_id 1
    
    factory :grant_with_grantholdings do
      after(:create) { |grant| grant.grantholdings << create(:grantholding) }
    end   
  end
end