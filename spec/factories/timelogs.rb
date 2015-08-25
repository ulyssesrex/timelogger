require 'faker'

FactoryGirl.define do
  factory :timelog do    
    user
    start_time { Time.new(2014, 2, 5) }
    end_time   { start_time.advance(hours: 8) }
    transient do
      time_allocations_count 0
    end

    after(:create) do |timelog, evaluator|
      create_list(:time_allocation,
                  evaluator.time_allocations_count,
                  timelog: timelog
                  )
    end
    
    factory :timelog_with_comments do
      comments   { Faker::Lorem.paragraph }
    end
  end
end