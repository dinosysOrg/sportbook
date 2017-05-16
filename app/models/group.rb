class Group < ApplicationRecord
  belongs_to :tournament
  has_many :matches, dependent: :destroy
  has_many :groups_teams, dependent: :destroy
  has_many :teams, through: :groups_teams

  accepts_nested_attributes_for :groups_teams, allow_destroy: true

  validates :name, presence: true, uniqueness: { scope: :tournament_id, case_sensitive: false }
  validates :tournament, presence: true

  validates :start_date, presence: true

  scope :round_robin, (-> { where('name NOT ILIKE ?', 'DE%') })

  default_scope { order(:name) }
end
