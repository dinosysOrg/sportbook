class AddVenueRanking < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :venue_ranking, :integer, array: true, default: []
  end
end
