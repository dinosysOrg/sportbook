namespace :sb do
  namespace :import do
    desc 'Import players for a tournament'
    task :players, [:dry_run] => [:environment, :confirm_dry_run] do |t, args|
      dry_run = args[:dry_run] != 'false'

      tournaments_mapping = {
        '9 Ball' => 1,
        '10 Ball' => 2
      }

      ActiveRecord::Base.transaction do
        players = []

        file = Roo::Spreadsheet.open('./players.xlsx')
        players_sheet = file.sheet('Form responses 1')
        players_sheet.parse(
          name: 'Họ và Tên / First & Last Name',
          phone_number: 'Số điện thoại / Phone Number',
          tournaments: 'Giải đấu tham gia / Type of tournaments',
          paid: 'Thanh toán / Payment',
          skill_level: 'Cấp độ cơ thủ / Skill level',
          address: 'Địa chỉ / Address',
          note: 'Hình thức liên lạc / Communication preference'
        ).each do |row|
          puts row.inspect

          missing_required_attrs = [:name].map do |required_attr|
            row[required_attr].blank? ? required_attr : nil
          end.compact

          unless missing_required_attrs.empty?
            puts "***** SKIP missing attributes: #{missing_required_attrs.join(', ')} *****"
            next
          end

          user = User.find_or_create_by!(name: row[:name].squish, phone_number: row[:phone_number].squish) do |u|
            u.phone_number = row[:phone_number].squish
            u.skill_level = (row[:skill_level].gsub(/\s+/, "")).downcase.underscore
            u.address = row[:address].try(:squish)
            u.note = row[:note].try(:squish)

            u.password = FFaker::Internet.password
            u.email = FFaker::Internet.email
          end

          tournament_names = row[:tournaments].split(',').map(&:squish)

          tournament_names.each do |name|
            puts tournaments_mapping[name]

            players << Player.find_or_create_by!(
              user_id: user.id,
              tournament_id: tournaments_mapping[name]
            )
          end
        end

        puts "Imported #{players.count} players without issues."
        if dry_run
          puts "!!!!! ROLLING BACK CHANGES !!!!"
          raise ActiveRecord::Rollback
        end
      end
    end
  end
end