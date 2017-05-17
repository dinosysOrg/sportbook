class TournamentsController < ApplicationController
  def show
    tournament = Tournament.find(params[:id])
    @tournament = TournamentDecorator.decorate tournament
  end

  def detail; end
end
