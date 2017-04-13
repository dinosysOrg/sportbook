class Team < ApplicationRecord
  belongs_to :group

  validates :name, presence: true, uniqueness: { scope: :group_id, case_sensitive: false }
  validate :unique_team_name_in_tournament

  private

  def unique_team_name_in_tournament
    return unless name && group && group.tournament

    errors[:name] << 'must be unique in tournament.' unless group.tournament.teams.where('name ILIKE ?', name).first
  end
end
