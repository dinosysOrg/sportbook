FactoryGirl.define do
  factory :admin_user, parent: :user, class: AdminUser do
    after(:create) do |admin|
      admin.roles << Role.admin_role
    end
  end
end
