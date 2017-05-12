class AddStartDateEndDateTournament < ActiveRecord::Migration[5.0]
  def change
    add_column :tournaments, :start_date, :datetime
    add_column :tournaments, :end_date, :datetime
  end
end
