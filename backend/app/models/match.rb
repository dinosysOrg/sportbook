class Match < ApplicationRecord
  belongs_to :group
  belongs_to :venue
  belongs_to :team_a, class_name: 'Team'
  belongs_to :team_b, class_name: 'Team'

  validates :group, presence: true

  delegate :tournament, to: :group
end
