describe 'TournamentsApi' do
  let!(:my_tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:my_team) { create(:team, :has_players, tournament: my_tournament1) }
  let!(:api_user) { my_team.users.first.becomes ApiUser }
  let(:my_started_tournament) { create(:tournament, start_date: 1.days.ago, end_date: 2.weeks.from_now) }
  let(:auth_headers) { api_user.create_new_auth_token }

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

  context 'show one tournament' do
    before do
      my_tournament1.update_attributes(competition_mode: 'Mode Vi', competition_fee: 'Fee Vi', competition_schedule: 'Schedule Vi', locale: :vi)
      my_tournament1.update_attributes(competition_mode: 'Mode En', competition_fee: 'Fee En', competition_schedule: 'Schedule En')
    end

    it 'without locale param' do
      get "/api/v1/tournaments/#{my_tournament1.id}", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:name]).to eq(my_tournament1.name)
      expect(json_response[:competition_mode]).to eq(my_tournament1.competition_mode(:vi))
      expect(json_response[:competition_fee]).to eq(my_tournament1.competition_fee(:vi))
      expect(json_response[:competition_schedule]).to eq(my_tournament1.competition_schedule(:vi))
    end

    it 'with locale = vi' do
      get "/api/v1/tournaments/#{my_tournament1.id}?locale=vi", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:name]).to eq(my_tournament1.name)
      expect(json_response[:competition_mode]).to eq(my_tournament1.competition_mode(:vi))
      expect(json_response[:competition_fee]).to eq(my_tournament1.competition_fee(:vi))
      expect(json_response[:competition_schedule]).to eq(my_tournament1.competition_schedule(:vi))
    end

    it 'with locale = en' do
      get "/api/v1/tournaments/#{my_tournament1.id}?locale=en", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:name]).to eq(my_tournament1.name)
      expect(json_response[:competition_mode]).to eq(my_tournament1.competition_mode(:en))
      expect(json_response[:competition_fee]).to eq(my_tournament1.competition_fee(:en))
      expect(json_response[:competition_schedule]).to eq(my_tournament1.competition_schedule(:en))
    end

    it 'with current user signed up this tournament' do
      get "/api/v1/tournaments/#{my_tournament1.id}?locale=en", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq(200)
      expect(json_response[:teams][:id]).to eq(my_team.id)
      expect(json_response[:teams][:status]).to eq(my_team.status)
    end

    it 'with current user not sign up this tournament' do
      other_tournament = create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now)
      get "/api/v1/tournaments/#{other_tournament.id}?locale=vi", headers: request_headers.merge(auth_headers)
      expect(response.status).to eq 200
      expect(json_response[:name]).to eq other_tournament.name
      expect(json_response[:teams]).to be nil
    end
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
