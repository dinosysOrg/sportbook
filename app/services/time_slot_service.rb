class TimeSlotService
  class << self
    def create_from_date_and_hour_range(objects, hour_range, date_range)
      slots = generate_time_slots_from_date_and_hour_range date_range, hour_range
      generate_time_slots_for_objects(objects, slots)
    end

    def create_from_preferred_time_blocks(objects, date_range, preferred_time_blocks)
      slots = generate_time_slots_from_preferred_time_blocks date_range, preferred_time_blocks
      generate_time_slots_for_objects(objects, slots)
    end

    def possible_time_slots(team, date = nil)
      team_time_slots = get_team_timeslot team, date
      Venue.all.map do |venue|
        shared_time_slots = venue.time_slots.available.where(time: team_time_slots).pluck(:time).uniq
        OpenStruct.new id: venue.id, name: venue.name, time_slots: shared_time_slots
      end
    end

    def get_team_timeslot(team, date)
      return team.time_slots.available.pluck(:time) unless date
      team.time_slots.available.where('time BETWEEN ? AND ?', Time.zone.parse(date), Time.zone.parse(date) + TimeSlot::DURATION_TIMESLOT).pluck(:time)
    end

    def choose_time_slot(team_a, team_b)
      time_slots = common_time_slots team_a, team_b

      return nil if time_slots.empty?

      combined_venue_ranking = combine_venue_rankings team_a.venue_ranking, team_b.venue_ranking
      Venue.find(combined_venue_ranking).each do |venue|
        result = find_time_slots_at_venue venue, time_slots
        return result unless result.nil?
      end
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

    def common_time_slots(team_a, team_b)
      TimeSlot.joins('INNER JOIN time_slots AS time_slots_b ON time_slots.time = time_slots_b.time')
              .where(object: team_a, available: true)
              .where(time_slots_b: { object_type: team_b.class.name, object_id: team_b.id, available: true })
              .pluck(:time)
              .uniq
    end

    def find_time_slots_at_venue(venue, time_slots)
      available_time_slot = venue.time_slots.available.where(time: time_slots).order(:time).pluck(:time).first
      available_time_slot.nil? ? nil : [available_time_slot, venue.id]
    end

    def combine_venue_rankings(venue_ranking_a, venue_ranking_b)
      venue_ranking_a.map.with_index do |venue_id, index|
        index_b = venue_ranking_b.index(venue_id)
        index_b ? [venue_id, index + venue_ranking_b.index(venue_id)] : nil
      end.compact.sort_by do |_venue_id, point|
        point
      end.map do |venue_id, _point|
        venue_id
      end
    end
  end
end
