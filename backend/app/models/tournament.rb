class Tournament < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :teams, dependent: :destroy
  has_many :players
  has_many :matches, through: :groups

  validates :name, presence: true, uniqueness: true
end
