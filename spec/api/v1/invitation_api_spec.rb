describe 'InvitationsApi' do
  let!(:match) { create(:match, time: nil, venue: nil) }
  let(:auth_headers) { api_user.create_new_auth_token }
  let(:venue) { create(:venue) }
  let(:time_slot_venue) { create(:time_slot, object: venue, available: true) }
  let!(:time_slot_team_a) { create(:time_slot, object: match.team_a, available: true) }

  describe '#create' do
    let(:api_user) { match.team_b.users.first.becomes ApiUser }
    let(:make_request) { post '/api/v1/invitations/create', params: params.to_json, headers: request_headers.merge(auth_headers) }

    context 'when not log in' do
      it 'throws 401' do
        post '/api/v1/invitations/create'
        expect(response.status).to eq(401)
      end
    end

    context 'when match does not have any invitation yet' do
      let(:params) { { time: time_slot_venue.time, match_id: match.id, venue_id: venue.id } }
      it 'creates invitaion' do
        expect { make_request }.to change(Invitation, :count).by(1)
        expect(response.status).to eq(201)
        invitation_team = Invitation.find_by_invitee_id(match.team_a.id)
        expect(invitation_team.time).to eq(time_slot_venue.time)
        expect(invitation_team.venue_id).to eq(venue.id)
        expect(invitation_team).to be_pending
      end
    end

    context 'when already had one reject invitation' do
      let(:params) { { time: time_slot_venue.time, match_id: match.id, venue_id: venue.id } }
      let!(:invitation) do
        create :invitation, :rejected,
               time: time_slot_venue.time, match: match, venue: venue,
               invitee: match.team_a, inviter: match.team_b,
               created_at: 1.days.ago.at_beginning_of_hour
      end
      it 'can not create response invitation after 1day ' do
        make_request
        expect(response.status).to eq(405)
        expect(invitation.reload).to be_expired
        expect(Invitation.count).to eq(1)
      end
    end

    context 'when time slot is no longer available' do
      let(:params) { { time: time_slot_venue.time, match_id: match.id, venue_id: venue.id } }
      it 'throws 422' do
        time_slot_venue
        TimeSlot.update_all available: false
        expect { make_request }.to_not change(Invitation, :count)
        expect(response.status).to eq(422)
      end
    end

    context 'when match does not belong to signed in user' do
      let(:api_user) { create :api_user }
      let(:params) { { time: time_slot_venue.time, match_id: match.id, venue_id: venue.id } }
      it 'throws 405' do
        make_request
        expect(response.status).to eq(405)
      end
    end
  end

  describe '#accept' do
    let(:api_user) { pending_invitation.invitee.users.first.becomes ApiUser }
    let(:pending_invitation) do
      create :invitation, :pending,
             time: time_slot_venue.time, match: match, venue: venue, invitee: match.team_a, inviter: match.team_b
    end
    let(:accept_request) { put "/api/v1/invitations/#{pending_invitation.id}/accept", params: {}.to_json, headers: request_headers.merge(auth_headers) }

    context 'when not log in' do
      it 'throws 401' do
        post "/api/v1/invitations/#{pending_invitation.id}/accept"
        expect(response.status).to eq(401)
      end
    end

    context 'accept invitation' do
      it 'success 200, update status for invitation' do
        accept_request
        expect(pending_invitation.reload).to be_accepted
      end

      it 'update status timeslot for invitee, inviter, venue' do
        different_time_slot_venue = create(:time_slot, time: 1.days.from_now, object: venue, available: true)
        create(:time_slot, time: time_slot_venue.time, object: venue, available: false)

        accept_request

        expect(time_slot_venue.reload).to_not be_available
        expect(time_slot_team_a.reload).to_not be_available
        expect(different_time_slot_venue.reload).to be_available

        inviter = pending_invitation.inviter
        time_slot_team_b = inviter.time_slots.find_by(time: pending_invitation.time)
        expect(time_slot_team_b).to_not be_available
      end

      it 'update match id for time slots' do
        expect(time_slot_venue.match_id).to be_nil
        expect(time_slot_team_a.match_id).to be_nil

        accept_request
        expect(time_slot_venue.reload.match_id).to eq(match.id)
        expect(time_slot_team_a.reload.match_id).to eq(match.id)

        inviter = pending_invitation.inviter
        time_slot_team_b = inviter.time_slots.find_by(time: pending_invitation.time)
        expect(time_slot_team_b.match_id).to eq(match.id)
      end
    end

    context 'update for this match that is belong to invitation' do
      it 'success 200' do
        accept_request
        match.reload
        expect(match.time.at_beginning_of_hour).to eq(pending_invitation.time.at_beginning_of_hour)
        expect(match.venue).to eq(venue)
      end
    end

    context 'cant accept invitation that already is accepted' do
      it 'throws 405' do
        pending_invitation.accept!
        accept_request
        expect(response.status).to eq(405)
      end
    end

    context 'cant accept invitation that already is rejected' do
      let(:params) { { time: time_slot_venue.time, invitee_id: match.team_b.id, inviter_id: match.team_a.id, match_id: match.id, venue_id: venue.id } }
      it 'throws 405' do
        pending_invitation.reject!
        accept_request
        expect(response.status).to eq(405)
      end
    end

    context 'cant accept invitation that current user is not belong accepted team' do
      let(:api_user) { pending_invitation.inviter.users.first.becomes ApiUser }
      it 'throws 405' do
        accept_request
        expect(response.status).to eq(405)
      end
    end

    context 'cant accept invitation that is expired' do
      let(:pending_invitation) do
        create :invitation, :pending,
               time: time_slot_venue.time, created_at: 1.days.ago.at_beginning_of_hour, match: match, venue: venue
      end
      it 'throws 405' do
        accept_request
        expect(response.status).to eq(405)
        expect(pending_invitation.reload).to be_expired
      end
    end
  end

  describe '#reject' do
    let(:api_user) { pending_invitation.invitee.users.first.becomes ApiUser }
    let(:pending_invitation) { create :invitation, :pending, time: time_slot_venue.time, match: match, venue: venue }
    let(:reject_request) { put "/api/v1/invitations/#{pending_invitation.id}/reject", params: {}.to_json, headers: request_headers.merge(auth_headers) }

    context 'when not log in' do
      it 'throws 401' do
        post "/api/v1/invitations/#{pending_invitation.id}/reject"
        expect(response.status).to eq(401)
      end
    end

    context 'reject invitation' do
      it 'success 200' do
        reject_request
        expect(pending_invitation.reload).to be_rejected
      end
    end

    context 'cant reject invitation that already is rejected' do
      it 'throws 405' do
        pending_invitation.reject!
        reject_request
        expect(response.status).to eq(405)
      end
    end

    context 'cant reject invitation that already is accepted' do
      it 'throws 405' do
        pending_invitation.accept!
        reject_request
        expect(response.status).to eq(405)
      end
    end

    context 'cant reject invitation that current user is not belong rejected team' do
      let(:api_user) { pending_invitation.inviter.users.first.becomes ApiUser }
      it 'throws 405' do
        reject_request
        expect(response.status).to eq(405)
      end
    end

    context 'cant reject invitation that is expired' do
      let(:pending_invitation) do
        create :invitation, :pending, time: time_slot_venue.time, created_at: 1.days.ago.at_beginning_of_hour, match: match, venue: venue
      end
      it 'throws 405' do
        reject_request
        expect(response.status).to eq(405)
        expect(pending_invitation.reload).to be_expired
      end
    end
  end

  describe 'show detail invitation' do
    let(:pending_invitation) do
      create :invitation, :pending,
             time: time_slot_venue.time, match: match, venue: venue, invitee: match.team_a, inviter: match.team_b
    end
    let(:api_user) { pending_invitation.invitee.users.first.becomes ApiUser }
    let(:show_request) { get "/api/v1/invitations/#{pending_invitation.id}", headers: request_headers.merge(auth_headers) }
    context 'view invitation details' do
      it 'return detail invitation' do
        show_request
        expect(response.status).to eq(200)
        expect(json_response[:invitee][:name]).to eq(pending_invitation.invitee.name)
      end
    end
    context 'show error when current is not belong to invitee team' do
      let(:api_user) { pending_invitation.inviter.users.first.becomes ApiUser }
      it 'throws 405' do
        show_request
        expect(response.status).to eq(405)
      end
    end
  end
end
