require 'faker'

FactoryGirl.define do
  factory :grantholding do
    user
    grant
    
    trait :with_time_allocations do
      after(:create) do |grantholding|
        grantholding.time_allocations << create(:time_allocation, :valid)
      end
    end   
  end
end
    