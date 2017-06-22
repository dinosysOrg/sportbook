class AddDeviceIdToDevices < ActiveRecord::Migration[5.0]
  def change
    add_column :devices, :udid, :string
  end
end
