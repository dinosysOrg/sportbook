FactoryGirl.define do
  factory :groups_team do
    group
    team { build(:team, tournament: group.tournament) }
    order { rand(5) }
  end
end
