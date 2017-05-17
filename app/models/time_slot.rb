class TimeSlot < ApplicationRecord
  belongs_to :venue
  validate :check_time_slots_for_each_venue

  def check_time_slots_for_each_venue
    time = self.time
    venue_id = self.venue_id
    time_slots = TimeSlot.where('time=? and venue_id=?', time, venue_id)
    return unless time_slots.count >= Venue::CAPACITY

    errors.add(:time,
               :slot_full,
               capacity: Venue::CAPACITY,
               class: I18n.t("activerecord.models.#{Venue.name.downcase}").downcase)
  end
end
