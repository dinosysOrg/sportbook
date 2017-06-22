module V1
  class TournamentsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers
    helpers V1::Helpers

    before do
      authenticate_api_user!
      set_locale_api
    end

    include ExceptionHandlers

    desc 'Get all tournaments'
    params do
      optional :locale, type: String
    end
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', Time.zone.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get all my tournaments', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]
    params do
      optional :locale, type: String
    end
    get 'tournaments/my-tournaments' do
      tournaments = current_api_user.tournaments
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get one tournament', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]
    params do
      optional :locale, type: String, default: 'vi', desc: "Language which server returns. Value is 'vi' or 'en'"
    end
    get 'tournaments/:tournament_id' do
      tournament = TournamentsService.tournament_detail params[:tournament_id], current_api_user
      present tournament, with: Representers::TournamentRepresenter
    end

    desc 'get all upcoming tournaments', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]
    params do
      optional :locale, type: String
    end
    get 'tournaments/my-tournaments/upcoming-tournaments' do
      tournaments = current_api_user.tournaments.where('start_date > ?', Time.zone.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'view opponent'
    get 'tournaments/:tournament_id/groups' do
      my_team = current_api_user.teams.find_by(tournament_id: params[:tournament_id])
      my_groups = my_team.groups
      other_groups = Group.where(tournament_id: params[:tournament_id])
                          .where.not(id: my_groups.ids)
      my_groups = my_groups.map do |g|
        opponent_teams = g.teams.reject { |t| t == my_team }
        opponent_with_status_invitation = opponent_teams.map do |t|
          invitation_last = Invitation.latest_invitation_between(my_team, t)
          { team_id: t.id, team_name: t.name, invitation_id: invitation_last.try(:id),
            invitation_status: invitation_last.try(:status),
            invitation_invitee_id: invitation_last.try(:invitee_id),
            invitation_inviter_id: invitation_last.try(:inviter_id) }
        end
        { group_name: g.name, group_time_create: g.created_at,
          opponent_teams: opponent_with_status_invitation }
      end
      other_groups = other_groups.map do |g|
        { group_name: g.name, teams: g.teams }
      end

      list_groups = OpenStruct.new my_groups: my_groups, other_groups: other_groups
      present list_groups, with: Representers::GroupsRepresenter
    end
  end
end
