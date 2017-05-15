describe 'TeamsApi' do
  let!(:tour) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:user) { create(:api_user, email: 'zi@dinosys.com', password: 'password') }
  let!(:user1) { create(:api_user, email: 'abc@dinosys.com', password: 'password') }
  let!(:user2) { create(:api_user, email: 'def@dinosys.com', password: 'password') }

  it 'sign up tournament without login' do
    post "/api/v1/tournaments/#{tour.id}/teams/create"
    expect(response.status).to eq(401)
  end

  context 'sign up tournament' do
    it 'sign up tournament without array user' do
      auth_headers = user.create_new_auth_token
      post "/api/v1/tournaments/#{tour.id}/teams/create", params: { name: 'TeamA' }.to_json,
                                                          headers: request_headers.merge(auth_headers)
      team = Team.find_by(name: 'TeamA', tournament_id: tour.id)
      expect(team).to be_present
      expect(response.status).to eq(201)
      expect(team.players.find_by_user_id(user.id)['user_id']).to eq(user.id)
    end

    it 'sign up tournament with array user' do
      auth_headers = user.create_new_auth_token
      user_id_array = [user1.id, user2.id]
      post "/api/v1/tournaments/#{tour.id}/teams/create", params: { user_ids: user_id_array, name: 'TeamA' }.to_json,
                                                          headers: request_headers.merge(auth_headers)
      team = Team.find_by(name: 'TeamA', tournament_id: tour.id)
      expect(team).to be_present
      expect(response.status).to eq(201)
      expect(team.players.find_by_user_id(user.id)['user_id']).to eq(user.id)
      expect(team.players.find_by_user_id(user1.id)['user_id']).to eq(user1.id)
      expect(team.players.find_by_user_id(user2.id)['user_id']).to eq(user2.id)
    end
  end
end
