class AddTablesVenuesTournaments < ActiveRecord::Migration[5.0]
  def change
    create_table :tours_venues do |t|
      t.references :tournament, foreign_key: true
      t.references :venue, foreign_key: true

      t.timestamps
    end
  end
end
