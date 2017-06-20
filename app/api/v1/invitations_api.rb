module V1
  class InvitationsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    include ExceptionHandlers

    desc 'create invitation', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 405, message: 'You can not create invitation for someone' },
      { code: 422, message: 'This time slot is no longer available' }
    ]
    params do
      requires :time, type: Time
      requires :venue_id, type: Integer
      requires :match_id, type: Integer
    end
    post 'invitations/create' do
      match = Match.find params[:match_id]
      if match.team_a.user_ids.include?(current_api_user.id)
        inviter_id = match.team_a_id
        invitee_id = match.team_b_id
      elsif match.team_b.user_ids.include?(current_api_user.id)
        inviter_id = match.team_b_id
        invitee_id = match.team_a_id
      else
        error!(I18n.t('activerecord.errors.models.invitation.attributes.team.wrong_team'), 405)
      end

      Invitation.check_reject_invitation params[:match_id]
      expired = Invitation.expired.where(match_id: params[:match_id])
      unless expired.empty?
        error!(I18n.t('activerecord.errors.models.invitation.attributes.team.no_response_after_reject'), 405)
      end

      invitation = Invitation.create!(status: 'created', time: params[:time], invitee_id: invitee_id, inviter_id: inviter_id,
                                      match_id: params[:match_id], venue_id: params[:venue_id])
      team = Team.find(invitation.invitee_id)
      ApplicationMailer.invitation_mail(team.users.pluck(:email)).deliver_now
      invitation.sent!
    end

    desc 'accepted invitation', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 405, message: 'You cant accept invitation that current user is not belong accepted team' },
      { code: 405, message: 'Your invitation is expired, You are expired' },
      { code: 422, message: 'You cant accept invitation that already is rejected' },
      { code: 422, message: 'You cant accept invitation that already is accepted' },
      { code: 422, message: 'This timeslot is picked' }
    ]
    params do
      requires :invitation_id, type: Integer
    end
    put 'invitations/:invitation_id/accept' do
      invitation = Invitation.find(params[:invitation_id])
      invitation.validate_deadline_for_api
      unless invitation.invitee.user_ids.include?(current_api_user.id)
        error!(I18n.t('activerecord.errors.models.invitation.attributes.team.wrong_team'), 405)
      end
      invitation.accept!
    end

    desc 'rejected invitation', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 405, message: 'You cant reject invitation that current user is not belong rejected team' },
      { code: 405, message: 'Your invitation is expired, You are expired' },
      { code: 422, message: 'You cant reject invitation that already is rejected' },
      { code: 422, message: 'You cant reject invitation that already is accepted' }
    ]
    params do
      requires :invitation_id, type: Integer
    end
    put 'invitations/:invitation_id/reject' do
      invitation = Invitation.find params[:invitation_id]
      invitation.validate_deadline_for_api
      unless invitation.invitee.user_ids.include?(current_api_user.id)
        error!(I18n.t('activerecord.errors.models.invitation.attributes.team.wrong_team'), 405)
      end
      invitation.reject!
    end

    desc 'show detail invitation', failure: [
      { code: 401, message: 'Unauthorized, missing token in header' },
      { code: 405, message: 'You cant do this operation that current user is not belong invitee team' },
      { code: 422, message: 'Missing Invitation Id' }
    ]
    params do
      requires :invitation_id, type: Integer
    end
    get 'invitations/:invitation_id' do
      invitation = Invitation.find(params[:invitation_id])
      unless invitation.invitee.user_ids.include?(current_api_user.id)
        error!(I18n.t('activerecord.errors.models.invitation.attributes.team.wrong_team'), 405)
      end
      present invitation, with: Representers::InvitationRepresenter
    end
  end
end
