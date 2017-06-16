module V1
  class TournamentsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers
    helpers V1::Helpers

    before do
      authenticate_api_user!
      set_locale_api
    end

    include ExceptionHandlers

    desc 'Get all tournaments'
    params do
      optional :locale, type: String
    end
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', Time.zone.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get all my tournaments', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]
    params do
      optional :locale, type: String
    end
    get 'tournaments/my-tournaments' do
      tournaments = current_api_user.tournaments
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get one tournament', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]
    params do
      optional :locale, type: String, default: 'vi', desc: "Language which server returns. Value is 'vi' or 'en'"
    end
    get 'tournaments/:tournament_id' do
      tournament = TournamentsService.tournament_detail params[:tournament_id], current_api_user
      present tournament, with: Representers::TournamentRepresenter
    end

    desc 'get all upcoming tournaments', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]
    params do
      optional :locale, type: String
    end
    get 'tournaments/my-tournaments/upcoming-tournaments' do
      tournaments = current_api_user.tournaments.where('start_date > ?', Time.zone.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end
  end
end
