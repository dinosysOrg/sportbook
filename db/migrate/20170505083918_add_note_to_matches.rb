class AddNoteToMatches < ActiveRecord::Migration[5.0]
  def change
    add_column :matches, :note, :text
  end
end
