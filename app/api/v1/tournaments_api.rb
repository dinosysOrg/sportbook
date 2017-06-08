module V1
  class TournamentsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    desc 'Get all tournaments'
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', Time.zone.now)
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

    desc 'get all upcoming matches'
    get 'tournaments/my-tournaments/upcoming-matches' do
      matches_team_a = Match.where('team_a_id = ? And time > ?', current_api_user.team_ids, Time.zone.now)
      matches_team_b = Match.where('team_b_id = ? And time > ?', current_api_user.team_ids, Time.zone.now)
      upcoming_matches = matches_team_a.or(matches_team_b)
      present upcoming_matches, with: Representers::MatchesRepresenter
    end

    desc 'update infomations for profile player'
    params do
      requires :first_name, type: String, desc: "Player's First Name"
      requires :last_name, type: String, desc: "Player's Last Name"
      requires :email, type: String, desc: "Player's Email"
      requires :password, type: String, desc: "Player's Password"
      requires :password_confirmation, type: String, desc: "Player's Password confirmation"
      requires :address, type: String, desc: "Player's Address"
      requires :birthday, type: String, desc: "Player's Birthday"
      requires :club, type: String, desc: "Player's Club"
    end
    put 'tournaments/:tournament_id/players/:player_id' do
      Player.update_infomations(params)
      player = Player.find_by_id(params[:player_id])
      player.update_attributes!(club: params[:club])
      present player, with: Representers::PlayerRepresenter
    end
  end
end
