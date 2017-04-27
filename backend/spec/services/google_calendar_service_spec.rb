describe GoogleCalendarService do
  it 'works' do
    match = create :match
    result = GoogleCalendarService.instance.create_match_event(match)

    expect(result.html_link).to be_present
    expect(result.summary).to eq("#{match.code}:#{match.team_a.name} - #{match.team_b.name}")

    result_email_list = result.attendees.map(&:email)

    attandees_email = ['di.dy211@gmail.com']
    match.team_a.players.each do |player|
      attandees_email << player.user.email
    end

    match.team_b.players.each do |player|
      attandees_email << player.user.email
    end

    expect(result_email_list).to match_array(attandees_email)
  end
end
