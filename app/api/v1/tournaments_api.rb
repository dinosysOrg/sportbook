module V1
  class TournamentsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    desc 'Get all tournaments'
    get 'tournaments' do
      tournaments = Tournament.where('start_date > ? ', Time.zone.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get all my tournaments', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' }
    ]

    get 'tournaments/my-tournaments' do
      tournaments = current_api_user.tournaments
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'Get one tournament'
    get 'tournaments/:tournament_id' do
      tournament = Tournament.find_by_id(params[:tournament_id])
      present tournament, with: Representers::TournamentRepresenter
    end

    desc 'get all upcoming tournaments'
    get 'tournaments/my-tournaments/upcoming-tournaments' do
      tournaments = current_api_user.tournaments.where('start_date > ?', Time.zone.now)
      present tournaments, with: Representers::TournamentsRepresenter
    end

    desc 'get all upcoming matches'
    get 'tournaments/my-tournaments/upcoming-matches' do
      matches_team_a = Match.where('team_a_id = ? And time > ?', current_api_user.team_ids, Time.zone.now)
      matches_team_b = Match.where('team_b_id = ? And time > ?', current_api_user.team_ids, Time.zone.now)
      upcoming_matches = matches_team_a.or(matches_team_b)
      present upcoming_matches, with: Representers::MatchesRepresenter
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
          invitee = my_team.invitations_as_invitee.where(inviter_id: t.id)
          inviter = my_team.invitations_as_inviter.where(invitee_id: t.id)
          list_invitations = invitee.empty? ? inviter : invitee
          invitation_last = list_invitations.last
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
