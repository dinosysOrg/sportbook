class Group < ApplicationRecord
  belongs_to :tournament
  has_many :teams

  validates :name, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
end
