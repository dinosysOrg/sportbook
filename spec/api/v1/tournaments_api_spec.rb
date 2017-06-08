describe 'TournamentsApi' do
  let!(:my_tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:my_team) { create(:team, :has_players, tournament: my_tournament1) }
  let!(:api_user) { my_team.users.first.becomes ApiUser }
  let(:my_started_tournament) { create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now) }
  let(:auth_headers) { api_user.create_new_auth_token }
  let(:tour_id) { my_tournament1.id }

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

  it 'show one tournaments' do
    get "/api/v1/tournaments/#{my_tournament1.id}", headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:name]).to eq(my_tournament1.name)
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

  it 'limit for matches by upcoming and belong to current_user' do
    create(:match, time: 1.days.ago.at_beginning_of_hour, team_a: my_team)
    match1 = create(:match, time: 2.days.from_now.at_beginning_of_hour, team_b: my_team)

    get '/api/v1/matches', params: { type: 'upcoming', tournament_id: nil, limit: 1, page: 1 }.as_json, headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(request.params[:limit].to_i)
    expect(json_response[:_embedded][:matches][0][:team_b][:name]).to eq(match1.team_b.name)
    expect(Time.parse(json_response[:_embedded][:matches][0][:time])).to eq(match1.time)
  end

  it 'limit for matches by history and belong to current_user' do
    match1 = create(:match, time: 2.days.ago.at_beginning_of_hour, team_a: my_team)
    match2 = create(:match, time: 3.days.ago.at_beginning_of_hour, team_b: my_team)

    get '/api/v1/matches', params: { type: 'history', tournament_id: nil, limit: 2, page: 1 }.as_json, headers: request_headers.merge(auth_headers)
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
    get '/api/v1/matches', params: { type: '', tournament_id: tour_id, limit: 3, page: 1 }.as_json, headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(request.params[:limit].to_i)
    expect(json_response[:_embedded][:matches][0][:team_b][:name]).to eq(match1.team_b.name)
    expect(Time.parse(json_response[:_embedded][:matches][0][:time])).to eq(match1.time)
  end

  it 'page for matches by upcoming and belong to current_user' do
    create(:match, time: 1.days.from_now.at_beginning_of_hour, team_a: my_team)
    get '/api/v1/matches', params: { type: 'upcoming', tournament_id: nil, limit: 5, page: 2 }.as_json, headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(0)
  end

  it 'page for matches by history and belong to current_user' do
    create(:match, time: 2.days.from_now.at_beginning_of_hour, team_a: my_team)
    get '/api/v1/matches', params: { type: 'history', tournament_id: nil, limit: 5, page: 3 }.as_json, headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(0)
  end

  it 'page for matches by belong to tournament' do
    create(:match, time: 3.days.from_now.at_beginning_of_hour, team_a: my_team)
    get '/api/v1/matches', params: { type: '', tournament_id: tour_id, limit: 50, page: 4 }.as_json, headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(0)
  end
end
