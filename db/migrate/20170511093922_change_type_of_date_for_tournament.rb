class ChangeTypeOfDateForTournament < ActiveRecord::Migration[5.0]
  def up
    change_column :tournaments, :start_date, :date
    change_column :tournaments, :end_date, :date
  end

  def down
    change_column :tournaments, :start_date, :datetime
    change_column :tournaments, :end_date, :datetime
  end
end
