require 'singleton'

class TimeSlotService
  include Singleton

  def generate_time_slots(objects, hour_range, date_range)
    date_range.each do |date|
      hour_range.each do |hour|
        objects.each do |object|
          generate_time_slot(object, hour, date)
        end
      end
    end
  end

  def generate_time_slot(object, hour, date)
    new_time = Time.new(date.year, date.month, date.day, hour)
    object.class::CAPACITY.times do
      object.time_slots.create(time: new_time, available: true)
    end
  end
end
