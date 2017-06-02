FactoryGirl.define do
  factory :device do
    user
    token SecureRandom.uuid
    platform [0, 1].sample
  end
end
