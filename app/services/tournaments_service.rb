class TournamentsService
  class << self
    def tournament_detail(tournament_id, current_user)
      tournament = Tournament.find(tournament_id)
      team = current_user.teams.find_by(tournament_id: tournament_id)
      OpenStruct.new id: tournament.id, name: tournament.name, start_date: tournament.start_date,
                     end_date: tournament.end_date, competition_mode: tournament.competition_mode,
                     competition_fee: tournament.competition_fee,
                     competition_schedule: tournament.competition_schedule, teams: team
    end
  end
end
