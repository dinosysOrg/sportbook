require 'rails_helper'

RSpec.describe Tournament, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:end_date) }
  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_uniqueness_of(:name) }

  describe 'after_create' do
    describe 'generating TimeSlot' do
      it 'generates all TimeSlot' do
        expect(TimeSlot.count).to eq(0)

        venues_count = 3
        create_list(:venue, venues_count)

        slots_per_venue_per_time_slot = 2
        number_of_days = 3
        slots_per_day = 16

        create(:tournament, start_date: Date.today, end_date: (number_of_days - 1).days.from_now)
        expect(TimeSlot.count).to eq(slots_per_day * number_of_days * slots_per_venue_per_time_slot * venues_count)
      end

      it 'just generates 2 timeslots for each venue' do
        expect(TimeSlot.count).to eq(0)

        venues_count = 1
        create_list(:venue, venues_count)

        create(:tournament, start_date: Date.today, end_date: 2.days.from_now)
        create(:tournament, start_date: 1.days.from_now, end_date: 2.days.from_now)
        create(:tournament, start_date: 1.days.ago, end_date: 5.days.from_now)

        new_time = Time.new(1.days.from_now.year, 1.days.from_now.month, 1.days.from_now.day, 9)
        time_slots = TimeSlot.where('time = ?', new_time)
        expect(time_slots.count).to eq(2)
      end
    end
  end
end
