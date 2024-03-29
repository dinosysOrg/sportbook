FactoryGirl.define do
  factory :invitation do
    match
    venue
    time { Time.zone.now.at_beginning_of_hour }
    invitee { match.team_a }
    inviter { match.team_b }

    trait :pending do
      status 'pending'
    end

    trait :created do
      status 'created'
    end

    trait :accepted do
      status 'accepted'
    end

    trait :rejected do
      status 'rejected'
    end
  end
end
