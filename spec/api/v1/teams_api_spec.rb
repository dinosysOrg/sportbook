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
      let(:params) { { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking, name: name, skill_id: skill.id } }
      let(:make_request) do
        auth_headers = user.create_new_auth_token
        post "/api/v1/tournaments/#{tour.id}/teams", params: params.to_json,
                                                     headers: request_headers.merge(auth_headers)
      end

      let(:tour) { create(:tournament, start_date: Date.new(2017, 5, 15), end_date: Date.new(2017, 5, 24)) }
      let(:user) { create(:api_user, email: 'zi@dinosys.com', password: 'password') }
      let(:venue_ranking) { (1..4).to_a }
      let(:name) { 'TeamA' }
      let(:preferred_time_blocks) { { monday: [[9, 10, 11]] } }
      let(:skill) { create(:skill, name: 'professinal') }

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
          { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking, name: 'TeamA',
            user_ids: [user1.id, user2.id] }
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

      context 'define rank venue for team' do
        it 'creates venue ranking for team' do
          make_request

          expect(response.status).to eq(201)
          team = tour.teams.find_by(name: name)
          expect(team.venue_ranking).to match_array(venue_ranking)
        end
      end

      context 'define timeblock for team' do
        it 'generates correct TimeSlots for team' do
          make_request
          team = tour.teams.find_by(name: name)
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

      context 'define skill for team' do
        it 'adds skill for user' do
          make_request
          skill = user.reload.skill
          expect(User.find(user.id)['skill_id']).to eq(skill.id)
        end
      end

      context 'check skill for user' do
        let(:params) { { preferred_time_blocks: preferred_time_blocks, venue_ranking: venue_ranking, name: name, skill_id: skill1.id } }
        let(:make_request) do
          auth_headers_user_skill = user_with_skill.create_new_auth_token
          post "/api/v1/tournaments/#{tour.id}/teams", params: params.to_json,
                                                       headers: request_headers.merge(auth_headers_user_skill)
        end

        let(:user_with_skill) { create(:api_user, email: 'zi@dinosys.com', password: 'password', skill_id: skill.id) }
        let(:skill) { create(:skill, name: 'professinal') }
        let(:skill1) { create(:skill, name: 'good') }

        it 'doesnt add skill for user if user already has skill' do
          make_request
          skill_reload = user_with_skill.reload.skill
          expect(skill_reload.name).to eq('professinal')
        end
      end

      context 'define venue ranking for team' do
        it 'define rank venue for team' do
          make_request
          team = Team.find_by(name: 'TeamA', tournament_id: tour.id)
          expect(team).to be_present
          expect(response.status).to eq(201)
          expect(team['venue_ranking']).to be_present
          expect(team['venue_ranking'].count).to eq(venue_ranking.count)
          expect(team.status).to eq('registered')
        end
      end

      context 'when fails to save' do
        let(:name) { '' }
        it 'returns error' do
          make_request
          expect(response.status).to eq(422)
        end
      end
    end
  end
end
