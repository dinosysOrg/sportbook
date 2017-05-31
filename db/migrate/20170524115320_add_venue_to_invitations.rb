class AddVenueToInvitations < ActiveRecord::Migration[5.0]
  def change
    add_column :invitations, :venue_id, :integer
    add_foreign_key :invitations, :venues
  end
end
