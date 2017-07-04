class AddTimeBlocksToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :preferred_time_blocks, :text
  end
end
