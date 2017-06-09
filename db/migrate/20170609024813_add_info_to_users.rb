class AddInfoToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :birthday, :datetime
    add_column :users, :club, :string
  end
end
