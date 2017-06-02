class AddMatchIdForTimslot < ActiveRecord::Migration[5.0]
  def change
    add_column :time_slots, :match_id, :integer
    add_foreign_key :time_slots, :matches
  end
end
