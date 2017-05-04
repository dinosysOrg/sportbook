class CreateGroupsTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :groups_teams do |t|
      t.references :group
      t.references :team

      t.timestamps
    end
  end
end
