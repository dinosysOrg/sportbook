module V1
  class TournamentsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    desc 'Get all tournaments'
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', DateTime.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get all my tournaments', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]

    get 'tournaments/my-tournaments' do
      tournaments = current_api_user.tournaments
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get one tournament'
    get 'tournaments/:tournament_id' do
      tournament = Tournament.find_by_id(params[:tournament_id])
      present tournament, with: Representers::TournamentRepresenter
    end

    desc 'get all upcoming tournaments'
    get 'tournaments/my-tournaments/upcoming-tournaments' do
      tournaments = current_api_user.tournaments.where('start_date > ?', Time.zone.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end
  end
end
