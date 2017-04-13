FactoryGirl.define do
  factory :team do
    name { FFaker::Name.name }
    group

    before(:create) do |team|
      team.tournament = team.group.try(:tournament)
    end
  end
end
