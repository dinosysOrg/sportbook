namespace :sb do
  namespace :import do
    desc 'Import players for a tournament'
    task :tournament, [:tournament_id, :dry_run] => [:environment, :require_tournament, :confirm_dry_run] do |t, args|
      tournament_id = args[:tournament_id]
      dry_run = args[:dry_run] != 'false'

      tournament = Tournament.find_by_id(tournament_id)
      puts "=== Tournament '#{tournament.name}' ==="

      ActiveRecord::Base.transaction do
        players = []
        matches = []

        file = Roo::Spreadsheet.open('./tournament_1.xlsx')
        players_sheet = file.sheet('Danh sách các trận đấu')
        players_sheet.parse(
          stt: 'STT',
          group: 'Bảng đấu',
          match_code: 'Mã trận',
          team_a: 'Cơ thủ 1',
          team_b: 'Cơ thủ 2',
          hour: 'Thời gian đăng ký',
          date: 'Ngày',
          venue: 'Địa điểm'
        ).each do |row|
          puts row.inspect

          # TODO: how to handle this?
          missing_required_attrs = [:group].map do |required_attr|
            row[required_attr].blank? ? required_attr : nil
          end.compact

          unless missing_required_attrs.empty?
            puts "***** SKIP missing attributes: #{missing_required_attrs.join(', ')} *****"
            next
          end

          group = tournament.groups.find_or_create_by!(name: row[:group].squish)
          venue = row[:venue] ? Venue.find_or_create_by!(name: row[:venue].squish) : nil

          team_a, team_b = [row[:team_a], row[:team_b]].map do |team_name|
            if team_name.blank?
              nil
            else
              team = group.teams.find_or_create_by!(name: team_name.squish)

              user = User.find_or_create_by!(name: team_name.squish) # TODO: phone_number is needed to identify user

              Player.find_or_create_by!(user_id: user.id, tournament_id: tournament_id, team_id: team.id)

              team
            end
          end

          # time = Time.zone.parse("#{row[:date]} #{row[:hour]}")
          # matches << Match.find_or_create_by!(group: group, team_a: team_a, team_b: team_b, time: time, venue: venue)
        end

        puts "Imported #{matches.count} matches without issues."
        if dry_run
          puts "Rolling back changes."
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end