describe 'TournamentsApi' do
  let!(:my_tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:my_team) { create(:team, :has_players, tournament: my_tournament1) }
  let!(:api_user) { my_team.users.first.becomes ApiUser }
  let(:my_started_tournament) { create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now) }
  let(:auth_headers) { api_user.create_new_auth_token }
  let(:user) { FactoryGirl.create(:user) }
  let(:player) { create(:player, user: user, tournament: my_tournament1, team: my_team) }
  let(:params) do
    { first_name: 'Jeny',
      last_name: 'Kim',
      address: '33 Paster, Q3, HCM',
      birthday: '1990-01-01',
      club: 'Chelsea' }
  end

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

  it 'show all upcoming confirmed match that is belong to current_user' do
    create(:match, time: 1.days.ago.at_beginning_of_hour, team_a: my_team)
    match1 = create(:match, time: 2.days.from_now.at_beginning_of_hour, team_b: my_team)

    get '/api/v1/tournaments/my-tournaments/upcoming-matches', headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:matches].count).to eq(1)
    expect(json_response[:_embedded][:matches][0][:team_b][:name]).to eq(match1.team_b.name)
    expect(Time.parse(json_response[:_embedded][:matches][0][:time])).to eq(match1.time)
  end

  it 'update infomations for profile player' do
    expect(user.first_name).to_not match(params[:first_name])
    expect(user.last_name).to_not match(params[:last_name])
    expect(user.address).to_not match(params[:last_name])
    expect(user.birthday).to_not match(params[:birthday])
    expect(user.club).to_not match(params[:club])
    put "/api/v1/tournaments/#{my_tournament1.id}/players/#{player.id}", params: params.to_json,
                                                                         headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:user][:first_name]).to match(params[:first_name])
    expect(json_response[:user][:last_name]).to match(params[:last_name])
    expect(json_response[:user][:address]).to match(params[:address])
    expect(json_response[:user][:birthday]).to match(params[:birthday])
    expect(json_response[:user][:club]).to match(params[:club])
  end
end
