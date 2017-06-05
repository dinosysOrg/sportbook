FactoryGirl.define do
  factory :match do
    group
    team_a { create(:groups_team, group: group).team }
    team_b { create(:groups_team, group: group).team }
    time { Time.zone.now }
    venue
    code { "#{('A'..'Z').to_a.sample}-#{(1..9).to_a.sample}-#{(1..9).to_a.sample}" }
  end
end
