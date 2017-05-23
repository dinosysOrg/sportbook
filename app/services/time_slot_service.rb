require 'singleton'

class TimeSlotService
  include Singleton

  def create_from_date_and_hour_range(objects, hour_range, date_range)
    slots = generate_time_slots_from_date_and_hour_range date_range, hour_range
    generate_time_slots_for_objects(objects, slots)
  end

  def create_from_preferred_time_blocks(objects, date_range, preferred_time_blocks)
    slots = generate_time_slots_from_preferred_time_blocks date_range, preferred_time_blocks
    generate_time_slots_for_objects(objects, slots)
  end

  private

  def generate_time_slots_from_preferred_time_blocks(date_range, preferred_time_blocks)
    date_range.map do |date|
      key = Date::DAYNAMES[date.wday].downcase.to_sym
      (preferred_time_blocks[key] || []).map do |hours|
        hours.map do |hour|
          generate_time(date, hour)
        end
      end
    end.flatten.uniq
  end

  def generate_time_slots_from_date_and_hour_range(date_range, hour_range)
    date_range.map do |date|
      hour_range.map do |hour|
        generate_time(date, hour)
      end
    end.flatten.uniq
  end

  def generate_time(date, hour)
    Time.new(date.year, date.month, date.day, hour)
  end

  def generate_time_slots_for_objects(objects, slots)
    slots.each do |slot|
      objects.each do |object|
        generate_time_slot(object, slot)
      end
    end
  end

  def generate_time_slot(object, time)
    object.class::CAPACITY.times do
      object.time_slots.create(time: time, available: true)
    end
  end
end
