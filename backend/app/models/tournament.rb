class Tournament < ApplicationRecord
  has_many :groups, dependent: :destroy
  has_many :teams, through: :groups
  has_many :players, through: :teams

  validates :name, presence: true, uniqueness: true
end
