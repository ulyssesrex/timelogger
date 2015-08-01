FactoryGirl.define do
  factory :supervision do
    association :supervisor, factory: :user
    association :supervisee, factory: :user
  end
end