describe 'TeamsApi' do
  let!(:tour) { create(:tournament, start_date: Date.new(2017, 5, 15), end_date: Date.new(2017, 5, 24)) }
  let(:name) { 'TeamA' }
  describe '#create' do
    context 'when not signed in' do
      it 'sign up tournament without login' do
        post "/api/v1/tournaments/#{tour.id}/teams"
        expect(response.status).to eq(401)
      end
    end

    context 'when signed in' do
      let(:params) { { name: name, skill_id: skill.id, birthday: Date.today, club: club, phone_number: 12_345_666, address: address } }
      let(:auth_headers) { user.create_new_auth_token }
      let(:make_request) do
        post "/api/v1/tournaments/#{tour.id}/teams", params: params.to_json,
                                                     headers: request_headers.merge(auth_headers)
      end

      let(:user) { create(:api_user, email: 'zi@dinosys.com', password: 'password') }
      let(:skill) { create(:skill, name: 'professinal') }
      let(:club) { 'Nhat Nguyen' }
      let(:address) { 'quan 3' }
      context 'when user_ids is emtpy' do
        it 'creates team with only the current user' do
          make_request
          expect(response.status).to eq(201)
          team = tour.teams.find_by(name: name)
          expect(team).to be_present
          expect(team.players.size).to eq(1)
          expect(team.players.first.user_id).to eq(user.id)
        end
      end

      context 'when user_ids is NOT emtpy' do
        let(:user1) { create(:api_user) }
        let(:user2) { create(:api_user) }
        let(:params) do
          { name: 'TeamA', user_ids: [user1.id, user2.id], skill_id: skill.id, birthday: Date.today, club: club,
            phone_number: 12_345_666, address: address }
        end

        it 'creates team with all the users' do
          make_request

          expect(response.status).to eq(201)
          team = tour.teams.find_by(name: name)
          expect(team).to be_registered
          expect(team.players.size).to eq(3)
          expect(team.players.pluck(:user_id)).to match_array([user.id, user1.id, user2.id])
        end
      end

      context 'define bod for user' do
        it 'adds bod for user' do
          make_request
          expect(response.status).to eq(201)
          expect(user.reload.birthday).to eq(Date.today)
        end
      end

      context 'define club for user' do
        it 'adds club for user' do
          make_request
          expect(response.status).to eq(201)
          expect(user.reload.club).to eq(club)
        end
      end

      context 'define phone number for user' do
        it 'adds phone number for user' do
          make_request
          expect(user.reload.phone_number.to_i).to eq(12_345_666)
        end
      end

      context 'add user in response params' do
        it 'get user detail' do
          make_request
          expect(response.status).to eq(201)
          expect(json_response[:user][:id]).to eq(user.id)
        end
      end

      context 'try to request nil params' do
        let(:params) { { name: name, skill_id: skill.id, birthday: Date.today, club: club, phone_number: '', address: '' } }
        it 'throw 422' do
          make_request
          expect(response.status).to eq(422)
        end
      end

      context 'define skill for team' do
        it 'adds skill for user' do
          make_request
          expect(user.reload.skill_id).to eq(skill.id)
        end
      end

      context 'check skill for user' do
        let(:params) { { name: name, skill_id: another_skill.id } }
        let(:make_request) do
          auth_headers_user_skill = user_with_skill.create_new_auth_token
          post "/api/v1/tournaments/#{tour.id}/teams", params: params.to_json,
                                                       headers: request_headers.merge(auth_headers_user_skill)
        end

        let(:user_with_skill) { create(:api_user, email: 'zi@dinosys.com', password: 'password', skill_id: assigned_skill.id) }
        let(:assigned_skill) { create(:skill, name: 'professinal') }
        let(:another_skill) { create(:skill, name: 'good') }

        it 'doesnt add skill for user if user already has skill' do
          make_request
          skill_reload = user_with_skill.reload.skill
          expect(skill_reload.name).to eq('professinal')
        end
      end

      context 'when fails to save' do
        let(:name) { '' }
        it 'returns error without locale' do
          make_request
          expect(response.status).to eq(422)
          expect(json_response[:errors].first[:attribute]).to eq 'name'
          expect(json_response[:errors].first[:message]).to include "can't be blank"
        end

        it 'returns error with locale = vi' do
          params.delete :name
          post "/api/v1/tournaments/#{tour.id}/teams?locale=vi", params: params.to_json,
                                                                 headers: request_headers.merge(auth_headers)
          expect(response.status).to eq(422)
          expect(json_response[:errors].first[:attribute]).to eq 'name'
          expect(json_response[:errors].first[:message]).to include 'bị thiếu'
        end
      end
    end
  end

  describe '#time_slots' do
    let(:new_venue_ranking) { (1..4).to_a }
    let(:team) { create(:team, :has_players, tournament: tour, name: 'TeamA', venue_ranking: new_venue_ranking) }
    let(:venue_ranking) { (5..8).to_a }
    let(:preferred_time_blocks) { { 'tuesday' => [[9, 10, 11]] } }

    describe 'user can update timeslot and venue ranking for thier team' do
      let!(:api_user) { team.players.first.user.becomes ApiUser }
      let!(:auth_headers) { api_user.create_new_auth_token }
      it 'returns the available time slots' do
        expect(TimeSlotService).to receive(:possible_time_slots).and_call_original

        get "/api/v1/teams/#{team.id}/time_slots", params: { type: 'available' }.as_json,
                                                   headers: request_headers.merge(auth_headers)

        expect(response.status).to eq(200)
        expect(json_response[:_embedded][:venues]).to_not be_nil
      end

      it 'create time slot and venue ranking for team' do
        team.update_attribute('venue_ranking', [])
        put "/api/v1/teams/#{team.id}", params: { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking }.to_json,
                                        headers: request_headers.merge(auth_headers)
        expect(team.reload.time_slots.pluck(:time)).to match_array(
          [
            Time.new(2017, 5, 16, 9),
            Time.new(2017, 5, 16, 10),
            Time.new(2017, 5, 16, 11),
            Time.new(2017, 5, 23, 9),
            Time.new(2017, 5, 23, 10),
            Time.new(2017, 5, 23, 11)
          ]
        )
        expect(team.reload.preferred_time_blocks).to match_array(preferred_time_blocks)
        expect(team.reload.venue_ranking).to match_array(venue_ranking)
      end

      it 'updates time slot and venue ranking for team' do
        create(:time_slot, object: team, time: Time.new(2017, 5, 15, 9), available: false)
        create(:time_slot, object: team, time: Time.new(2017, 5, 15, 10))
        expect(team.time_slots.pluck(:time)).to match_array(
          [
            Time.new(2017, 5, 15, 9),
            Time.new(2017, 5, 15, 10)
          ]
        )
        expect(team.venue_ranking).to match_array(new_venue_ranking)
        expect(team.reload.preferred_time_blocks).to be_nil
        put "/api/v1/teams/#{team.id}", params: { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking }.to_json,
                                        headers: request_headers.merge(auth_headers)
        expect(response.status).to eq(200)
        team = tour.teams.find_by(name: name)
        expect(team.time_slots.pluck(:time)).to match_array(
          [
            Time.new(2017, 5, 15, 9),
            Time.new(2017, 5, 16, 9),
            Time.new(2017, 5, 16, 10),
            Time.new(2017, 5, 16, 11),
            Time.new(2017, 5, 23, 9),
            Time.new(2017, 5, 23, 10),
            Time.new(2017, 5, 23, 11)
          ]
        )
        expect(team.preferred_time_blocks).to match_array(preferred_time_blocks)
        expect(team.venue_ranking).to match_array(venue_ranking)
      end

      it 'Get time_block and venue ranking for team' do
        new_preferred_time_blocks = { monday: [[8, 11, 12]] }
        team1 = create(:team, :has_players, tournament: tour, name: 'TeamA', venue_ranking: venue_ranking,
                                            preferred_time_blocks: new_preferred_time_blocks)
        get "/api/v1/teams/#{team1.id}/time_blocks", params: {}.as_json,
                                                     headers: request_headers.merge(auth_headers)

        expect(response.status).to eq(200)
        expect(json_response[:preferred_time_blocks]).to match_array(new_preferred_time_blocks)
        expect(json_response[:venue_ranking]).to match_array(venue_ranking)
      end
    end
    describe 'current user can not update timeslot and venue for another team' do
      let(:api_user) { create(:api_user) }
      let(:auth_headers) { api_user.create_new_auth_token }
      it 'throw 405' do
        put "/api/v1/teams/#{team.id}", params: { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking }.to_json,
                                        headers: request_headers.merge(auth_headers)
        expect(response.status).to eq(405)
      end
    end
  end
end
