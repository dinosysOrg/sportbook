FactoryGirl.define do
  factory :time_slot do |t|
    t.object { |a| a.association(:team) }
    time { Time.now.at_beginning_of_hour }
  end
end
