class CreatePages < ActiveRecord::Migration[5.0]
  def change
    create_table :pages do |t|
      t.references :tournament
      t.string :name
      t.string :locale
      t.text :html_content

      t.timestamps
    end
  end
end
