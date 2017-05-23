class ChangeColumnInTimeslot < ActiveRecord::Migration[5.0]
  def change
    remove_column :time_slots, :venue_id
    add_column :time_slots, :object_id, :integer
    add_column :time_slots, :object_type, :string
  end
end
