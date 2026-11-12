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

  # Keep in step with spec_helper, which names the ActiveAdmin 4 app apart.
  aa_v4 = Gem.loaded_specs['activeadmin'].version >= Gem::Version.new('4.0.0.beta1')
  rails_root = ENV['RAILS_ROOT'] || "spec/rails/rails-#{Rails::VERSION::STRING}#{'-aa4' if aa_v4}"
  system "bundle exec rails new #{rails_root} #{rails_new_args}"
end
