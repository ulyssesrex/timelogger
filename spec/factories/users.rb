require 'faker'

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    position   { Faker::Name.title }
    email      { Faker::Internet.email }
    password              'password'
    password_confirmation 'password'
    activated true
    activated_at      { Time.zone.now }
    activation_digest { User.digest(User.new_token) }
    password_digest   { User.digest('password') }
    organization_id   1
    organization_name 'Organization'
    organization_password 'password'
    
    factory :user_2 do
      organization_id 2
      organization_name 'Organization2'
      organization_password 'password'
    end
    
    factory :supervisor do
      after(:create) do |supervisor|
        supervisor.supervisees << create(:user, organization: supervisor.organization)
      end
    end

    factory :user_with_reset do
      reset_token   { User.new_token }
      reset_digest  { User.digest(reset_token) }
      reset_sent_at { Time.zone.now }
    end   
    
    trait :new do
      activated false
    end
    
    trait :with_remembering do
      remember_token  { nil }
      remember_digest { nil }
    end

    trait :with_grantholdings do    
      after(:create) do |user|
        user.grantholdings << create(:grantholding)
      end
    end
    
    trait :with_timelogs do
      after(:create) do |user|
        user.timelogs << create(:timelog)
      end
    end
    
    
    trait :supervisee do
      after(:create) do |user|
        user.supervisors << create(:user)        
      end
    end
    
    trait :intermediate do
      after(:create) do |user|
        user.supervisors << create(:user)
        user.supervisees << create(:user)
      end
    end
  end
end

    