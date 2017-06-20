FactoryGirl.define do
  factory :device do
    udid { SecureRandom.hex(8) }
    user
    token { SecureRandom.uuid }
    platform [0, 1].sample
  end
end
