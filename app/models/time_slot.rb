class TimeSlot < ApplicationRecord
  validate :check_time_slots_for_each_venue
  belongs_to :object, polymorphic: true

  def check_time_slots_for_each_venue
    time_slots = TimeSlot.where('time=? and object_id=?', time, object_id)
    errors.add(:time, :slot_full) if time_slots.count >= object.class::CAPACITY
  end
end
