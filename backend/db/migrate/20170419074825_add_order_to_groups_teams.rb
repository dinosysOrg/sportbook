class AddOrderToGroupsTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :groups_teams, :order, :integer
  end
end
