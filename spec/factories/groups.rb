FactoryGirl.define do
  factory :group do
    tournament
    name { "#{('A'..'Z').to_a.sample}#{(1..16).to_a.sample}" }
    start_date { Date.today }
  end
end
