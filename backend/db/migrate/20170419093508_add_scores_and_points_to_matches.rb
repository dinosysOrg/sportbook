class AddScoresAndPointsToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :score_a, :integer, default: 0
    add_column :matches, :score_b, :integer, default: 0
    add_column :matches, :point_a, :integer, default: 0
    add_column :matches, :point_b, :integer, default: 0
  end
end
