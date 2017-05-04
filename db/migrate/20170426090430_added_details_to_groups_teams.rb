class AddedDetailsToGroupsTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :groups_teams, :points, :integer, default: 0
    add_column :groups_teams, :score_difference, :integer, default: 0
    add_column :groups_teams, :wins, :integer, default: 0
    add_column :groups_teams, :draws, :integer, default: 0
    add_column :groups_teams, :losses, :integer, default: 0
  end
end
