class FixTeamIdInParticipants < ActiveRecord::Migration[5.0]
  def up
    remove_column :players, :team_id, :integer

    add_reference :players, :team, index: true, foreign_key: true
  end

  def down
    remove_reference :players, :team

    add_column :players, :team_id, :integer
    add_foreign_key :players, :teams
  end
end
