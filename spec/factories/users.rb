FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    nickname { FFaker::Name.name }
    password 'password'
    confirmed_at { Time.now }

    after(:build) do |u|
      u.uid = u.email
    end

    trait(:email) do
      provider { :email }

      after(:build) do |u|
        u.uid = u.email
      end
    end

    trait(:facebook) do
      provider { :email }
      uid { FFaker::Internet.user_name }
    end
  end
end
