FactoryGirl.define do
  factory :time_slot do |t|
    t.object { |a| a.association(:team) }
    time { Time.zone.now.at_beginning_of_hour }
    available true
  end
end
