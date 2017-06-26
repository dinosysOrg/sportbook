FactoryGirl.define do
  factory :user do
    provider 'email'
    uid { FFaker::Internet.email }
    email { FFaker::Internet.email }
    nickname { FFaker::Name.name }
    name { FFaker::Name.name }
    password 'password'
    password_confirmation 'password'
    confirmed_at { Time.zone.now }
    birthday { FFaker::Time.datetime }
    address { FFaker::Address.street_address }
    club { FFaker::Name.name }

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
