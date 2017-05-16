FactoryGirl.define do
  sequence :team_name do |n|
    "#{FFaker::Name.name}#{n}"
  end

  factory :team do
    tournament
    name { generate(:team_name) }
    status Team.statuses[:registered]
    venue_ranking (1..4).to_a
    trait :has_players do
      after(:create) do |team|
        create_list :player, 1, team: team
      end
    end
  end
end
