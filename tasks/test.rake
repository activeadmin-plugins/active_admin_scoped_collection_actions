desc 'Creates a test rails app for the specs to run against'
task :setup do
  require 'rails/version'

  # --skip-javascript: Rails 8.1 emits `stale_when_importmap_changes` into the
  # generated ApplicationController whenever the app uses importmap, but the
  # dummy app runs against this gem's Gemfile (sprockets-rails + sass-rails, no
  # importmap-rails), so that call is undefined and the app dies on boot. The
  # generator gates the line on `using_importmap?`, which this flag turns off.
  rails_new_args = %w[
    --skip-turbolinks
    --skip-spring
    --skip-bootsnap
    --skip-javascript
    -m
    spec/support/rails_template.rb
  ].join(' ')

  system "bundle exec rails new spec/rails/rails-#{Rails::VERSION::STRING} #{rails_new_args}"
end
