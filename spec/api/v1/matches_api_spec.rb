describe 'MatchesApi' do
  let!(:my_tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:my_team) { create(:team, :has_players, tournament: my_tournament1) }
  let!(:api_user) { my_team.users.first.becomes ApiUser }
  let(:auth_headers) { api_user.create_new_auth_token }
  let(:tour_id) { my_tournament1.id }

  it 'limit for matches by upcoming and belong to current_user' do
    tournament2 = create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now)
    my_player2 = create(:player, user: api_user, tournament: tournament2)
    my_team2 = create(:team, players: [my_player2], tournament: tournament2)
    match1 = create(:match, time: 1.days.from_now.at_beginning_of_hour, team_b: my_team)
    match2 = create(:match, time: 1.days.from_now.at_beginning_of_hour, team_b: my_team2)

    get '/api/v1/matches', params: { type: 'my_upcoming', tournament_id: nil, limit: 2, page: 1 }.as_json,
                           headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(request.params[:limit].to_i)
    expect(json_response[:_embedded][:matches][0][:team_b][:name]).to eq(match1.team_b.name)
    expect(Time.parse(json_response[:_embedded][:matches][0][:time])).to eq(match1.time)
  end

  it 'limit for matches by history and belong to current_user' do
    tournament2 = create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now)
    my_player2 = create(:player, user: api_user, tournament: tournament2)
    my_team2 = create(:team, players: [my_player2], tournament: tournament2)
    match1 = create(:match, time: 2.days.ago.at_beginning_of_hour, team_a: my_team)
    match2 = create(:match, time: 3.days.ago.at_beginning_of_hour, team_b: my_team2)

    get '/api/v1/matches', params: { type: 'my_historical', tournament_id: nil, limit: 2, page: 1 }.as_json,
                           headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(request.params[:limit].to_i)
    expect(json_response[:_embedded][:matches][0][:team_a][:name]).to eq(match1.team_a.name)
    expect(Time.parse(json_response[:_embedded][:matches][0][:time])).to eq(match1.time)
    expect(json_response[:_embedded][:matches][1][:team_b][:name]).to eq(match2.team_b.name)
    expect(Time.parse(json_response[:_embedded][:matches][1][:time])).to eq(match2.time)
  end

  it 'limit for matches by belong to tournament' do
    match1 = create(:match, time: 5.days.from_now.at_beginning_of_hour, team_b: my_team)
    match2 = create(:match, time: 4.days.ago.at_beginning_of_hour, team_a: my_team)
    match3 = create(:match, time: 3.days.from_now.at_beginning_of_hour, team_a: my_team)
    get '/api/v1/matches', params: { type: '', tournament_id: tour_id, limit: 3, page: 1 }.as_json,
                           headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(request.params[:limit].to_i)
    expect(json_response[:_embedded][:matches][0][:team_b][:name]).to eq(match1.team_b.name)
    expect(Time.parse(json_response[:_embedded][:matches][0][:time])).to eq(match1.time)
    expect(json_response[:_embedded][:matches][0][:team_b][:tournament_id]).to eq(request.params[:tournament_id].to_i)
  end

  context 'pagination when upcoming' do
    let!(:matches) { FactoryGirl.create_list(:match, 10, time: 5.days.from_now.at_beginning_of_hour, team_a: my_team) }
    it 'pagination for matches by upcoming and belong to current_user' do
      get '/api/v1/matches', params: { type: 'my_upcoming', tournament_id: nil, limit: 5, page: 2 }.as_json,
                             headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches].count).to eq(5)
    end
  end

  context 'pagination when history or tournament' do
    let!(:matches) { FactoryGirl.create_list(:match, 10, team_a: my_team) }
    it 'pagination for matches by history and belong to current_user' do
      get '/api/v1/matches', params: { type: 'my_historical', tournament_id: nil, limit: 5, page: 2 }.as_json,
                             headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches].count).to eq(5)
    end

    it 'pagination for matches by belong to tournament' do
      get '/api/v1/matches', params: { type: '', tournament_id: tour_id, limit: 5, page: 2 }.as_json,
                             headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches].count).to eq(5)
    end
  end
end
