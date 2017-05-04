class PlayersController < ApplicationController
  def index
    @tournament = Tournament.find params[:tournament_id]
    @players = @tournament.players
  end
end
