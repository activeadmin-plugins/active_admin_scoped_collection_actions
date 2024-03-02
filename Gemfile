source 'https://rubygems.org'

gemspec

group :test do
  default_rails_version = '7.1.0'
  default_activeadmin_version = '3.2.0'

  gem 'rails', "~> #{ENV['RAILS'] || default_rails_version}"
  gem 'activeadmin', "~> #{ENV['AA'] || default_activeadmin_version}"

  gem 'sprockets-rails'
  gem 'rspec-rails'
  gem 'coveralls_reborn', require: false
  gem 'sass-rails'
  gem 'sqlite3', '~> 1.4.0'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'capybara'
  gem 'webdrivers'
  gem 'byebug'
  gem 'draper'
  gem 'webrick', require: false
end
