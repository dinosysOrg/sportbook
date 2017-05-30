describe 'MatchesApi' do
  let!(:user) { create(:user) }
  context 'Player can view their upcoming confirmed matches' do
    it 'When not found user in matches' do
      create_list(:match, 5)
      get "/api/v1/user/#{user.id}/matches"
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches].count).to eq(0)
    end
    it 'When found user in matches' do
      team_a = create(:team)
      team_b = create(:team)
      api_user = create(:api_user)
      create(:player, team: team_a, user: api_user)
      matches = create(:match, team_a: team_a, team_b: team_b)
      get "/api/v1/user/#{api_user.id}/matches"
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches][0][:id]).to eq(matches.id)
    end
  end
end
