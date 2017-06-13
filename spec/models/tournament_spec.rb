require 'rails_helper'

RSpec.describe Tournament, type: :model do
  it { is_expected.to have_many(:pages) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:end_date) }
  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_uniqueness_of(:name) }

  describe 'after_create' do
    it 'generates pages' do
      tournament = create(:tournament)
      Tournament::PAGE_NAMES.each do |p|
        I18n.available_locales.each do |l|
          expect(tournament.pages.where(name: p, locale: l).first).to be_present
        end
      end

      expect { tournament.update(name: 'Updated') }.to_not change(Page, :count)
    end

    describe 'generating TimeSlot' do
      it 'generates all TimeSlot' do
        expect(TimeSlot.count).to eq(0)

        create_list(:venue, 3)
        tournament = create(:tournament, start_date: Date.today, end_date: 3.days.from_now)

        slots_per_venue_per_time_slot = Venue::CAPACITY
        number_of_days = (tournament.start_date..tournament.end_date).count
        slots_per_day = (Venue::OPENING_HOUR..Venue::CLOSING_HOUR).count
        venues_count = Venue.count

        expect(TimeSlot.count).to eq(slots_per_day * number_of_days * slots_per_venue_per_time_slot * venues_count)
      end

      it 'just generates 2 timeslots for each venue' do
        expect(TimeSlot.count).to eq(0)

        venues_count = 1
        create_list(:venue, venues_count)

        create(:tournament, start_date: Date.today, end_date: 2.days.from_now)
        create(:tournament, start_date: 1.days.from_now, end_date: 2.days.from_now)
        create(:tournament, start_date: 1.days.ago, end_date: 5.days.from_now)

        overlapping_time = Time.new(1.days.from_now.year, 1.days.from_now.month, 1.days.from_now.day, 9)
        time_slots = TimeSlot.where('time = ?', overlapping_time)
        expect(time_slots.count).to eq(Venue::CAPACITY)
      end
    end
  end
  describe 'notification_create' do
    it 'registration is confirmed' do
      allow(Tournament).to receive(:registration_confirmed)
    end

    it 'registered' do
      allow(Tournament).to receive(:registered)
    end
  end
end
