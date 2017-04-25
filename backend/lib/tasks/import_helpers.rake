namespace :sb do
  task :require_tournament, [:tournament_id] => [:environment] do |t, args|
    tournament_id = args[:tournament_id]
    unless tournament_id
      puts 'Please provide TOURNAMENT_ID: rake "sb:import:players[TOURNAMENT_ID, DRY_RUN]"'
      exit
    end

    tournament = Tournament.find_by_id(tournament_id)
    unless tournament
      puts "Tournament with ID: #{tournament_id} is not found"
      exit
    end
  end

  task :confirm_dry_run, [:tournament_id, :dry_run] do |t, args|
    dry_run = args[:dry_run] != 'false'
    if dry_run
      puts '!!!!! THIS IS A DRY RUN !!!!!'
    else
      puts 'Are you sure you want to populate to the database? Answer Y/N'
      input = STDIN.gets.chomp
      exit unless input == 'Y'
    end
  end
end