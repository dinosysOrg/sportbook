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

        file = Roo::Spreadsheet.open("./tournament_#{tournament_id}.xlsx")
        players_sheet = file.sheet('Danh sách các trận đấu')
        players_sheet.parse(
          stt: 'STT',
          group: 'Bảng đấu',
          match_code: 'Mã trận',
          team_a: 'Cơ thủ 1',
          team_b: 'Cơ thủ 2',
          hour: 'Thời gian đăng ký',
          date: 'Ngày',
          score: 'Tỉ số text',
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
          _, team_a_order, team_b_order = row[:match_code].split('-')

          team_a = if row[:team_a].blank?
            nil
          else
            team = tournament.teams.find_by!(name: row[:team_a].squish)
            team.groups_teams.find_or_create_by!(group_id: group.id, order: team_a_order)

            team
          end

          team_b = if row[:team_b].blank?
            nil
          else
            team = tournament.teams.find_by!(name: row[:team_b].squish)
            team.groups_teams.find_or_create_by!(group_id: group.id, order: team_b_order)

            team
          end

          time = nil
          if row[:date] && row[:hour]
            time = row[:date].to_datetime + ((row[:hour] / 3600).round * 3600).seconds
          end

          matches << Match.find_or_create_by!(group: group, team_a: team_a, team_b: team_b) do |match|
            match.time = time
            match.venue = venue
            match.code = row[:match_code]
            if row[:score]
              if row[:score] =~ /\-/
                match.score = row[:score]
              elsif row[:score] =~ /bỏ cuộc|bị xử thua/
                lost_team_names = row[:score].gsub(/bỏ cuộc|bị xử thua/, '').split('&')
                if lost_team_names.size == 1
                  lost_team_name = lost_team_names.first.strip
                  lost_team = if team_a.name == lost_team_name
                    team_a
                  elsif team_b.name == lost_team_name
                    team_b
                  else
                    raise 'Could not match lost team!!!'
                  end
                end
              end
            end
          end
        end

        puts "Imported #{matches.count} matches without issues."
        if dry_run
          puts 'Rolling back changes.'
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end
