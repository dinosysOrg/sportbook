class RenameParticipantsToPlayers < ActiveRecord::Migration[5.0]
  def change
    rename_table :participants, :players
  end
end
