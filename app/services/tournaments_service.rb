class TournamentsService
  class << self
    def tournament_detail(tournament_id, locale, current_user)
      locale = locale.present? ? locale.downcase.to_sym : I18n.locale
      tournament = Tournament.find_by_id(tournament_id)
      team = current_user.teams.find_by(tournament_id: tournament_id)
      OpenStruct.new id: tournament.id, name: tournament.name, start_date: tournament.start_date,
                     end_date: tournament.end_date, competition_mode: tournament.competition_mode(locale),
                     competition_fee: tournament.competition_fee(locale),
                     competition_schedule: tournament.competition_schedule(locale), teams: team
    end
  end
end
