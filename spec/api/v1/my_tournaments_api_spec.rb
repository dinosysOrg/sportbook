describe 'MyTournamentsApi' do
  let!(:my_tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:my_team) { create(:team, :has_players, tournament: my_tournament1) }
  let!(:api_user) { my_team.users.first.becomes ApiUser }
  let(:my_started_tournament) { create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now) }
  let(:auth_headers) { api_user.create_new_auth_token }

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
  end
end
