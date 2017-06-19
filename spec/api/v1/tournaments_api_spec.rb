describe 'TournamentsApi' do
  let!(:venue) { create(:venue) }
  let!(:my_tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:my_team) { create(:team, :has_players, tournament: my_tournament1) }
  let!(:api_user) { my_team.users.first.becomes ApiUser }
  let(:my_started_tournament) { create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now) }
  let(:auth_headers) { api_user.create_new_auth_token }
  describe "get '/api/v1/tournaments'" do
    it 'show all tournaments' do
      create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
      create(:tournament, start_date: 3.days.from_now, end_date: 4.weeks.from_now)
      create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
      create(:tournament, start_date: 2.days.from_now, end_date: 4.weeks.from_now)
      create(:tournament, start_date: 5.days.ago, end_date: 1.days.ago)
      create(:tournament, start_date: 3.days.ago, end_date: 2.weeks.from_now)
      create(:tournament, start_date: 4.days.ago, end_date: 1.weeks.from_now)
      get '/api/v1/tournaments', headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:tournaments].count).to eq(5)
      expect(json_response[:_embedded][:tournaments][0][:name]).to eq(my_tournament1.name)
    end

    it 'show all tournaments that I signed up for' do
      create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
      create(:tournament, start_date: 3.days.from_now, end_date: 4.weeks.from_now)

      get '/api/v1/tournaments/my-tournaments', headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:tournaments].count).to eq(1)
      expect(json_response[:_embedded][:tournaments][0][:name]).to eq(my_tournament1.name)
    end

    it 'returns error when user is not signed in' do
      get '/api/v1/tournaments/my-tournaments'
      expect(response.status).to eq(401)
    end

    it 'show all upcoming tournaments that I signed up for' do
      create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
      create(:tournament, start_date: 3.days.from_now, end_date: 4.weeks.from_now)
      player2 = create(:player, user: api_user, tournament: my_started_tournament)
      create(:team, players: [player2], tournament: my_started_tournament)

      get '/api/v1/tournaments/my-tournaments/upcoming-tournaments', headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:tournaments].count).to eq(1)
      expect(json_response[:_embedded][:tournaments][0][:name]).to eq(my_tournament1.name)
    end
  end
  describe "get '/api/v1/tournaments/:tournament_id'" do
    describe 'return current tournament detail' do
      context 'show one tournament' do
        before do
          my_tournament1.update_attributes(competition_mode: 'Mode Vi', competition_fee: 'Fee Vi', competition_schedule: 'Schedule Vi', locale: :vi)
          my_tournament1.update_attributes(competition_mode: 'Mode En', competition_fee: 'Fee En', competition_schedule: 'Schedule En', locale: :en)
        end

        it 'without locale param' do
          get "/api/v1/tournaments/#{my_tournament1.id}", headers: request_headers.merge(auth_headers)
          expect(response.status).to eq(200)
          expect(json_response[:name]).to eq(my_tournament1.name)
          expect(json_response[:competition_mode]).to eq 'Mode En'
          expect(json_response[:competition_fee]).to eq 'Fee En'
          expect(json_response[:competition_schedule]).to eq 'Schedule En'
        end

        it 'with locale = vi' do
          get "/api/v1/tournaments/#{my_tournament1.id}?locale=vi", headers: request_headers.merge(auth_headers)
          expect(response.status).to eq(200)
          expect(json_response[:name]).to eq(my_tournament1.name)
          expect(json_response[:competition_mode]).to eq 'Mode Vi'
          expect(json_response[:competition_fee]).to eq 'Fee Vi'
          expect(json_response[:competition_schedule]).to eq 'Schedule Vi'
        end

        it 'with locale = en' do
          get "/api/v1/tournaments/#{my_tournament1.id}?locale=en", headers: request_headers.merge(auth_headers)
          expect(response.status).to eq(200)
          expect(json_response[:name]).to eq(my_tournament1.name)
          expect(json_response[:competition_mode]).to eq 'Mode En'
          expect(json_response[:competition_fee]).to eq 'Fee En'
          expect(json_response[:competition_schedule]).to eq 'Schedule En'
        end

        it 'with current user signed up this tournament' do
          get "/api/v1/tournaments/#{my_tournament1.id}", headers: request_headers.merge(auth_headers)
          expect(response.status).to eq(200)
          expect(json_response[:teams][:id]).to eq(my_team.id)
          expect(json_response[:teams][:status]).to eq(my_team.status)
        end

        it 'with current user not sign up this tournament' do
          other_tournament = create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now)
          get "/api/v1/tournaments/#{other_tournament.id}", headers: request_headers.merge(auth_headers)
          expect(response.status).to eq 200
          expect(json_response[:name]).to eq other_tournament.name
          expect(json_response[:teams]).to be nil
        end
      end
    end
    describe 'return all groups that belong to current tournament' do
      let(:group_api_request) { get "/api/v1/tournaments/#{my_tournament1.id}/groups", headers: request_headers.merge(auth_headers) }

      describe 'return all my group that belong to current tournament' do
        before do
          create(:groups_team, group: my_group, team: my_team)
          create(:groups_team, group: my_group, team: other_team)
        end

        let!(:my_group) { create(:group, tournament: my_tournament1, created_at: 2.days.ago) }
        let!(:other_team) { create(:team, :has_players, tournament: my_tournament1) }
        let!(:my_match) { create(:match, group: my_group, team_a: my_team, team_b: other_team, venue: venue) }

        it 'all opponents have intitations' do
          create(:invitation, :rejected, time: TimeSlot.first.time, invitee: my_match.team_a,
                                         inviter: my_match.team_b, venue: my_match.venue)
          my_accepted_invatation = create(:invitation, :accepted, time: TimeSlot.second.time, invitee: my_match.team_b,
                                                                  inviter: my_match.team_a, venue: my_match.venue)
          group_api_request
          expect(response.status).to eq(200)
          my_group_response = json_response[:my_groups]
          expect(my_group_response.size).to eq(1)
          expect(my_group_response[0][:group_name]).to eq(my_group.name)
          expect(my_group_response[0][:opponent_teams][0][:team_name]).to eq(other_team.name)
          expect(my_group_response[0][:opponent_teams][0][:invitation_invitee_id]).to eq(other_team.id)
          expect(my_group_response[0][:opponent_teams][0][:invitation_inviter_id]).to eq(my_team.id)
          expect(my_group_response[0][:opponent_teams][0][:invitation_status]).to eq(my_accepted_invatation.status)
        end

        it 'At lease one opponent doesnt have any invitations' do
          group_api_request
          expect(response.status).to eq(200)
          my_group_response = json_response[:my_groups]
          expect(my_group_response.size).to eq(1)
          expect(my_group_response[0][:group_name]).to eq(my_group.name)
          expect(my_group_response[0][:opponent_teams][0][:team_name]).to eq(other_team.name)
          expect(my_group_response[0][:opponent_teams][0][:invitation_id]).to be_nil
        end
      end

      describe 'return all other groups that belong to current tournament' do
        let!(:other_group) { create(:group, tournament: my_tournament1, created_at: Time.zone.now) }
        let!(:other_team) { create(:team, :has_players, tournament: my_tournament1) }
        let!(:group_a_other_team) { create(:groups_team, group: other_group, team: other_team) }

        it 'work' do
          group_api_request
          expect(response.status).to eq(200)
          other_groups_response = json_response[:other_groups]
          expect(other_groups_response.size).to eq(1)
          expect(other_groups_response[0][:group_name]).to eq(other_group.name)
          expect(other_groups_response[0][:teams].size).to eq(1)
          expect(other_groups_response[0][:teams][0][:name]).to include(other_team.name)
        end
      end
    end
  end
end
