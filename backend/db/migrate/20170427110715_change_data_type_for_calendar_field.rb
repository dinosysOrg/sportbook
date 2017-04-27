class ChangeDataTypeForCalendarField < ActiveRecord::Migration[5.0]
  def up
    change_column :matches, :calendar_link, :text
    change_column :venues, :calendar_id, :string
  end

  def down
    change_column :matches, :calendar_link, :string
    change_column :venues, :calendar_id, :text
  end
end
