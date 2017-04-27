require 'googleauth'
require 'google/apis/calendar_v3'
require 'singleton'

class GoogleCalendarService
  include Singleton

  def initialize
    authorize
  end

  def create_match_event(match)
    attendees_email = match.player_emails.map do |email|
      { email: email }
    end

    event = Google::Apis::CalendarV3::Event.new(
      summary: match.event_summary,
      location: match.venue.name,
      description: '',
      start: { date_time: match.event_start_time },
      end: { date_time: match.event_end_time },
      attendees: attendees_email
    )

    service.insert_event(match.venue.calendar_id, event)
  end

  private

  attr_reader(:service)

  def authorize
    @service = Google::Apis::CalendarV3::CalendarService.new
    scopes = [Google::Apis::CalendarV3::AUTH_CALENDAR]
    service.authorization = Google::Auth.get_application_default(scopes)
  end
end
