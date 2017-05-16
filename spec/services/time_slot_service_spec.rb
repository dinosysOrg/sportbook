describe TimeSlotService do
  it 'works' do
    date_range = (DateTime.now..DateTime.now).to_a
    time_slot = TimeSlotService.instance.generate_time_slots(Venue.all.to_a, (9..12).to_a, date_range)
    expect(time_slot).to be_present
  end
end
