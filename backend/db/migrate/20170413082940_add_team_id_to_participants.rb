class AddTeamIdToParticipants < ActiveRecord::Migration[5.0]
  def change
    add_column :participants, :team_id, :integer
    add_foreign_key :participants, :teams
  end
end
