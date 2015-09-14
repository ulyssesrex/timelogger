require 'faker'

FactoryGirl.define do
  factory :time_allocation do
    grantholding
    timelog
    comments { Faker::Lorem.paragraph }
    hours 1.0
  end
end