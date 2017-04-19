namespace :sb do
  namespace :remove do
    desc 'Remove a tournament and all of its information'
    task :tournament, [:tournament_id, :dry_run] => [:environment, :require_tournament, :confirm_dry_run] do |t, args|
      tournament_id = args[:tournament_id]
      dry_run = args[:dry_run] != 'false'

      tournament = Tournament.find_by_id(tournament_id)
      puts "=== Tournament '#{tournament.name}' ==="

      ActiveRecord::Base.transaction do
        puts "Removing #{tournament.matches.count} matches."
        # tournament.matches.destroy_all

        puts "Removing #{tournament.players.count} players."
        # tournament.players.destroy_all

        puts "Removing #{tournament.teams.count} teams."
        tournament.teams.destroy_all

        puts "Removing #{tournament.groups.count} groups."
        tournament.groups.destroy_all

        puts "Removing #{tournament.name} tournament."
        # tournament.destroy

        if dry_run
          puts "Rolling back changes."
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end