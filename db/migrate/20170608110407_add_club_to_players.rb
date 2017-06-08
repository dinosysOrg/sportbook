class AddClubToPlayers < ActiveRecord::Migration[5.0]
  def change
    add_column :players, :club, :string
  end
end
