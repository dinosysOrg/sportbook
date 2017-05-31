class AddTableInvitation < ActiveRecord::Migration[5.0]
  def change
    create_table :invitations do |t|
      t.integer :status
      t.references :match, foreign_key: true
      t.datetime :time
      t.integer :invitee_id
      t.integer :inviter_id
      t.timestamps
    end

    add_foreign_key :invitations, :teams, column: :invitee_id
    add_foreign_key :invitations, :teams, column: :inviter_id
  end
end
