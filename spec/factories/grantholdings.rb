require 'faker'

FactoryGirl.define do
  factory :grantholding do
    user
    grant
    required_hours 8
    
    trait :with_time_allocations do
      after(:create) do |grantholding|
        grantholding.time_allocations << create(:time_allocation, :valid)
      end
    end   
  end
end
    