module V1
  class InvitationsApi < BaseApi
    auth :grape_devise_token_auth, resource_class: :user

    helpers GrapeDeviseTokenAuth::AuthHelpers

    before do
      authenticate_api_user!
    end

    include ExceptionHandlers

    desc 'create invitation'
    params do
      requires :time, type: Time
      requires :venue_id, type: Integer
      requires :match_id, type: Integer
    end
    post 'invitations/create' do
      available_time_slots = TimeSlot.where(time: params[:time], object_id: params[:venue_id], available: true)
      error!('This time slot is picked', 422) if available_time_slots.empty?

      match = Match.find params[:match_id]
      if match.team_a.user_ids.include?(current_api_user.id)
        inviter_id = match.team_a_id
        invitee_id = match.team_b_id
      elsif match.team_b.user_ids.include?(current_api_user.id)
        inviter_id = match.team_b_id
        invitee_id = match.team_a_id
      else
        error!('You are not in the team that is requresting to create invitation', 405)
      end

      invitation = Invitation.create!( status: 'created', time: params[:time],
													             invitee_id: invitee_id, inviter_id: inviter_id, match_id: params[:match_id], venue_id: params[:venue_id] )
      team = Team.find(invitation.invitee_id)
      team.users.each do |user|
        ApplicationMailer.mailer(user.email).deliver_now
      end
      invitation.tranform_pending!
    end

    desc 'approved invitation'
    put 'invitations/:invitation_id/accept' do
      invitation = Invitation.find(params[:invitation_id])
      error!('You are not in the team that can accept this invitation', 405) unless invitation.invitee.user_ids.include?(current_api_user.id)
      invitation.accept!
    end

    desc 'rejected invitation'
    put 'invitations/:invitation_id/reject' do
      invitation = Invitation.find params[:invitation_id]
      error!('You are not in the team that can reject this invitation', 405) unless invitation.invitee.user_ids.include?(current_api_user.id)
      invitation.reject!
    end
  end
end
