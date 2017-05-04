class AddDetailsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :skill_level, :integer
    add_column :users, :address, :text
    add_column :users, :note, :text
  end
end
