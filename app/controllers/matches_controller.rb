class MatchesController < ApplicationController
  def index
    @tournament = Tournament.find params[:tournament_id]
    @matches = @tournament.matches
  end
end
