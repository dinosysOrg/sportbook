FactoryGirl.define do
  factory :device do
    device_id { SecureRandom.hex(8) }
    user
    token { SecureRandom.uuid }
    platform [0, 1].sample
  end
end
