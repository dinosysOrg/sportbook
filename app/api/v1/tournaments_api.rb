module V1
  class TournamentsApi < BaseApi
    desc 'Get all tournaments'
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', DateTime.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get one tournament'
    get 'tournaments/:id' do
      tournament = Tournament.find_by_id(params[:id])
      present tournament, with: Representers::TournamentRepresenter
    end
  end
end
