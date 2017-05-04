class AddMatchCodeToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :code, :string
  end
end
