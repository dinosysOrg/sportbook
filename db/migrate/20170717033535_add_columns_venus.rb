class AddColumnsVenus < ActiveRecord::Migration[5.0]
  def change
    add_column :venues, :lat, :float
    add_column :venues, :long, :float
  end
end
