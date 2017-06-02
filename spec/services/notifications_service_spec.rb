describe NotificationsService do
  describe 'push notification' do
    it 'push' do
      user1 = create(:api_user)
      user2 = create(:api_user)
      team = create(:team)
      create(:player, team: team, user: user1)
      create(:player, team: team, user: user2)
      create(:device, user: user1, token: SecureRandom.uuid, platform: 0)
      create(:device, user: user2, token: SecureRandom.uuid, platform: 1)

      allow(NotificationsService).to receive(:push_notification)
    end
  end
end
