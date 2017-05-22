describe TimeSlotService do
  describe 'generating TimeSlot for objects' do
    it 'generates all time slots in that date range and hour range' do
      date_range = (Date.new(2017, 5, 15)..Date.new(2017, 5, 16)).to_a
      venues = create_list(:venue, 3)
      TimeSlotService.instance.create_from_date_and_hour_range(venues, (9..11).to_a, date_range)
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
      TimeSlotService.instance.create_from_preferred_time_blocks([team], date_range, preferred_time_blocks)
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
end
