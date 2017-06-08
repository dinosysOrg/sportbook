describe 'TournamentsApi' do
  let!(:my_tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:my_team) { create(:team, :has_players, tournament: my_tournament1) }
  let!(:api_user) { my_team.users.first.becomes ApiUser }
  let(:my_started_tournament) { create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now) }
  let(:auth_headers) { api_user.create_new_auth_token }
  describe 'have many tuornaments' do
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

    it 'show all upcoming confirmed match that is belong to current_user' do
      create(:match, time: 1.days.ago.at_beginning_of_hour, team_a: my_team)
      match1 = create(:match, time: 2.days.from_now.at_beginning_of_hour, team_b: my_team)

      get '/api/v1/tournaments/my-tournaments/upcoming-matches', headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches].count).to eq(1)
      expect(json_response[:_embedded][:matches][0][:team_b][:name]).to eq(match1.team_b.name)
      expect(Time.parse(json_response[:_embedded][:matches][0][:time])).to eq(match1.time)
    end
  end

  describe 'choose one tournament' do
    let!(:my_group) { create(:group, tournament: my_tournament1, created_at: 2.days.ago) }
    let!(:other_group) { create(:group, tournament: my_tournament1, created_at: 1.days.ago) }
    let!(:other_team) { create(:team, :has_players, tournament: my_tournament1) }
    let!(:other_team_1) { create(:team, :has_players, tournament: my_tournament1) }
    let!(:group_a_myteam) { create(:groups_team, group: my_group, team: my_team) }
    let!(:group_a_other_team) { create(:groups_team, group: my_group, team: other_team) }
    let!(:group_b_myteam) { create(:groups_team, group: other_group, team: my_team) }
    let!(:group_b_other_team) { create(:groups_team, group: other_group, team: other_team_1) }
    let!(:match_1) { create(:match, group: my_group, team_a: my_team, team_b: other_team) }
    let!(:match_2) { create(:match, group: other_group, team_a: my_team, team_b: other_team_1) }
    let!(:invitation_a) { create(:invitation, :accepted, invitee: match_1.team_a, inviter: match_1.team_b, venue: match_1.venue) }
    it 'show one tournaments' do
      get "/api/v1/tournaments/#{my_tournament1.id}", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:name]).to eq(my_tournament1.name)
    end

    it 'view opponments when no one doesnt have any invitation' do
      invitation_b = create(:invitation, :accepted, invitee: match_2.team_b, inviter: match_2.team_a, venue: match_2.venue)
      get "/api/v1/tournaments/#{my_tournament1.id}/view_opponents", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      teams_in_group = other_group.teams.reject { |t| t == my_team }
      opponments_response = json_response[:_embedded][:opponents]
      expect(opponments_response.size).to eq(teams_in_group.size)
      expect(opponments_response[0][:team_name]).to eq(teams_in_group[0].name)
      expect(opponments_response[0][:invitation_id]).to eq(invitation_b.id)
      expect(opponments_response[0][:invitation_status]).to eq(invitation_b.status)
    end

    it 'view opponments when at lease one team doesnt have invitation' do
      get "/api/v1/tournaments/#{my_tournament1.id}/view_opponents", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      teams_in_group = other_group.teams.reject { |t| t == my_team }
      opponments_response = json_response[:_embedded][:opponents]
      expect(opponments_response.size).to eq(teams_in_group.size)
      expect(opponments_response[0][:team_name]).to eq(teams_in_group[0].name)
    end
  end
end
