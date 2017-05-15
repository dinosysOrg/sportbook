source 'https://rubygems.org'
ruby '2.3.1'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'activeadmin', '~> 1.0.0.pre5'
gem 'arctic_admin'

gem 'grape'
gem 'grape-roar'
gem 'grape-swagger'
gem 'hashie-forbidden_attributes'
gem 'rack-cors'
gem 'roar'
gem 'grape-middleware-logger'
gem 'grape-route-helpers'

gem 'cancancan'
gem 'grape-cancan'

gem 'kaminari'
gem 'api-pagination'
gem 'pg_search'

gem 'grape_devise_token_auth'

gem 'devise'
gem 'devise-i18n'
gem 'devise_token_auth'
gem 'grape_devise_token_auth'

gem 'ffaker' # to generate sample data
gem 'rollbar'
gem 'newrelic_rpm'

gem 'roo'
gem 'friendly_id'
gem 'draper', '3.0.0.pre1'
gem 'auto_strip_attributes'

gem 'google-api-client'
gem 'dotenv-rails'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.2'
gem 'rails-i18n'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

gem 'font-awesome-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use HAML for views
gem 'haml-rails', '~> 0.9'

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Gem for facebook
gem 'koala'

source 'https://rails-assets.org' do
  gem 'rails-assets-lodash'
  gem 'rails-assets-jquery.tablesorter'
end

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
# gem 'turbolinks', '~> 5'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'railroady'
  gem 'i18n-tasks', '~> 0.9.13'
end

group :test do
  gem 'shoulda-matchers'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'overcommit'
  gem 'rubocop', require: false
  gem 'letter_opener'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
