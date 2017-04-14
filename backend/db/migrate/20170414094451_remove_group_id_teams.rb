class RemoveGroupIdTeams < ActiveRecord::Migration[5.0]
  def change
    remove_reference :teams, :group
  end
end
