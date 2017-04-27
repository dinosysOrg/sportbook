FactoryGirl.define do
  factory :team do
    tournament
    name { FFaker::Name.name }
  end
end
