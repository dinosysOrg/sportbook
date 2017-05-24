class AddCountToColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :invitations_count, :integer, :default => 0
  end
end
