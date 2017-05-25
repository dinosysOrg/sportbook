describe 'InvitationsApi' do
	let!(:match) { create(:match) }
	let(:auth_headers) { api_user.create_new_auth_token }

	describe '#create' do
		let(:api_user) { match.team_b.users.first.becomes ApiUser }
		let!(:time_slot) { create(:time_slot, object: venue, available: true) }
		let(:venue) { create(:venue) }
		let(:make_request) { post "/api/v1/invitations/create", params: params.to_json,
																					 									headers: request_headers.merge(auth_headers) }

		context 'when not log in' do
			it 'throws 401' do
				post "/api/v1/invitations/create"
				expect(response.status).to eq(401)
			end
		end

		context 'when match does not have any invitation yet' do
			let(:params) { {time: time_slot.time, match_id: match.id, venue_id: venue.id} }
			it 'creates invitaion' do
				expect { make_request }.to change(Invitation, :count).by(1)
				expect(response.status).to eq(201)
				invitation_team = Invitation.find_by_invitee_id(match.team_a.id)
				expect(invitation_team.time).to eq(time_slot.time)
        expect(invitation_team.venue_id).to eq(venue.id)
				expect(invitation_team).to be_pending
			end
		end

		context 'when time slot is no longer available' do
			let(:params) { { time: time_slot.time, match_id: match.id, venue_id: venue.id} }
			it 'throws 422' do
				TimeSlot.update_all available: false
				expect { make_request }.to_not change(Invitation, :count)
				expect(response.status).to eq(422)
			end
		end

		context 'when match does not belong to signed in user' do
			let(:api_user) { create :api_user }
			let(:params) { { time: time_slot.time, match_id: match.id, venue_id: venue.id} }
			it 'throws 405' do
				make_request
				expect(response.status).to eq(405)
			end
		end
	end

	describe '#accept' do
		let(:api_user) { pending_invitation.invitee.users.first.becomes ApiUser }
		let(:pending_invitation) { create :invitation, :pending, match: match }
		let(:accept_request) { put "/api/v1/invitations/#{pending_invitation.id}/accept", params: {}.to_json,
																					 																						headers: request_headers.merge(auth_headers) }
		context 'when not log in' do
			it 'throws 401' do
				post "/api/v1/invitations/#{pending_invitation.id}/accept"
				expect(response.status).to eq(401)
			end
		end

		context 'accept invitation' do
			it 'success 200' do
				accept_request
				expect(pending_invitation.reload).to be_accepted
			end
		end

		context 'cant accept invitation that already is accepted' do
			it 'throws 422' do
				pending_invitation.accept!
				accept_request
				expect(response.status).to eq(422)
			end
		end

		context 'cant accept invitation that already is rejected' do
			let(:params) { { time: time_slot.time, invitee_id: match.team_b.id, inviter_id: match.team_a.id, match_id: match.id, venue_id: venue.id} }
			it 'throws 422' do
				pending_invitation.reject!
				accept_request
				expect(response.status).to eq(422)
			end
		end

		context 'cant accept invitation that current user is not belong accepted team' do
			let(:api_user) { pending_invitation.inviter.users.first.becomes ApiUser }
			it 'throws 405' do
				accept_request
				expect(response.status).to eq(405)
			end
		end
	end

	describe '#reject' do
		let(:api_user) { pending_invitation.invitee.users.first.becomes ApiUser }
		let(:pending_invitation) { create :invitation, :pending, match: match }
		let(:reject_request) { put "/api/v1/invitations/#{pending_invitation.id}/reject", params: {}.to_json,
																					 																						headers: request_headers.merge(auth_headers) }

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
			it 'throws 422' do
				pending_invitation.reject!
				reject_request
				expect(response.status).to eq(422)
			end
		end

		context 'cant reject invitation that already is accepted' do
			it 'throws 422' do
				pending_invitation.accept!
				reject_request
				expect(response.status).to eq(422)
			end
		end

		context 'cant reject invitation that current user is not belong rejected team' do
			let(:api_user) { pending_invitation.inviter.users.first.becomes ApiUser }
			it 'throws 405' do
				reject_request
				expect(response.status).to eq(405)
			end
		end
	end
end