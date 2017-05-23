module V1
  class MatchesApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    desc 'Player can see all upcoming confirmed matches'
    get 'matches' do
      #Case 1: return list mathes
      if params[:user_id] == nil && params[:tournament_id] == nil
        matches = Match.all
        return matches.to_json()
      end
      matches = []
      #Case 2: Return list mathes with user_id
      if params[:user_id] == nil && params[:tournament_id] != nil || 
        params[:user_id] != nil && params[:tournament_id] != nil
        Match.all.each do |match|
          team = Team.find(match.team_a_id)
          if team.tournament_id == params[:tournament_id].to_i
            matches << match
          end
        end
      end
      #Case 3: Return list matches with tournament
      if params[:user_id] != nil && params[:tournament_id] == nil 
        user = User.find(params[:user_id])
        if user.teams == nil
          return matches.to_json()
        end
      end
      return matches.to_json()
    end
  end
end
