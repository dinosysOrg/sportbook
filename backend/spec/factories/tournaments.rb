FactoryGirl.define do
  factory :tournament do
    name { FFaker::Lorem.words(3).join(' ') }
  end
end
