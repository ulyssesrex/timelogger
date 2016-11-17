require 'faker'

FactoryGirl.define do 
  factory :organization do
    name                  'Organization'
    password              'password'
    password_confirmation 'password'
    password_digest       User.digest('password')    
    
    after(:create) do |organization|
      organization.users << create(:user, admin: true)  
      organization.activation_token  = Organization.new_token
      organization.update(activation_digest: Organization.digest(organization.activation_token))
    end
    
    factory :organization_with_reset_info do
      reset_token   { User.new_token }
      reset_sent_at { Time.zone.now  }
      after(:create) do |organization|
        organization.update_attribute(
          :reset_digest, 
          User.digest(organization.reset_token)
        )
      end
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