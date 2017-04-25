FactoryGirl.define do
  factory :venue do
    name { FFaker::AddressFI.street_name }
  end
end
