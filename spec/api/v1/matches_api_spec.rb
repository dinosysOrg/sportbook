describe 'MatchesApi' do
  # let!(:tour) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  it 'user can view all upcoming opponent for a tour' do
    create(:tournament, start_date: 2.days.from_now, end_date: 3.weeks.from_now)
    create(:team, id: 1, tournament_id: tour.id, name: "Thanh Tùng")
    create(:team, id: 2, tournament_id: tour.id, name: "Thái Duy")
    create(:team, id: 3, tournament_id: tour.id, name: "Nguyễn Hoàng Minh Tài")
    create(:team, id: 4, tournament_id: tour.id, name: "Phương Thảo")
    create(:team, id: 5, tournament_id: tour.id, name: "Nguyen Hoang Lam")
    create(:team, id: 6, tournament_id: tour.id, name: "Nguyễn Nhật Thanh")
    create(:match, id: 1, team_a_id: 6, team_b_id: 1)
    create(:match, id: 2, team_a_id: 6, team_b_id: 2)
    create(:match, id: 3, team_a_id: 3, team_b_id: 6)
    create(:match, id: 4, team_a_id: 4, team_b_id: 5)
    get "/api/v1/matches", 
    params: { name: "Nguyễn Nhật Thanh" }
    expect(response.status).to eq(200)
  end

end