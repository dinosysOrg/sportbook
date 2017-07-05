class Team < ApplicationRecord
  CAPACITY = 1
  serialize :preferred_time_blocks
  belongs_to :tournament
  has_many :players, dependent: :destroy
  has_many :users, through: :players
  has_many :matches_as_team_a, foreign_key: 'team_a_id', class_name: 'Match'
  has_many :matches_as_team_b, foreign_key: 'team_b_id', class_name: 'Match'
  has_many :groups_teams
  has_many :groups, through: :groups_teams
  has_many :time_slots, as: :object
  has_many :pages
  has_many :invitations
  has_many :invitations_as_invitee, foreign_key: 'invitee_id', class_name: 'Invitation'
  has_many :invitations_as_inviter, foreign_key: 'inviter_id', class_name: 'Invitation'
  accepts_nested_attributes_for :groups_teams, allow_destroy: true

  validates :name, presence: true
  validates :status, presence: true
  validates :tournament, presence: true

  enum status: { registered: 0, paid: 1 }

  before_create :check_is_paid

  def check_is_paid
    user_ids = User.includes(:teams).references(:teams).where('teams.status = ?', 1).ids
    Tournament.push_is_paid(user_ids)
  end
  
  def paid?
    self[:status] == 'paid' ? true : false
  end

  def phone_numbers
    players.map(&:phone_number).join(', ')
  end

  def emails
    players.map(&:email)
  end
end
