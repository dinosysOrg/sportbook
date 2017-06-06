class ChangeTypePlatformInDevice < ActiveRecord::Migration[5.0]
  change_column :devices, :platform, :integer, using: 'platform::integer'
end
