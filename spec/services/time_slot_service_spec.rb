describe TimeSlotService do
  describe 'generating TimeSlot for objects' do
    it 'generates all time slots in that date range and hour range' do
      date_range = (Date.new(2017, 5, 15)..Date.new(2017, 5, 16)).to_a
      venues = create_list(:venue, 3)
      TimeSlotService.create_from_date_and_hour_range(venues, (9..11).to_a, date_range)
      venues.each do |venue|
        expect(venue.time_slots.pluck(:time)).to match_array(
          [
            Time.new(2017, 5, 15, 9),
            Time.new(2017, 5, 15, 10),
            Time.new(2017, 5, 15, 11),
            Time.new(2017, 5, 16, 9),
            Time.new(2017, 5, 16, 10),
            Time.new(2017, 5, 16, 11),
            Time.new(2017, 5, 15, 9),
            Time.new(2017, 5, 15, 10),
            Time.new(2017, 5, 15, 11),
            Time.new(2017, 5, 16, 9),
            Time.new(2017, 5, 16, 10),
            Time.new(2017, 5, 16, 11)
          ]
        )
      end
    end
  end

  describe '#generate_time_slots_for_team' do
    let(:date_range) { (Date.new(2017, 5, 15)..Date.new(2017, 5, 24)).to_a }
    let(:preferred_time_blocks) do
      {
        monday: [(9..10).to_a, (10..13).to_a],
        tuesday: [(9..10).to_a]
      }
    end

    it 'generates time slot array' do
      team = create(:team)
      TimeSlotService.create_from_preferred_time_blocks([team], date_range, preferred_time_blocks)
      expect(team.time_slots.pluck(:time)).to match_array(
        [
          Time.new(2017, 5, 15, 9),
          Time.new(2017, 5, 15, 10),
          Time.new(2017, 5, 15, 11),
          Time.new(2017, 5, 15, 12),
          Time.new(2017, 5, 15, 13),
          Time.new(2017, 5, 16, 9),
          Time.new(2017, 5, 16, 10),
          Time.new(2017, 5, 22, 9),
          Time.new(2017, 5, 22, 10),
          Time.new(2017, 5, 22, 11),
          Time.new(2017, 5, 22, 12),
          Time.new(2017, 5, 22, 13),
          Time.new(2017, 5, 23, 9),
          Time.new(2017, 5, 23, 10)
        ]
      )
    end
  end

  describe 'find available timeslots for team' do
    let!(:venue) { create(:venue) }
    let(:today) { Date.today }
    let(:tomorrow) { Date.tomorrow }
    let(:tournament) { create(:tournament, start_date: Date.today, end_date: 1.days.from_now) }
    let(:team) { create(:team, tournament: tournament) }

    before do
      TimeSlotService.create_from_date_and_hour_range([team], (9..10).to_a, (tournament.start_date..tournament.end_date))
    end

    it 'returns the available time slots' do
      returned_venues = TimeSlotService.possible_time_slots team
      returned_venue = returned_venues[0]

      expect(returned_venue.id).to eq(venue.id)
      expect(returned_venue.name).to eq(venue.name)
      expect(returned_venue.time_slots).to match_array(
        [
          Time.new(today.year, today.month, today.day, 9),
          Time.new(today.year, today.month, today.day, 10),
          Time.new(tomorrow.year, tomorrow.month, tomorrow.day, 9),
          Time.new(tomorrow.year, tomorrow.month, tomorrow.day, 10)
        ]
      )
    end

    it 'excludes unavailable time slots' do
      venue.time_slots.where(time: Time.new(tomorrow.year, tomorrow.month, tomorrow.day, 9)).update_all(available: false)

      returned_venues = TimeSlotService.possible_time_slots team
      returned_venue = returned_venues[0]

      expect(returned_venue.id).to eq(venue.id)
      expect(returned_venue.name).to eq(venue.name)
      expect(returned_venue.time_slots).to match_array(
        [
          Time.new(today.year, today.month, today.day, 9),
          Time.new(today.year, today.month, today.day, 10),
          Time.new(tomorrow.year, tomorrow.month, tomorrow.day, 10)
        ]
      )
    end
  end

  describe 'combine venue ranking' do
    it 'works' do
      result = TimeSlotService.combine_venue_rankings([1, 2, 3], [2, 3, 1])
      expect(result).to eq([2, 1, 3])

      result = TimeSlotService.combine_venue_rankings([1, 2, 3], [2, 1])
      expect(result).to eq([1, 2])
    end
  end

  describe 'find a time slot for a match' do
    let!(:venue) { create(:venue) }
    let(:tournament) { create(:tournament, start_date: today, end_date: Date.tomorrow) }
    let(:team_a) { create(:team, tournament: tournament, venue_ranking: [venue.id]) }
    let(:team_b) { create(:team, tournament: tournament, venue_ranking: [venue.id]) }
    let(:today) { Date.today }

    context 'when only 1 time slot matches' do
      it 'returns time slot and venue' do
        overlapping_time = Time.new(today.year, today.month, today.day, 9)
        create(:time_slot, object: team_a, time: overlapping_time)
        create(:time_slot, object: team_b, time: overlapping_time)

        chosen_time, chosen_venue = TimeSlotService.choose_time_slot team_a, team_b
        expect(chosen_time).to eq(overlapping_time)
        expect(chosen_venue).to eq(venue.id)
      end
    end

    context 'when no time slot matches' do
      it 'returns nil' do
        create(:time_slot, object: team_a, time: Time.new(today.year, today.month, today.day, 9))
        create(:time_slot, object: team_b, time: Time.new(today.year, today.month, today.day, 10))

        result = TimeSlotService.choose_time_slot team_a, team_b
        expect(result).to be_nil
      end
    end

    context 'when many time slots match' do
      it 'returns the earliest time slot' do
        later_overlapping_time = Time.new(today.year, today.month, today.day, 11)
        create(:time_slot, object: team_a, time: later_overlapping_time)
        create(:time_slot, object: team_b, time: later_overlapping_time)

        earlier_overlapping_time = Time.new(today.year, today.month, today.day, 9)
        create(:time_slot, object: team_a, time: earlier_overlapping_time)
        create(:time_slot, object: team_b, time: earlier_overlapping_time)

        chosen_time, chosen_venue = TimeSlotService.choose_time_slot team_a, team_b
        expect(chosen_time).to eq(earlier_overlapping_time)
        expect(chosen_venue).to eq(venue.id)
      end
    end

    context 'when many time slots of many venues match' do
      let!(:venue_1) { create(:venue) }
      let!(:venue_2) { create(:venue) }
      let!(:venue_3) { create(:venue) }
      let(:team_a) { create(:team, tournament: tournament, venue_ranking: [venue_1.id, venue_2.id, venue_3.id]) }
      let(:team_b) { create(:team, tournament: tournament, venue_ranking: [venue_2.id, venue_3.id, venue_1.id]) }

      it 'returns the earliest time slot' do
        later_overlapping_time = Time.new(today.year, today.month, today.day, 11)
        create(:time_slot, object: team_a, time: later_overlapping_time)
        create(:time_slot, object: team_b, time: later_overlapping_time)

        earlier_overlapping_time = Time.new(today.year, today.month, today.day, 9)
        create(:time_slot, object: team_a, time: earlier_overlapping_time)
        create(:time_slot, object: team_b, time: earlier_overlapping_time)

        venue_1.time_slots.where(time: earlier_overlapping_time).update_all(available: false)
        venue_2.time_slots.where(time: later_overlapping_time).update_all(available: false)
        venue_2.time_slots.where(time: earlier_overlapping_time).update_all(available: false)

        chosen_time, chosen_venue = TimeSlotService.choose_time_slot team_a, team_b
        expect(chosen_time).to eq(later_overlapping_time)
        expect(chosen_venue).to eq(venue_1.id)
      end
    end
  end
end
