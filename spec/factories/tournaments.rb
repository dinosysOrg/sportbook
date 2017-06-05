FactoryGirl.define do
  factory :tournament do
    name { FFaker::Lorem.words(3).join(' ') }
    start_date { Time.zone.now }
    end_date { Time.zone.now }
  end
end
