describe 'TournamentsApi' do
  let!(:tour) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:api_user) { create(:api_user) }
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
    expect(json_response[:_embedded][:tournaments][0][:name]).to eq(tour.name)
  end

  it 'show one tournaments' do
    get "/api/v1/tournaments/#{tour.id}", headers: request_headers.merge(auth_headers)
    expect(response.status).to eq(200)
    expect(json_response[:name]).to eq(tour.name)
  end
end
