class Tournament < ApplicationRecord
  has_many :groups
  has_many :teams, through: :groups

  validates :name, presence: true, uniqueness: true
end
