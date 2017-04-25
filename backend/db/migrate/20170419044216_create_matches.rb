class CreateMatches < ActiveRecord::Migration[5.0]
  def change
    create_table :matches do |t|
      t.references :group
      t.references :venue
      t.references :team_a
      t.references :team_b

      t.datetime :time

      t.timestamps
    end
  end
end
