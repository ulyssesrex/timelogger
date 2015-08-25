require 'faker'

FactoryGirl.define do
  factory :time_allocation do
    grantholding
    timelog
    comments { Faker::Lorem.paragraph }
    start_time Time.new(2014, 2, 5).advance(hours: 1)
    end_time   Time.new(2014, 2, 5).advance(hours: 2)

    trait :invalid do
      start_time { timelog.start_time.change(year: 2000) }
      end_time   { timelog.start_time.advance(hours: 1)  }
    end 
  end
end