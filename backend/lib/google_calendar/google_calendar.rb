require 'googleauth'
require 'google/apis/calendar_v3'
require 'byebug'

class GoogleCalendar

  def initialize
    authorize
  end

  def service
    @service
  end

  def events(reload=false)
    # NOTE: This is just for demonstration purposes and not complete.
    # If you have more than 2500 results, you'll need to get more than
    # one set of results.
    @events = nil if reload
    @events ||= service.list_events(calendar_id, max_results: 2500).items
  end

  def createMatchEvents
    event = Google::Apis::CalendarV3::Event.new({
      summary: 'Match',
      location: 'Carmen',
      description: 'Semi finals',
      start: {
        date_time: '2017-04-26T09:00:00+07:00',
        time_zone: 'Asia/Ho_Chi_Minh',
      },
      end: {
        date_time: '2017-04-26T17:00:00+07:00',
        time_zone: 'Asia/Ho_Chi_Minh',
      },
      attendees: [
        {email: 'di.dy211@gmail.com'},
        {email: 'sbrin@example.com'},
      ]
    })

    result = service.insert_event('primary', event)
    puts "Event created: #{result.html_link}"

  end

private

  def calendar_id
    @calendar_id ||= 'di.dy211@gmail.com'
  end

  def authorize
    calendar = Google::Apis::CalendarV3::CalendarService.new

    # An alternative to the following line is to set the ENV variable directly
    # in the environment or use a gem that turns a YAML file into ENV variables
    ENV['GOOGLE_APPLICATION_CREDENTIALS'] = "lib/google_calendar/Sportbook.json"
    scopes = [Google::Apis::CalendarV3::AUTH_CALENDAR]
    calendar.authorization = Google::Auth.get_application_default(scopes)

    @service = calendar
  end

end

cal = GoogleCalendar.new
puts cal.createMatchEvents