class Player < ApplicationRecord
  belongs_to :user
  belongs_to :tournament
  belongs_to :team

  delegate :name, :phone_number, :email, to: :user

  validates :user_id, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
end
