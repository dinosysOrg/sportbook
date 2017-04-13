class Group < ApplicationRecord
  belongs_to :tournament

  validates :name, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
end
