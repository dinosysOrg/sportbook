module V1
  class TournamentsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    desc 'Get all tournaments'
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', DateTime.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get all my tournaments'
    get 'my-tournaments' do
      authenticate_api_user!
      tournaments = current_api_user.tournaments
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get one tournament'
    get 'tournaments/:id' do
      tournament = Tournament.find_by_id(params[:id])
      present tournament, with: Representers::TournamentRepresenter
    end


    desc 'User can all upcoming components for a tour'
    post 'tournaments/:id/my-opponents' do
      debugger
      tournament = Tournament.find_by_id(params[:id])
      present tournament, with: Representers::TournamentRepresenter
      debugger
    end
  end
end
