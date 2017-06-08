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
    get 'tournaments/:tournament_id/view_opponents' do
      team = current_api_user.teams.find_by(tournament_id: params[:tournament_id])
      group = team.groups.max_by(&:created_at)
      opponent_teams = group.teams.reject { |t| t == team }
      opponent_with_status_invitation = opponent_teams.map do |t|
        invitatee = team.invitations_as_invitee.where(inviter_id: t.id)
        invitater = team.invitations_as_inviter.where(invitee_id: t.id)
        list_invitations = invitatee.empty? ? invitater : invitatee
        invitation_max = list_invitations.max_by(&:created_at)
        OpenStruct.new team_id: t.id, team_name: t.name, invitation_id: invitation_max.try(:id),
                       invitation_status: invitation_max.try(:status),
                       invitation_invitee_id: invitation_max.try(:invitee_id),
                       invitation_inviter_id: invitation_max.try(:inviter_id)
      end
      present opponent_with_status_invitation, with: Representers::OpponentsRepresenter
    end
  end
end
