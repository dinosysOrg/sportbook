FactoryGirl.define do
  factory :time_block do
    preferred_time { { 'tuesday' => [[9, 10, 11]] } }
  end
end
