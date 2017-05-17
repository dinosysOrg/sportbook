describe 'TeamsApi' do
  describe '#create' do
    let!(:tour) { create(:tournament, start_date: Date.new(2017, 5, 15), end_date: Date.new(2017, 5, 24)) }

    context 'when not signed in' do
      it 'sign up tournament without login' do
        post "/api/v1/tournaments/#{tour.id}/teams"
        expect(response.status).to eq(401)
      end
    end

    context 'when signed in' do
      let(:params) { { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking, name: 'TeamA' } }
      let(:make_request) do
        auth_headers = user.create_new_auth_token
        post "/api/v1/tournaments/#{tour.id}/teams", params: params.to_json,
                                                     headers: request_headers.merge(auth_headers)
      end

      let(:tour) { create(:tournament, start_date: Date.new(2017, 5, 15), end_date: Date.new(2017, 5, 24)) }
      let(:user) { create(:api_user, email: 'zi@dinosys.com', password: 'password') }
      let(:venue_ranking) { (1..4).to_a }
      let(:preferred_time_blocks) { { monday: [[9, 10, 11]] } }

      context 'when user_ids is emtpy' do
        it 'creates team with only the current user' do
          make_request

          expect(response.status).to eq(201)
          team = tour.teams.find_by(name: 'TeamA')
          expect(team).to be_present
          expect(team.players.size).to eq(1)
          expect(team.players.first.user_id).to eq(user.id)
        end
      end

      context 'when user_ids is NOT emtpy' do
        let(:user1) { create(:api_user) }
        let(:user2) { create(:api_user) }
        let(:params) do
          { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking, name: 'TeamA', user_ids: [user1.id, user2.id] }
        end

        it 'creates team with all the users' do
          make_request

          expect(response.status).to eq(201)
          team = tour.teams.find_by(name: 'TeamA')
          expect(team).to be_registered
          expect(team.players.size).to eq(3)
          expect(team.players.pluck(:user_id)).to match_array([user.id, user1.id, user2.id])
        end
      end

      context 'define rank venue for team' do
        it 'creates venue ranking for team' do
          make_request

          expect(response.status).to eq(201)
          team = tour.teams.find_by(name: 'TeamA')
          expect(team.venue_ranking).to match_array(venue_ranking)
        end
      end

      context 'define timeblock for team' do
        let(:date_range) { ((tour.start_date)..(tour.end_date)).to_a }
        let(:preferred_time_blocks) { { monday: [[9, 10, 11]] } }

        it 'generates correct TimeSlots for team' do
          make_request
          team = tour.teams.find_by(name: 'TeamA')
          expect(team.time_slots.pluck(:time)).to match_array(
            [
              Time.new(2017, 5, 15, 9),
              Time.new(2017, 5, 15, 10),
              Time.new(2017, 5, 15, 11),
              Time.new(2017, 5, 22, 9),
              Time.new(2017, 5, 22, 10),
              Time.new(2017, 5, 22, 11)
            ]
          )
        end
      end
    end
  end
end
