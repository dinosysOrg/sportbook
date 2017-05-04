class RenameCalendarIdToGoogleCalendarName < ActiveRecord::Migration[5.0]
  def change
    rename_column :venues, :calendar_id, :google_calendar_name
  end
end
