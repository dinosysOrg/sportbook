FactoryGirl.define do
  factory :player do
    user { create(:api_user) }
    tournament
  end
end
