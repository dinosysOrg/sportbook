FactoryGirl.define do
  factory :tournament do
    name { FFaker::Lorem.words(3).join(' ') }
    start_date { DateTime.now }
    end_date { DateTime.now }
  end
end
