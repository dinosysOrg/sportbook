class TimeSlot < ApplicationRecord
  belongs_to :match
  validate :check_time_slots_for_each_venue, on: :create
  belongs_to :object, polymorphic: true
  validates :available, inclusion: { in: [true, false] }
  scope :available, -> { where(available: true) }

  def check_time_slots_for_each_venue
    return unless object

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
