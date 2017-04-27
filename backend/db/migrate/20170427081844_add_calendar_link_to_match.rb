class AddCalendarLinkToMatch < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :calendar_link, :string
  end
end
