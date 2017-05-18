FactoryGirl.define do
  factory :skill do
    name { FFaker::Lorem.words(3).join(' ') }
  end
end
