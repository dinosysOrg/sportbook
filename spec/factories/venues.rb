FactoryGirl.define do
  factory :venue do
    name { FFaker::AddressFI.street_name }
    google_calendar_name { 'q240vu0q51lkmbbq70e8f2i344@group.calendar.google.com' }
  end
end
