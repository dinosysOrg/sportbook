describe 'MatchesApi' do
  let(:api_user) { create(:api_user) }
  let!(:match) { create(:match) }
  context 'Player can view their upcoming confirmed matches' do
    it 'When not found user in matches' do
      get "/api/v1/user/#{api_user.id}/matches"
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches].count).to eq(0)
    end
    it 'When found user in matches' do
      team_a = create(:team)
      team_b = create(:team)
      create(:player, team: team_a, user: api_user)
      match_a = create(:match, team_a: team_a, team_b: team_b)
      get "/api/v1/user/#{api_user.id}/matches"
      expect(response.status).to eq(200)
      expect(json_response[:_embedded][:matches].count).to eq(1)
      expect(json_response[:_embedded][:matches][0][:id]).to eq(match_a.id)
    end
  end
end
