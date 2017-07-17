class AddTableVenuesTournaments < ActiveRecord::Migration[5.0]
  def change
    create_table :tour_venues do |t|
      t.references :tournament, foreign_key: true
      t.references :venue, foreign_key: true

      t.timestamps
    end
  end
end
