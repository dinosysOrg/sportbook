FactoryGirl.define do
  factory :time_slot do
    venue
    time { DateTime.now.at_beginning_of_hour }
  end
end
