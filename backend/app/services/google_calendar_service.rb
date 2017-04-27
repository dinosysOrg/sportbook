require 'googleauth'
require 'google/apis/calendar_v3'
require 'singleton'

class GoogleCalendarService
  include Singleton

  def initialize
    authorize
  end

  def authorize
    @service = Google::Apis::CalendarV3::CalendarService.new

    # An alternative to the following line is to set the ENV variable directly
    # in the environment or use a gem that turns a YAML file into ENV variables
    scopes = [Google::Apis::CalendarV3::AUTH_CALENDAR]
    service.authorization = Google::Auth.get_application_default(scopes)
  end

  def create_match_event(match)
    attandees_email = []
    match.team_a.players.each do |player|
      attandees_email << {email: player.user.email}
    end

    match.team_b.players.each do |player|
      attandees_email << {email: player.user.email}
    end

    event = Google::Apis::CalendarV3::Event.new({
      summary: "#{match.code}:#{match.team_a.name} - #{match.team_b.name}",
      location: match.venue,
      description: "",
      start: {
        date_time: match.time.to_datetime.rfc3339(2),
        time_zone: 'Asia/Ho_Chi_Minh',
      },
      end: {
        date_time: (match.time+1.hour).to_datetime.rfc3339(2),
        time_zone: 'Asia/Ho_Chi_Minh',
      },
      attendees: attandees_email
    })

    service.insert_event(match.venue.calendar_id, event)
  end

  private

  attr_reader(:service)

end