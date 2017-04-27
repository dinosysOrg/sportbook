FactoryGirl.define do
  factory :team do
    tournament
    name { FFaker::Name.name }
    trait :has_players do
      after(:create) do |team|
        create_list :player, 1, team: team
      end
    end
  end
end
