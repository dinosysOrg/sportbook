class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable

  include FriendlyId
  friendly_id :slug_info, use: [:slugged, :finders]

  has_many :players
  belongs_to :skill
  has_many :teams, through: :players
  has_many :tournaments, through: :players
  has_many :roles_users
  has_many :roles, through: :roles_users
  has_many :devices

  enum skill_level: { beginner: 100, amateur: 200, semi_professional: 300, professional: 400, master: 500 }

  def slug_info
    "#{name} #{phone_number ? phone_number[-3..-1] : ''}"
  end

  def role?(role)
    roles.pluck(:name).include?(role)
  end
end
