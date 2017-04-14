namespace :generate do
  desc 'Generate test data'
  task sample_data: :environment do
    [
      { name: 'Duy Nguyen', email: 'duy.nguyen@dinosys.vn' },
      { name: 'Zi', email: 'hungryzi@gmail.com' }
    ].each do |admin|
      u = User.find_or_create_by!(email: admin[:email], name: admin[:name]) do |new_user|
        new_user.password = 'password'
        new_user.confirmed_at = Time.now
      end

      # u.roles << Role.admin_role
    end
  end
end
