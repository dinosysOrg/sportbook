class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable

  include FriendlyId
  friendly_id :slug_info, use: [:slugged, :finders]

  has_many :players
  belongs_to :skill
  enum skill_level: { beginner: 100, amateur: 200, semi_professional: 300, professional: 400, master: 500 }

  def slug_info
    "#{name} #{phone_number ? phone_number[-3..-1] : ''}"
  end
end
