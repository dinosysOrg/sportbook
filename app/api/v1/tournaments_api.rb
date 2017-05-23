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


    desc 'User can all upcoming components for a tour'
    get 'tournaments/:id/my-opponents' do
      team = Team.where(name: params[:name]).first
      teams = []
      # total_rating << l.rating
      matches = Match.where(team_a_id: team.id).or(Match.where(team_b_id: team.id))
      matches.each do |m|
        Team.all.each do |t|
          if t.id == m.team_b_id || t.id == m.team_a_id
            if t.name != params[:name]
              teams << t.name 
            end
          end
        end
      end
    end
  end
end
