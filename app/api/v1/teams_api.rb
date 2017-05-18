module V1
  class TeamsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    include ExceptionHandlers

    desc 'Sign up tournament'
    params do
      requires :name, type: String
    end
    post 'tournaments/:tournament_id/teams' do
      tour = Tournament.find_by_id(params[:tournament_id])
      team = Team.create!(name: params[:name], tournament_id: params[:tournament_id], status: :registered, venue_ranking: params[:venue_ranking])

      current_api_user.update_attributes!(skill_id: params[:skill_id])

      date_range = (tour['start_date']..tour['end_date']).to_a
      TimeSlotService.instance.create_from_preferred_time_blocks([team], date_range, params[:preferred_time_blocks])

      user_ids = params[:user_ids] || []
      user_ids << current_api_user.id
      user_ids.each do |user_id|
        Player.create(user_id: user_id, tournament_id: params[:tournament_id], team_id: team.id)
      end
      present team, with: Representers::TeamRepresenter
    end
  end
end
