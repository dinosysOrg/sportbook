FactoryGirl.define do
  factory :match do
    group
    team_a { team }
    team_b { team }
  end
end
