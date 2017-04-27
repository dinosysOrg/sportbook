class AddCalendarIdToVenue < ActiveRecord::Migration[5.0]
  def change
    add_column :venues, :calendar_id, :text
  end
end
