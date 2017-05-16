require 'rails_helper'

RSpec.describe TimeSlot, type: :model do
  describe 'Validation' do
    describe 'generating TimeSlot' do
      it 'just generate 2 timeslots for each venue' do
        full_venue = create(:venue)
        create_list(:time_slot, 2, object: full_venue)
        extra_time_slot = full_venue.time_slots.build time: DateTime.now.at_beginning_of_hour
        expect(extra_time_slot).to_not be_valid
        expect(extra_time_slot.errors[:time]).to include('There can be only 2 timeslot per time for 1 venue')
      end
    end
  end
end
