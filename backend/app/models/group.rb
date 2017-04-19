class Group < ApplicationRecord
  belongs_to :tournament
  has_many :groups_teams, dependent: :destroy
  has_many :teams, through: :groups_teams
  has_many :matches, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
end
