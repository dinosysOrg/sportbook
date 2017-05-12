require 'rails_helper'

RSpec.describe Tournament, type: :model do
  describe 'before_create' do
    describe 'generating TimeSlot' do
      it 'just generate 2 timeslots for each venue' do
        expect(TimeSlot.count).to eq(0)

        venues_count = 1
        create_list(:venue, venues_count)
        new_time = Time.new(Date.today.year, Date.today.month, Date.today.day, 9)
        Venue.find_each do |v|
          3.times do
            v.time_slots.create(time: new_time, available: true)
          end
        end
        time_slots = TimeSlot.where('time = ?', new_time)
        expect(time_slots.count).to eq(2)
      end
    end
  end
end
