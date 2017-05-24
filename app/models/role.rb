class Role < ApplicationRecord
  has_many :users, through: :roles_users
end
