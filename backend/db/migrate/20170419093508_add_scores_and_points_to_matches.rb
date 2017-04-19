class AddScoresAndPointsToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :score_a, :integer
    add_column :matches, :score_b, :integer
    add_column :matches, :point_a, :integer
    add_column :matches, :point_b, :integer
  end
end
