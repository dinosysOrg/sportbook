describe MatchesService do
  describe 'assign_time_for_expiring_matches' do
    let(:group) { create :group, start_date: Date.tomorrow }
    let(:match) { create :match, group: group, time: nil, venue: nil }

    it 'updates matches time' do
      mock_time = Time.zone.now.beginning_of_hour
      mock_venue = create :venue
      allow(TimeSlotService).to receive(:choose_time_slot).and_return [mock_time, mock_venue.id]

      expect(match.time).to eq(nil)
      expect(match.venue).to eq(nil)
      MatchesService.assign_time_for_expiring_matches

      match.reload
      expect(match.time).to eq(mock_time)
      expect(match.venue).to eq(mock_venue)
    end

    it 'does not update matches that are not expiring' do
      not_expiring_group = create :group, start_date: Date.today + 5
      not_expiring_match = create :match, group: not_expiring_group, time: nil, venue: nil

      expect(not_expiring_match.time).to eq(nil)
      expect(not_expiring_match.venue).to eq(nil)
      MatchesService.assign_time_for_expiring_matches

      not_expiring_match.reload
      expect(not_expiring_match.time).to eq(nil)
      expect(not_expiring_match.venue).to eq(nil)
    end

    context 'when it does not find any time slot' do
      it 'does not update match' do
        allow(TimeSlotService).to receive(:choose_time_slot).and_return nil

        expect(match.time).to eq(nil)
        expect(match.venue).to eq(nil)
        MatchesService.assign_time_for_expiring_matches

        match.reload
        expect(match.time).to eq(nil)
        expect(match.venue).to eq(nil)
      end

      it 'sends an email to admins' do
        another_match = create :match, group: group, time: nil, venue: nil

        expect(AdminMailer).to receive(:notify_unconfirmed_matches).with(match_array([match, another_match]))
        MatchesService.assign_time_for_expiring_matches
      end
    end
  end
end
