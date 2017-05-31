module V1
  class TournamentsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    desc 'Get all tournaments'
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', DateTime.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get all my tournaments', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]

    get 'tournaments/my-tournaments' do
      authenticate_api_user!
      tournaments = current_api_user.tournaments
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get one tournament'
    get 'tournaments/:tournament_id' do
      tournament = Tournament.find_by_id(params[:tournament_id])
      present tournament, with: Representers::TournamentRepresenter
    end


    desc 'User can view all the upcoming opponents for a tournament'
    get 'tournaments/:id/my-opponents' do
      team = Team.where(name: params[:name], tournament_id: params[:id]).first
      teams = []
      matches = Match.where(team_a_id: team.id).or(Match.where(team_b_id: team.id))
      matches.each do |m|
        if m.team_a.name == params[:name]
          teams << Team.where(name: m.team_b.name).first.name
        else
          teams << Team.where(name: m.team_a.name).first.name
        end
      end
      return teams.to_json
    end
  end
end
