module V1
  class TeamsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    desc 'Sign up tournament'
    post 'tournaments/:tournament_id/teams' do
      tour = Tournament.find_by_id(params[:tournament_id])
      team = Team.create(name: params[:name], tournament_id: params[:tournament_id], status: :registered, venue_ranking: params[:venue_ranking])
      date_range = (tour['start_date']..tour['end_date']).to_a
      TimeSlotService.instance.generate_time_slots([team], params[:hour_range], date_range)
      user_ids = params[:user_ids] || []
      user_ids << current_api_user.id
      user_ids.each do |user_id|
        Player.create(user_id: user_id, tournament_id: params[:tournament_id], team_id: team.id)
      end
    end
  end
end
