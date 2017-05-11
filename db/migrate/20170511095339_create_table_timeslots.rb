class CreateTableTimeslots < ActiveRecord::Migration[5.0]
  def change
    create_table :time_slots do |t|
      t.datetime :time
      t.boolean :available
      t.references :venue
      t.timestamps
    end
  end
end
