module V1
  class MatchesApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers
    helpers V1::Helpers

    before do
      authenticate_api_user!
      set_locale_api
    end

    desc 'get all upcoming or history matches'
    params do
      optional :type, type: String, desc: 'Upcoming or history for matches'
      optional :tournament_id, type: Integer, desc: 'Filter tournament_id for matches'
      requires :limit, type: Integer, desc: 'Number of list'
      requires :page, type: Integer, desc: 'Number of page'
      optional :locale, type: String
    end
    get 'matches' do
      case params[:type]
      when 'my_upcoming'
        matches_team_a = Match.where('team_a_id IN (?) And time > ?', current_api_user.team_ids)
        matches_team_b = Match.where('team_b_id IN (?) And time > ?', current_api_user.team_ids)
      when 'my_historical'
        matches_team_a = Match.where('team_a_id IN (?) And time < ?', current_api_user.team_ids, Time.zone.now)
        matches_team_b = Match.where('team_b_id IN (?) And time < ?', current_api_user.team_ids, Time.zone.now)
      else
        my_tournament = Tournament.find_by_id(params[:tournament_id])
        matches_team_a = Match.where('team_a_id IN (?)', my_tournament.team_ids)
        matches_team_b = Match.where('team_b_id IN (?)', my_tournament.team_ids)
      end
      matches = matches_team_a.or(matches_team_b).page(params[:page]).per(params[:limit])
      if params[:type] == 'my_upcoming'
        present matches, with: Representers::UpcomingMatchesRepresenter
      else
        present matches, with: Representers::MatchesRepresenter
      end
    end
  end
end
