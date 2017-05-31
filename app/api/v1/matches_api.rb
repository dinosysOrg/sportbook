module V1
  class MatchesApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers
    default_format :hal_json

    desc 'Player can view their upcoming confirmed matches'
    get 'user/:user_id/matches' do
      matches = []
      user = User.find(params[:user_id])
      if user.teams.count.positive?
        user.teams.each do |team|
          matches << (team.matches_as_team_a + team.matches_as_team_b).uniq
        end
      end
      present matches.flatten, with: Representers::MatchesRepresenter
    end
  end
end
