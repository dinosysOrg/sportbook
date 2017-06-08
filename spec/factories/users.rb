FactoryGirl.define do
  factory :user do
    provider 'email'
    uid { FFaker::Internet.email }
    email { FFaker::Internet.email }
    name { FFaker::Name.name }
    nickname { FFaker::Name.name }
    password 'password'
    birthday { FFaker::Time.datetime }
    address { FFaker::Address.street_address }
    confirmed_at { Time.zone.now }

    after(:build) do |u|
      u.uid = u.email unless u.uid
    end

    trait(:email) do
      provider { :email }

      after(:build) do |u|
        u.uid = u.email unless u.uid
      end
    end

    trait(:facebook) do
      provider { :email }
      uid { FFaker::Internet.user_name }
    end
  end
end
