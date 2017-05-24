class Role < ApplicationRecord
  has_many :users, through: :roles_users

  def self.admin_role
    Role.find_by_name 'Admin'
  end
end
