describe 'MatchesApi' do
  let!(:tour) { create(:tournament) }
  let!(:user) { create(:user) }
    context 'Player can view their upcoming confirmed matches' do
      it 'When tournament_id is nil. There are 5 matches.' do
        create_list(:match, 5)
        get "/api/v1/matches", 
        params: { user_id: nil , tournament_id: nil }
        expect(response.status).to eq(200)
        expect(json_response[:_embedded][:matches].count).to eq(5)
      end
    end
    context 'Player can view their upcoming confirmed matches' do
      it 'When tournament_id != nil.There are 1 match.' do
        create_list(:match, 5)
        get "/api/v1/matches/#{tour.id+1}", 
        params: {tournament_id: tour.id + 1 }
        expect(response.status).to eq(200)
        expect(json_response[:_embedded][:matches].count).to eq(1)
      end
    end
    context 'Player can view their upcoming confirmed matches' do
      it 'When user_id != nil.There are 5 matches.' do
        create_list(:match, 5)
        get "/api/v1/matches/#{user.id}/user", 
        params: { user_id: user.id }
        expect(response.status).to eq(200)
        expect(json_response[:_embedded][:matches].count).to eq(5)
      end
    end
end