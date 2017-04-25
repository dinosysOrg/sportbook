class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.references :tournament, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
