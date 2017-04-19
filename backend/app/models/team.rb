class Team < ApplicationRecord
  belongs_to :tournament
  has_many :players, dependent: :destroy
  has_many :matches_as_team_a, foreign_key: 'team_a_id', class_name: 'Match'
  has_many :matches_as_team_b, foreign_key: 'team_b_id', class_name: 'Match'
  has_many :groups_teams
  has_many :groups, through: :groups_teams

  validates :name, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
end
