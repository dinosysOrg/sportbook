describe NotificationsService do
  let!(:tournament1) { create(:tournament, start_date: 1.days.from_now, end_date: 2.weeks.from_now) }
  let!(:team) { create(:team, :has_players, tournament: tournament1) }
  let!(:match) { create(:match, time: nil, venue: nil) }
  let(:venue) { create(:venue) }
  let(:time_slot_venue) { create(:time_slot, object: venue, available: true) }
  let!(:time_slot_team_a) { create(:time_slot, object: match.team_a, available: true) }
  let!(:user1) { create(:api_user) }
  let!(:user2) { create(:api_user) }
  let!(:player1) { create(:player, team: team, user: user1) }
  let!(:player2) { create(:player, team: team, user: user2) }
  let!(:device_ios) { create(:device, user: user1, token: SecureRandom.uuid, platform: 0) }
  let!(:device_android) { create(:device, user: user2, token: SecureRandom.uuid, platform: 1) }
  let(:pending_invitation) do
    create :invitation, :pending, time: time_slot_venue.time, created_at: 1.days.ago.at_beginning_of_hour, match: match, venue: venue
  end

  describe 'push notification' do
    it 'push' do
      allow(NotificationsService).to receive(:push_notification)
    end
  end

  describe 'Create houston data' do
    let(:notification_options) do
      {
        token: SecureRandom.uuid,
        alert: 'Houston, we have a problem.',
        badge: 1,
        sound: 'sosumi.aiff',
        code: 201
      }
    end
    subject { Houston::Notification.new(notification_options) }

    describe '#alert' do
      subject { super().alert }
      it { should == 'Houston, we have a problem.' }
    end

    describe '#badge' do
      subject { super().badge }
      it { should == 1 }
    end

    describe '#sound' do
      subject { super().sound }
      it { should == 'sosumi.aiff' }
    end

    describe '#custom_data' do
      subject { super().custom_data }
      it { should == { code: 201 } }
    end
  end

  describe 'tournaments push notification' do
    it 'push_is_paid in device android' do
      tournament = Tournament.push_is_paid(device_android.user_id)
      expect(tournament[:status_code]).to eq(200)
      expect(tournament[:response]).to eq('success')
    end

    it 'push_is_paid in device ios' do
      Tournament.push_is_paid(device_ios.user_id)
    end

    it 'push_unpaid' do
      Tournament.push_unpaid
    end

    it 'push_upcoming' do
      Tournament.push_upcoming
    end
  end

  describe 'matches push notification' do
    it 'push_match_upcoming' do
      Match.push_match_upcoming
    end
  end

  describe 'invitations push notification' do
    it 'push_rejected in device android' do
      invitation = Invitation.push_rejected(device_android.user_id)
      expect(invitation[:status_code]).to eq(200)
      expect(invitation[:response]).to eq('success')
    end

    it 'push_rejected in device ios' do
      Invitation.push_rejected(device_ios.user_id)
    end

    it 'push_accepted in device android' do
      invitation = Invitation.push_accepted(device_android.user_id)
      expect(invitation[:status_code]).to eq(200)
      expect(invitation[:response]).to eq('success')
    end

    it 'push_accepted in device ios' do
      Invitation.push_accepted(device_ios.user_id)
    end

    it 'push_sent in device android' do
      invitation = Invitation.push_sent(device_android.user_id)
      expect(invitation[:status_code]).to eq(200)
      expect(invitation[:response]).to eq('success')
    end

    it 'push_sent in device ios' do
      Invitation.push_sent(device_ios.user_id)
    end

    it 'push_expired in device android' do
      invitation = Invitation.push_expired(device_android.user_id)
      expect(invitation[:status_code]).to eq(200)
      expect(invitation[:response]).to eq('success')
    end

    it 'push_expired in device ios' do
      Invitation.push_expired(device_ios.user_id)
    end
  end
end
