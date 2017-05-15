namespace :generate do
  desc 'Generate test data'
  task sample_data: :environment do
    [
      { name: 'Duy Nguyen', email: 'duy.nguyen@dinosys.vn' },
      { name: 'Zi', email: 'hungryzi@gmail.com' }
    ].each do |admin|
      u = AdminUser.find_or_create_by!(email: admin[:email], name: admin[:name]) do |new_user|
        new_user.password = 'password'
        new_user.confirmed_at = Time.now
        new_user.uid = new_user.email
      end

      # u.roles << Role.admin_role
    end

    [
      '9 Ball', '10 Ball'
    ].each do |tournament_name|
      Tournament.find_or_create_by!(name: tournament_name) do |tournament|
        tournament.start_date = Date.today
        tournament.end_date = 3.weeks.ago
      end
    end

    [
      'Carmen', 'Sinh đôi', 'Huyền thoại', 'Chuyên nghiệp'
    ].each do |venue_name|
      Venue.find_or_create_by!(name: venue_name) do |venue|
        venue.google_calendar_name = [
          'q240vu0q51lkmbbq70e8f2i344@group.calendar.google.com',
          'b0os5t7s53bgplis90aish9mhk@group.calendar.google.com'
        ].sample
      end
    end
  end
end
