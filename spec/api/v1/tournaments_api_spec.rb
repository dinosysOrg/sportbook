describe 'TournamentsApi' do
  let!(:tour) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  it 'show all tournaments' do
    create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
    create(:tournament, start_date: 3.days.from_now, end_date: 4.weeks.from_now)
    create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
    create(:tournament, start_date: 2.days.from_now, end_date: 4.weeks.from_now)
    create(:tournament, start_date: 5.days.ago, end_date: 1.days.ago)
    create(:tournament, start_date: 3.days.ago, end_date: 2.weeks.from_now)
    create(:tournament, start_date: 4.days.ago, end_date: 1.weeks.from_now)
    get '/api/v1/tournaments'
    expect(response.status).to eq(200)
    expect(json_response[:_embedded][:tournaments].count).to eq(5)
    expect(json_response[:_embedded][:tournaments][0][:name]).to eq(tour.name)
  end

  it 'show one tournaments' do
    get "/api/v1/tournaments/#{tour.id}"
    expect(response.status).to eq(200)
    expect(json_response[:name]).to eq(tour.name)
  end


  it 'user can view all upcoming component for a tour' do
    post "/api/v1/tournaments/#{tour.id}/my-opponents", 
    params: { namene: "Nguyễn Nhật Thanh" }
  end
end