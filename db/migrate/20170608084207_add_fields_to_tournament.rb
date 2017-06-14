class AddFieldsToTournament < ActiveRecord::Migration[5.0]
  def change
    add_column :tournaments, :competition_mode, :text
    add_column :tournaments, :competition_fee, :text
    add_column :tournaments, :competition_schedule, :text
  end
end
