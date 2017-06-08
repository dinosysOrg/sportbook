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

    desc 'get all upcoming or history matches'
    params do
      requires :type, type: String, desc: 'Upcoming or history for matches'
      requires :tournament_id, type: Integer, desc: 'Filter tournament_id for matches'
      requires :limit, type: Integer, desc: 'Number of list'
      requires :page, type: Integer, desc: 'Number of page'
    end
    get 'matches' do
      case params[:type]
      when 'upcoming'
        matches_team_a = Match.where('team_a_id = ? And time > ?', current_api_user.team_ids, Time.zone.now)
        matches_team_b = Match.where('team_b_id = ? And time > ?', current_api_user.team_ids, Time.zone.now)
      when 'history'
        matches_team_a = Match.where('team_a_id = ? And time < ?', current_api_user.team_ids, Time.zone.now)
        matches_team_b = Match.where('team_b_id = ? And time < ?', current_api_user.team_ids, Time.zone.now)
      else
        tournament = Tournament.find_by_id(params[:tournament_id])
        team_ids = tournament.teams.pluck(:id)
        matches_team_a = Match.where('team_a_id IN (?)', team_ids)
        matches_team_b = Match.where('team_b_id IN (?)', team_ids)
      end
      page = params[:page].present? ? params[:page] : 1
      limit = params[:limit].present? ? params[:limit] : 5
      upcoming_matches = matches_team_a.or(matches_team_b).page(page).limit(limit)
      present upcoming_matches, with: Representers::MatchesRepresenter
    end
  end
end
