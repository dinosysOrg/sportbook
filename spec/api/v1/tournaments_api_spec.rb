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


  it 'user can view all upcoming opponent for a tour' do
    create(:tournament ,  id: 2)
    create(:team, id: 1, tournament_id: 2, name: "Thanh Tùng")
    create(:team, id: 2, tournament_id: 2, name: "Thái Duy")
    create(:team, id: 3, tournament_id: 2, name: "Nguyễn Hoàng Minh Tài")
    create(:team, id: 4, tournament_id: 2, name: "Phương Thảo")
    create(:team, id: 5, tournament_id: 2, name: "Nguyen Hoang Lam")
    create(:team, id: 6, tournament_id: 2, name: "Nguyễn Nhật Thanh")
    create(:match, id: 1, team_a_id: 6, team_b_id: 1)
    create(:match, id: 2, team_a_id: 6, team_b_id: 2)
    create(:match, id: 3, team_a_id: 3, team_b_id: 6)
    create(:match, id: 4, team_a_id: 4, team_b_id: 5)
    get "/api/v1/tournaments/#{tour.id}/my-opponents", 
    params: { name: "Nguyễn Nhật Thanh" }
    expect(response.status).to eq(200)
    expect(response.body.length).to eq(57)
  end
end