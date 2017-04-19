class Team < ApplicationRecord
  belongs_to :tournament
  has_many :players, dependent: :destroy
  has_and_belongs_to_many :groups

  validates :name, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
end
