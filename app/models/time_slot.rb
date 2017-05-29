class TimeSlot < ApplicationRecord
  validate :check_time_slots_for_each_venue
  belongs_to :object, polymorphic: true

  validates :available, presence: true

  scope :available, -> { where(available: true) }

  def check_time_slots_for_each_venue
    current_time_slots_count = TimeSlot.where(time: time, object: object).count
    return unless current_time_slots_count >= object.class::CAPACITY

    add_slot_full_error
  end

  private

  def add_slot_full_error
    errors.add(:time,
               :slot_full,
               capacity: object.class::CAPACITY,
               class: I18n.t("activerecord.models.#{object.class.name.downcase}").downcase)
  end
end
