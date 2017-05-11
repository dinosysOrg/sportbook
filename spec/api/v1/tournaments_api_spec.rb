describe 'TournamentsApi' do
  it 'show all tournaments' do
    tour0 = create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now)
    tour1 = create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
    tour2 = create(:tournament, start_date: 3.days.from_now, end_date: 4.weeks.from_now)
    tour3 = create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
    tour4 = create(:tournament, start_date: 2.days.from_now, end_date: 4.weeks.from_now)
    create(:tournament, start_date: 5.days.ago, end_date: 1.days.ago)
    create(:tournament, start_date: 3.days.ago, end_date: 2.weeks.from_now)
    create(:tournament, start_date: 4.days.ago, end_date: 1.weeks.from_now)
    get '/api/v1/tournaments'
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:tournaments].count).to eq(5)
    expect(json_response[:_embedded][:tournaments][0][:name]).to eq(tour0.name)
  end

  it 'show one tournaments' do
    tour0 = create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now)
    get "/api/v1/tournaments/#{tour0.id}"
    expect(response.status).to eq(200)
    expect(json_response[:name]).to eq(tour0.name)
  end
end
