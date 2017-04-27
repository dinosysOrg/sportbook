FactoryGirl.define do
  factory :groups_team do
    group
    team { create(:team, :has_players, tournament: group.tournament) }
    order { rand(5) }
  end
end