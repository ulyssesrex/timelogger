require 'faker'

FactoryGirl.define do 
  factory :organization do
    name                  'Organization'
    password              'password'
    password_confirmation 'password'
    password_digest       { User.digest('password') }
    
    after(:create) do |organization|
      organization.users << create(:user)      
    end
  
    factory :organization_2 do
      name 'Organization2'
      password 'password'
      password_confirmation 'password'
      password_digest { User.digest('password') }
    end
    
    trait :with_users do
      after(:create) do |organization|
        organization.users << create(:user)
      end
    end
    
    trait :with_grants do
      after(:create) do |organization|
        organization.grants << create(:grant)
      end
    end
    
    trait :fully_loaded do
      with_users
      with_grants
    end
  end
end