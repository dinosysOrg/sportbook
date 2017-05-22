class TimeSlot < ApplicationRecord
  validate :check_time_slots_for_each_venue
  belongs_to :object, polymorphic: true

  def check_time_slots_for_each_venue
  time_slots = TimeSlot.where('time=? and object_id=?', time, object_id)
  return unless time_slots.count >= object.class::CAPACITY

  errors.add(:time,
             :slot_full,
             capacity: object.class::CAPACITY,
             class: I18n.t("activerecord.models.#{object.class.name.downcase}").downcase)
  end
end
