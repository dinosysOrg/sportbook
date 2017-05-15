class Team < ApplicationRecord
  belongs_to :tournament
  has_many :players, dependent: :destroy
  has_many :matches_as_team_a, foreign_key: 'team_a_id', class_name: 'Match'
  has_many :matches_as_team_b, foreign_key: 'team_b_id', class_name: 'Match'
  has_many :groups_teams
  has_many :groups, through: :groups_teams

  accepts_nested_attributes_for :groups_teams, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
  validates :status, presence: true
  validates :tournament, presence: true

  enum status: { registered: 0, paid: 1 }
  enum status: { 0 => :registered, 1 => :paid }

  def phone_numbers
    players.map(&:phone_number).join(', ')
  end

  def emails
    players.map(&:email)
  end
end
