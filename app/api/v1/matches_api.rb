module V1
  class MatchesApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers
    default_format :hal_json

    desc 'Player can see all upcoming confirmed matches'
	get 'matches' do
		matches = Match.all
		matches.to_json()
	end
	desc 'Player can see all upcoming confirmed matches with tournament_id'
	get 'matches/:tournament_id' do
		matches = []
		Match.all.each do |match|
			if match.team_a_id != nil
				team = Team.find(match.team_a_id)
				if team.tournament_id == params[:tournament_id].to_i
					matches << match
				end
			end
		end
	 	matches.to_json()
	end
	desc 'Player can see all upcoming confirmed matches with user_id'
	get 'matches/:user_id/user' do
		matches = Match.all
		matches.to_json()
	end
  end
end
