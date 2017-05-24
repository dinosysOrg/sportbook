class MatchesService
  class << self
    def assign_time_for_expiring_matches
      expiring_groups = find_expiring_groups
      unconfirmed_matches = expiring_groups.map do |group|
        update_matches_without_time(group)
      end.flatten

      return if unconfirmed_matches.empty?

      email = AdminMailer.notify_unconfirmed_matches(unconfirmed_matches)
      email&.deliver
    end

    private

    def find_expiring_groups
      Group.joins(:matches)
           .where('start_date <= ?', Date.tomorrow)
           .where(matches: { time: nil })
           .distinct
    end

    def update_matches_without_time(group)
      unconfirmed_matches = []

      group.matches.each do |match|
        chosen_time, chosen_venue_id = TimeSlotService.choose_time_slot match.team_a, match.team_b
        if chosen_time && chosen_venue_id
          match.update(venue_id: chosen_venue_id, time: chosen_time)
        else
          unconfirmed_matches << match
        end
      end

      unconfirmed_matches
    end
  end
end
