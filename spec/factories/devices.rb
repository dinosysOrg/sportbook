FactoryGirl.define do
  factory :device do
    user
    token SecureRandom.uuid
    platform %w[iOS Android].sample
  end
end
