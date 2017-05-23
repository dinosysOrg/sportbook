module V1
  class MatchesApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    desc 'Player can see all upcoming confirmed matches'
    get 'matches' do
      matches = Team.all
      debugger
    end
  end
end
