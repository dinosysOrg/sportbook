class Team < ApplicationRecord
  belongs_to :group
  has_many :players, dependent: :destroy

  delegate :tournament, to: :group

  validates :name, presence: true, uniqueness: { scope: :group_id, case_sensitive: false }
end
