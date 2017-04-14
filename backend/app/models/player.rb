class Player < ApplicationRecord
  belongs_to :user
  belongs_to :tournament
  belongs_to :team

  delegate :group, to: :team

  validates :user_id, uniqueness: { scope: :team_id }
end
