module V1
  class TeamsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers
    helpers V1::Helpers

    before do
      authenticate_api_user!
      set_locale_api
    end

    include ExceptionHandlers

    desc 'Sign up tournament', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 422, message: 'One of require fields is missing' }
    ]
    params do
      requires :name, type: String, desc: 'User Name'
      requires :phone_number, type: Integer, desc: 'Player phone number'
      requires :address, type: String, desc: 'User Address'
      requires :tournament_id, type: Integer, desc: 'Id of tournament'
      optional :club, type: String, desc: 'Club that player is playing'
      optional :birthday, type: Date, desc: 'Player BOD'
      optional :user_ids, type: Array[Integer], desc: 'Arrays user for creating team. Input values are user_id: [1, 2, 3 ,4]'
      optional :locale, type: String, default: 'vi', desc: "Language which server returns. Value is 'vi' or 'en'"
    end
    post 'tournaments/:tournament_id/teams' do
      unless params[:phone_number] && params[:address] && params[:name]
        error!(I18n.t('activerecord.errors.models.team.attributes.missing_field'), 422)
      end
      team = Team.create!(name: params[:name], tournament_id: params[:tournament_id], status: :registered)
      current_api_user.update_attributes!(name: params[:name],
                                          birthday: params[:birthday],
                                          club: params[:club],
                                          phone_number: params[:phone_number],
                                          address: params[:address])
      current_api_user.update_attribute('skill_id', params[:skill_id]) if current_api_user.skill_id.nil?
      user_ids = params[:user_ids] || []
      user_ids << current_api_user.id
      user_ids.each do |user_id|
        Player.create(user_id: user_id, tournament_id: params[:tournament_id], team_id: team.id)
      end
      team = OpenStruct.new team: team, user: current_api_user
      present team, with: Representers::TeamRepresenter
    end

    desc 'Get timeslots for team', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 422, message: 'One of require fields is missing' }
    ]
    params do
      requires :team_id, type: Integer, desc: 'Id of team'
      optional :locale, type: String, default: 'vi', desc: "Language which server returns. Value is 'vi' or 'en'"
    end
    get 'teams/:team_id/time_slots' do
      team = Team.find params[:team_id]
      venue_time_slots = TimeSlotService.possible_time_slots team
      present venue_time_slots, with: Representers::PossibleTimeSlotsRepresenter
    end

    desc 'Updates time slot and venue ranking for team', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 422, message: 'One of require fields is missing' },
      { code: 405, message: 'You are not in the team that can do this operation' }
    ]
    params do
      requires :preferred_time_blocks, type: Object, desc: 'Preferred time block for team.
                                                          Input values are: { tuesday: [[9, 10, 11],[13, 14, 15]], monday: [[9, 10, 11],[13, 14, 15]] }'
      requires :venue_ranking, type: Array[Integer], desc: 'Venue ranking for team. Input values are array of venue_id: [1, 2, 3, 4]'
      requires :team_id, type: Integer, desc: 'Id of team'
      optional :locale, type: String, default: 'vi', desc: "Language which server returns. Value is 'vi' or 'en'"
    end
    put 'teams/:team_id' do
      unless current_api_user.team_ids.include?(params[:team_id].to_i)
        error!(I18n.t('activerecord.errors.models.team.attributes.team_id'), 405)
      end
      team = Team.find params[:team_id]
      tour = team.tournament
      date_range = (tour['start_date']..tour['end_date']).to_a
      if team.paid? && params[:preferred_time_blocks].present?
        team.time_slots.where(available: true).each(&:destroy)
        TimeSlotService.create_from_preferred_time_blocks([team], date_range, params[:preferred_time_blocks])
        team.update_attributes!(preferred_time_blocks: params[:preferred_time_blocks].as_json)
      end
      team.update_attributes!(venue_ranking: params[:venue_ranking]) if params[:venue_ranking].present? && team.paid?
      team = OpenStruct.new team: team, user: current_api_user
      present team, with: Representers::TeamRepresenter
    end

    desc 'Get time_block and venue ranking for team', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 422, message: 'One of require fields is missing' }
    ]
    params do
      requires :team_id, type: Integer, desc: 'Id of team'
      optional :locale, type: String, default: 'vi', desc: "Language which server returns. Value is 'vi' or 'en'"
    end
    get 'teams/:team_id/time_blocks' do
      team = Team.find params[:team_id]
      present team, with: Representers::TimeBlocksRepresenter
    end
  end
end
