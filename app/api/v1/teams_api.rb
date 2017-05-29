module V1
  class TeamsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    include ExceptionHandlers

    desc 'Sign up tournament', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 422, message: 'One of require fields is missing' }
    ]
    params do
      requires :name, type: String, desc: 'Team Name'
      requires :venue_ranking, type: Array[Integer], desc: 'Venue ranking for team'
      requires :preferred_time_blocks, type: Hash, desc: 'Preferred time block for team'
      optional :user_ids, type: Array[Integer], desc: 'Arrays user for creating team'
    end
    post 'tournaments/:tournament_id/teams' do
      tour = Tournament.find_by_id(params[:tournament_id])
      team = Team.create!(name: params[:name], tournament_id: params[:tournament_id], status: :registered, venue_ranking: params[:venue_ranking])
      current_api_user.update_attributes!(skill_id: params[:skill_id]) if current_api_user.skill_id.nil?
      date_range = (tour['start_date']..tour['end_date']).to_a
      TimeSlotService.create_from_preferred_time_blocks([team], date_range, params[:preferred_time_blocks])
      user_ids = params[:user_ids] || []
      user_ids << current_api_user.id
      user_ids.each do |user_id|
        Player.create(user_id: user_id, tournament_id: params[:tournament_id], team_id: team.id)
      end
      present team, with: Representers::TeamRepresenter
    end

    desc 'Get timeslots for team', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 422, message: 'One of require fields is missing' }
    ]
    params do
      requires :type, type: String, default: 'available', values: ['available']
    end
    get 'teams/:id/time_slots' do
      team = Team.find params[:id]
      venue_time_slots = TimeSlotService.possible_time_slots team
      present venue_time_slots, with: Representers::PossibleTimeSlotsRepresenter
    end
  end
end
