FactoryGirl.define do
  factory :user do
    email { FFaker::Internet.email }
    nickname { FFaker::Name.name }
    password 'password'
    confirmed_at { Time.now }
  end
end
