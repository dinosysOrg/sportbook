class TimeSlot < ApplicationRecord
  belongs_to :venue
  validate :check_time_slots_for_each_venue

  def check_time_slots_for_each_venue
    time = self.time
    venue_id = self.venue_id
    time_slots = TimeSlot.where('time=? and venue_id=?', time, venue_id)
    errors.add(:time, :slot_full) if time_slots.count >= Venue::CAPACITY
  end
end
