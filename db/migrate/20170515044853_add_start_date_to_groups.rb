class AddStartDateToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :start_date, :date
  end
end
