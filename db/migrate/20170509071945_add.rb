class Add < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :facebook_uid, :string
    add_column :users, :facebook_credentials, :json
  end
end
