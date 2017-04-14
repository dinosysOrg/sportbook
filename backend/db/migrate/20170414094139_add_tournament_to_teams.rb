class AddTournamentToTeams < ActiveRecord::Migration[5.0]
def change
    add_reference :teams, :tournament, index: true, foreign_key: true
  end
end
