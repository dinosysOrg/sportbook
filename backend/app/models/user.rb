class User < ApplicationRecord
  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,
          :confirmable
  include DeviseTokenAuth::Concerns::User

  has_many :players

  enum skill_level: { beginner: 100, amateur: 200, semi_professional: 300, professional: 400, master: 500 }

  def email_required?
    false
  end
end
