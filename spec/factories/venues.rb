FactoryGirl.define do
  sequence :venue_name do |n|
    "#{FFaker::AddressFI.street_name}#{n}"
  end

  factory :venue do
    name { generate(:venue_name) }
    google_calendar_name { 'q240vu0q51lkmbbq70e8f2i344@group.calendar.google.com' }
  end
end
