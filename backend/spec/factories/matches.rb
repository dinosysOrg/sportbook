FactoryGirl.define do
  factory :match do
    group
    team_a { create(:groups_team, group: group).team }
    team_b { create(:groups_team, group: group).team }
    time { DateTime.now }
    venue
  end
end
