FactoryGirl.define do
  factory :time_slot do |t|
    t.object { |a| a.association(:team) }
    time { DateTime.now.at_beginning_of_hour }
    available true
  end
end
